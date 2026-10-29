import 'package:web/web.dart' as web;

import 'token_storage_base.dart';

const _accessKey = 'cuidarte.access_token';
const _refreshKey = 'cuidarte.refresh_token';

class _WebTokenStorage implements TokenStorageBase {
  String? _read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  void _write(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {}
  }

  void _remove(String key) {
    try {
      web.window.localStorage.removeItem(key);
    } catch (_) {}
  }

  @override
  Future<String?> readAccessToken() async => _read(_accessKey);

  @override
  Future<String?> readRefreshToken() async => _read(_refreshKey);

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _write(_accessKey, accessToken);
    _write(_refreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    _remove(_accessKey);
    _remove(_refreshKey);
  }
}

TokenStorageBase createPlatformTokenStorage() => _WebTokenStorage();
