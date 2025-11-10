import 'package:flutter/foundation.dart';

class VerifyOtpController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);

  String? get errorMessage => error.value;

  Future<bool> verify({required String email, required String code}) async {
    loading.value = true;
    error.value = null;
    await Future.delayed(const Duration(milliseconds: 700));
    loading.value = false;

    // TODO: call BE /auth/otp/verify … trả true/false theo response
    return code == '123456' ? true : false; // stub
  }

  Future<bool> resend({required String email}) async {
    loading.value = true;
    error.value = null;
    await Future.delayed(const Duration(milliseconds: 600));
    loading.value = false;

    // TODO: call BE /auth/otp/request …
    return true; // stub
  }

  void dispose() {
    loading.dispose();
    error.dispose();
  }
}
