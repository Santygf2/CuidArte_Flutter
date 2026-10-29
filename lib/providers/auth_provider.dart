import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiClient? apiClient, TokenStorageBase? tokenStorage})
    : _api = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? createTokenStorage();

  final ApiClient _api;
  final TokenStorageBase _tokenStorage;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>> _fieldErrors = const {};

  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.client;
  bool get isCaregiver => currentRole == UserRole.caregiver;
  bool get isClient => currentRole == UserRole.client;
  bool get isAdmin => currentRole == UserRole.admin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  String? fieldError(String field) {
    final messages = _fieldErrors[field];
    return messages != null && messages.isNotEmpty ? messages.first : null;
  }

  Future<void> restoreSession() async {
    _status = AuthStatus.unknown;
    notifyListeners();

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      final data = await _api.get('/auth/me/');
      if (data is Map) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));
        _status = AuthStatus.authenticated;
      } else {
        throw ApiException(null, 'Respuesta inválida del servidor.');
      }
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _tokenStorage.clear();
      }
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    _beginRequest();
    try {
      final data = await _api.post(
        '/auth/login/',
        body: {'email': email.trim(), 'password': password},
        auth: false,
      );
      await _applyAuthPayload(data);
      return currentRole;
    } on ApiException catch (error) {
      _captureError(error);
      rethrow;
    } finally {
      _endRequest();
    }
  }

  Future<UserRole> registerClientAccount({
    required String name,
    required String lastName,
    required String email,
    required DateTime birthDate,
    required String password,
    String? confirmPassword,
    bool acceptedTerms = true,
    String? phone,
    String? city,
    String? address,
  }) async {
    _beginRequest();
    try {
      final data = await _api.post(
        '/auth/register/client/',
        body: {
          'nombre': name.trim(),
          'apellido': lastName.trim(),
          'correo': email.trim(),
          'fecha_nacimiento': _formatDate(birthDate),
          'password': password,
          'password_confirm': confirmPassword ?? password,
          'terminos': acceptedTerms,
          if (phone != null && phone.trim().isNotEmpty)
            'telefono': phone.trim(),
          if (city != null && city.trim().isNotEmpty) 'ciudad': city.trim(),
          if (address != null && address.trim().isNotEmpty)
            'direccion': address.trim(),
        },
        auth: false,
      );
      await _applyAuthPayload(data);
      return currentRole;
    } on ApiException catch (error) {
      _captureError(error);
      rethrow;
    } finally {
      _endRequest();
    }
  }

  Future<UserRole> registerCaregiverAccount({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required DateTime birthDate,
    required String specialty,
    required String experience,
    required String password,
    String? confirmPassword,
    bool acceptedTerms = true,
    String? city,
    String? address,
    String? cedula,
  }) async {
    _beginRequest();
    try {
      final data = await _api.post(
        '/auth/register/caregiver/',
        body: {
          'nombre': name.trim(),
          'apellido': lastName.trim(),
          'correo': email.trim(),
          'telefono': phone.trim(),
          'fecha_nacimiento': _formatDate(birthDate),
          'especialidad': specialty,
          'experiencia': experience.trim(),
          'password': password,
          'password_confirm': confirmPassword ?? password,
          'terminos': acceptedTerms,
          if (city != null && city.trim().isNotEmpty) 'ciudad': city.trim(),
          if (address != null && address.trim().isNotEmpty)
            'direccion': address.trim(),
          if (cedula != null && cedula.trim().isNotEmpty)
            'cedula': cedula.trim(),
        },
        auth: false,
      );
      await _applyAuthPayload(data);
      return currentRole;
    } on ApiException catch (error) {
      _captureError(error);
      rethrow;
    } finally {
      _endRequest();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String lastName,
    required String email,
    String? phone,
    String? city,
    DateTime? birthDate,
    String? cedula,
    String? experiencia,
    String? especialidades,
  }) async {
    _beginRequest();
    try {
      final data = await _api.patch(
        '/auth/me/',
        body: {
          'nombre': name.trim(),
          'apellido': lastName.trim(),
          'correo': email.trim(),
          if (phone != null) 'telefono': phone.trim(),
          if (city != null) 'ciudad': city.trim(),
          if (birthDate != null) 'fecha_nacimiento': _formatDate(birthDate),
          if (cedula != null) 'cedula': cedula.trim(),
          if (experiencia != null) 'experiencia': experiencia.trim(),
          'especialidades': ?especialidades,
        },
      );
      if (data is Map) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));
        _status = AuthStatus.authenticated;
      }
    } on ApiException catch (error) {
      _captureError(error);
      rethrow;
    } finally {
      _endRequest();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _beginRequest();
    try {
      await _api.post(
        '/auth/change-password/',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': confirmPassword,
        },
      );
    } on ApiException catch (error) {
      _captureError(error);
      rethrow;
    } finally {
      _endRequest();
    }
  }

  Future<void> reloadProfile() async {
    if (!isAuthenticated) {
      return;
    }
    try {
      final data = await _api.get('/auth/me/');
      if (data is Map) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));
        notifyListeners();
      }
    } on ApiException catch (error) {
      _captureError(error);
      notifyListeners();
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final data = await _api.post(
      '/auth/password-reset/',
      body: {'email': email.trim()},
      auth: false,
    );
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return 'Si el correo está registrado, recibirás un enlace para '
        'restablecer tu contraseña.';
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null && _fieldErrors.isEmpty) {
      return;
    }
    _errorMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  Future<void> _applyAuthPayload(dynamic data) async {
    if (data is! Map) {
      throw ApiException(null, 'Respuesta inválida del servidor.');
    }
    final payload = Map<String, dynamic>.from(data);
    final access = payload['access'];
    final refresh = payload['refresh'];
    final user = payload['user'];
    if (access is! String || refresh is! String || user is! Map) {
      throw ApiException(null, 'Respuesta inválida del servidor.');
    }
    await _tokenStorage.saveTokens(access, refresh);
    _currentUser = UserModel.fromJson(Map<String, dynamic>.from(user));
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    _fieldErrors = const {};
  }

  void _beginRequest() {
    _isLoading = true;
    _errorMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  void _endRequest() {
    _isLoading = false;
    notifyListeners();
  }

  void _captureError(ApiException error) {
    _errorMessage = error.message;
    _fieldErrors = error.fieldErrors;
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
