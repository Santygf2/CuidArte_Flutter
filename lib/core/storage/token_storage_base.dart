abstract class TokenStorageBase {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens(String accessToken, String refreshToken);

  Future<void> clear();
}
