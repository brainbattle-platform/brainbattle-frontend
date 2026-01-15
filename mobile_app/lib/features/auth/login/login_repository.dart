import '../../../core/network/auth_api.dart';
import '../../../core/services/token_storage.dart';

class LoginRepository {
  final AuthApi _api;
  final TokenStorage _storage;
  LoginRepository(this._api, this._storage);

  Future<void> login(String email, String password) async {
    final data = await _api.login(email: email, password: password);
    final access = (data['accessToken'] ?? data['access_token']) as String?;
    final refresh = (data['refreshToken'] ?? data['refresh_token']) as String?;
    if (access == null || refresh == null) {
      throw Exception('Invalid response from server');
    }
    await _storage.save(access: access, refresh: refresh);
  }
}
