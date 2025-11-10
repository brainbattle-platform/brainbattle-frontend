import 'package:flutter/foundation.dart';
import 'forgot_repository.dart';

class ForgotController extends ChangeNotifier {
  ForgotController(this._repo);
  final ForgotRepository _repo;

  bool _loading = false;
  bool get loading => _loading;

  Future<String?> start(String email) async {
    _loading = true; notifyListeners();
    final (ok, msg) = await _repo.start(email);
    _loading = false; notifyListeners();
    return ok ? null : (msg ?? 'Failed to start reset');
  }

  Future<String?> verify({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _loading = true; notifyListeners();
    final err = await _repo.verify(email: email, otp: otp, newPassword: newPassword);
    _loading = false; notifyListeners();
    return err; // null = success
  }
}
