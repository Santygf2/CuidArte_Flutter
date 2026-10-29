import 'dart:convert';
import 'dart:io';

import 'token_storage_base.dart';

const _accessKey = 'access_token';
const _refreshKey = 'refresh_token';

class _FileTokenStorage implements TokenStorageBase {
  Future<File> _file() async {
    final environment = Platform.environment;
    final base = environment['APPDATA'] ?? environment['HOME'];
    final directory = base != null && base.isNotEmpty
        ? Directory('$base${Platform.pathSeparator}CuidArte')
        : Directory(
            '${Directory.systemTemp.path}${Platform.pathSeparator}CuidArte',
          );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}${Platform.pathSeparator}session.json');
  }

  Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return <String, dynamic>{};
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <String, dynamic>{};
      }
      final decoded = jsonDecode(raw);
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _writeAll(Map<String, dynamic> data) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {}
  }

  @override
  Future<String?> readAccessToken() async {
    final data = await _readAll();
    final value = data[_accessKey];
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  Future<String?> readRefreshToken() async {
    final data = await _readAll();
    final value = data[_refreshKey];
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final data = await _readAll();
    data[_accessKey] = accessToken;
    data[_refreshKey] = refreshToken;
    await _writeAll(data);
  }

  @override
  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

TokenStorageBase createPlatformTokenStorage() => _FileTokenStorage();
