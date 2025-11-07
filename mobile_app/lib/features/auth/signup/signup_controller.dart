import 'package:flutter/foundation.dart';

class SignUpController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
  final obscurePassword = ValueNotifier<bool>(true);

  String? get errorMessage => error.value;

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    loading.value = true;
    error.value = null;
    await Future.delayed(const Duration(milliseconds: 700));
    loading.value = false;
    // Stub: cho pass tất cả
    return true;
  }

  void togglePassword() => obscurePassword.value = !obscurePassword.value;

  void dispose() {
    loading.dispose();
    error.dispose();
    obscurePassword.dispose();
  }
}
