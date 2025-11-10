import 'package:flutter/foundation.dart';

class CompleteProfileController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
  final obscurePassword = ValueNotifier<bool>(true);

  String? get errorMessage => error.value;

  Future<bool> setCredentials({
    required String email,
    required String displayName,
    required String password,
  }) async {
    loading.value = true;
    error.value = null;
    await Future.delayed(const Duration(milliseconds: 800));
    loading.value = false;

    // TODO: call BE /auth/complete-profile (set name + password)
    // Trả true nếu OK
    return true; // stub
  }

  void togglePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void dispose() {
    loading.dispose();
    error.dispose();
    obscurePassword.dispose();
  }
}
