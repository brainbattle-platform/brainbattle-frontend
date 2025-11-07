// lib/features/auth/login/login_controller.dart (rút gọn ý tưởng)
import 'package:flutter/foundation.dart';
import '../../../core/network/auth_api.dart';
import '../../../core/services/token_storage.dart';
import 'login_repository.dart';

class LoginController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
  final obscurePassword = ValueNotifier<bool>(true);

  late final LoginRepository _repo;

  LoginController() {
    _repo = LoginRepository(AuthApi(), TokenStorage());
  }

  Future<bool> login(String email, String password) async {
    try {
      loading.value = true;
      error.value = null;
      await _repo.login(email, password);
      return true;
    } catch (e) {
      // Đừng để toString() ra “Exception: …”
      error.value = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Login failed';
      return false;
    } finally {
      loading.value = false;
    }
  }

  void togglePassword() => obscurePassword.value = !obscurePassword.value;
  void dispose() {
    loading.dispose();
    error.dispose();
    obscurePassword.dispose();
  }
}
