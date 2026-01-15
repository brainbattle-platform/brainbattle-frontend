import 'package:flutter/foundation.dart';
import 'login_repository.dart';

class LoginController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
  final obscurePassword = ValueNotifier<bool>(true);

  late final LoginRepository _repo;

  LoginController({LoginRepository? repo}) {
    _repo = repo ?? LoginRepository();
  }

  /// Login with username and password
  /// 
  /// Returns true on success, false on error
  /// Error message is available in error.value
  Future<bool> login(String username, String password) async {
    try {
      loading.value = true;
      error.value = null;
      await _repo.login(username, password);
      return true;
    } catch (e) {
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
