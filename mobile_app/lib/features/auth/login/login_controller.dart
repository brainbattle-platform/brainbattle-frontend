import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';

/// ViewModel (không phụ thuộc UI), sẵn sàng nối BE sau này
class LoginController with ChangeNotifier {
  final ValueNotifier<bool> loading = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<String?> error = ValueNotifier(null);

  String? get errorMessage => error.value;

  final AuthRepository _repo = AuthRepositoryStub(); // DI sau này

  Future<bool> login(String email, String password) async {
    error.value = null;
    loading.value = true;
    try {
      final ok = await _repo.login(email: email, password: password);
      return ok;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void dispose() {
    loading.dispose();
    obscurePassword.dispose();
    error.dispose();
    super.dispose();
  }
}
