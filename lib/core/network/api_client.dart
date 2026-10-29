import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiException implements Exception {
  ApiException(
    this.statusCode,
    this.message, {
    this.fieldErrors = const <String, List<String>>{},
    this.code,
  });

  final int? statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? code;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  String? fieldError(String field) {
    final messages = fieldErrors[field];
    return messages != null && messages.isNotEmpty ? messages.first : null;
  }

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

class ApiClient {
  ApiClient({http.Client? client, TokenStorageBase? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? createTokenStorage();

  static const _timeout = Duration(seconds: 20);

  final http.Client _client;
  final TokenStorageBase _tokenStorage;
  Future<bool>? _refreshInFlight;

  /// Backend Django desplegado en Vercel.
  static const String productionBaseUrl =
      'https://cuid-arte-gamma.vercel.app/api/v1';

  /// Base de la API.
  ///
  /// Prioridad:
  /// 1. `--dart-define=API_URL=https://mi-backend/api/v1`
  /// 2. `--dart-define=USE_LOCAL_API=true` para desarrollo contra Django local.
  /// 3. Backend de producción en Vercel.
  static String get baseUrl {
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) {
      return _normalizeBase(override);
    }
    const useLocalApi = bool.fromEnvironment('USE_LOCAL_API');
    if (useLocalApi) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000/api/v1';
      }
      return 'http://127.0.0.1:8000/api/v1';
    }
    return productionBaseUrl;
  }

  /// Origen del backend (sin el prefijo de la API), útil para media.
  static String get serverOrigin => Uri.parse(baseUrl).origin;

  /// Convierte rutas relativas devueltas por Django (ej. `/media/foto.jpg`)
  /// en URLs absolutas para que funcionen en web y móvil.
  static String resolveUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return url;
    final parsed = Uri.tryParse(url);
    if (parsed != null && parsed.hasScheme) return url;
    if (url.startsWith('//')) return 'https:$url';
    return url.startsWith('/')
        ? '$serverOrigin$url'
        : '$serverOrigin/$url';
  }

  static String _normalizeBase(String value) =>
      value.replaceAll(RegExp(r'/+$'), '');

  Future<dynamic> get(String path, {bool auth = true}) {
    return _send('GET', path, auth: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) {
    return _send('PATCH', path, body: body, auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = true}) {
    return _send('DELETE', path, auth: auth);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$baseUrl${_normalize(path)}');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }
    if (auth) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    late final http.Response response;
    try {
      final payload = body == null ? null : jsonEncode(body);
      response = await switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: payload),
        'PATCH' => _client.patch(uri, headers: headers, body: payload),
        'DELETE' => _client.delete(uri, headers: headers, body: payload),
        _ => throw UnsupportedError('Método HTTP no soportado: $method'),
      }
          .timeout(_timeout);
    } on TimeoutException {
      throw ApiException(
        null,
        'La conexión tardó demasiado. Verifica tu internet e intenta de nuevo.',
      );
    } on http.ClientException {
      throw ApiException(
        null,
        'No se pudo conectar con el servidor de CuidArte. Intenta de nuevo.',
      );
    } on Exception {
      throw ApiException(
        null,
        'No se pudo conectar con el servidor de CuidArte. Intenta de nuevo.',
      );
    }

    if (response.statusCode == 401 && auth && !retried) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(
          method,
          path,
          body: body,
          auth: auth,
          retried: true,
        );
      }
      await _tokenStorage.clear();
      throw ApiException(
        401,
        'Tu sesión expiró. Inicia sesión nuevamente.',
        code: 'sesion_expirada',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decode(response);
    }

    throw _buildError(response);
  }

  Future<bool> _tryRefresh() {
    return _refreshInFlight ??= _refresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/refresh/'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        return false;
      }
      final data = _decode(response);
      if (data is! Map) {
        return false;
      }
      final accessToken = data['access'];
      if (accessToken is! String || accessToken.isEmpty) {
        return false;
      }
      await _tokenStorage.saveTokens(accessToken, refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return null;
    }
    final text = utf8.decode(response.bodyBytes);
    if (text.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  ApiException _buildError(http.Response response) {
    final decoded = _decode(response);
    var message = 'Ocurrió un error inesperado. Intenta de nuevo.';
    String? code;
    final fieldErrors = <String, List<String>>{};

    if (decoded is Map) {
      final data = decoded.cast<String, dynamic>();
      final detail = data['detail'];
      if (data['code'] is String) {
        code = data['code'] as String;
      }
      if (detail is String) {
        message = detail;
      } else {
        for (final entry in data.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            final messages = value.map((item) => item.toString()).toList();
            fieldErrors[entry.key] = messages;
            if (message == 'Ocurrió un error inesperado. Intenta de nuevo.') {
              message = messages.first;
            }
          } else if (value is String && value.isNotEmpty) {
            fieldErrors[entry.key] = [value];
            if (message == 'Ocurrió un error inesperado. Intenta de nuevo.') {
              message = value;
            }
          }
        }
      }
    } else if (decoded is String && decoded.trim().isNotEmpty) {
      message = decoded;
    }

    return ApiException(
      response.statusCode,
      message,
      fieldErrors: fieldErrors,
      code: code,
    );
  }

  String _normalize(String path) {
    return path.startsWith('/') ? path : '/$path';
  }
}
