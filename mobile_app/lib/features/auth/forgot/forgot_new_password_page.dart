import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'forgot_repository.dart';
import 'forgot_controller.dart';
import 'package:lottie/lottie.dart';

class ForgotNewPasswordPage extends StatefulWidget {
  const ForgotNewPasswordPage({
    super.key,
    required this.baseUrl,
    required this.email,
    required this.otp,
  });

  static const routeName = '/auth/forgot/new-password';
  final String baseUrl;
  final String email;
  final String otp;

  @override
  State<ForgotNewPasswordPage> createState() => _ForgotNewPasswordPageState();
}

class _ForgotNewPasswordPageState extends State<ForgotNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  late final ForgotController _vm;
  final _ob1 = ValueNotifier<bool>(true);
  final _ob2 = ValueNotifier<bool>(true);

  static const _pink = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = ForgotController(ForgotRepository(baseUrl: widget.baseUrl));
  }

  @override
  void dispose() {
    _pass.dispose();
    _pass2.dispose();
    _vm.dispose();
    _ob1.dispose();
    _ob2.dispose();
    super.dispose();
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Please enter new password';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validatePass2(String? v) {
    if (v != _pass.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;

    final err = await _vm.verify(
      email: widget.email,
      otp: widget.otp,
      newPassword: _pass.text,
    );
    if (!mounted) return;

    if (err == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Password updated'),
          content: const Text('You can now log in with your new password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  InputDecoration _deco(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF3A3150),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffix,
      );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New password'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Lottie.asset(
                'assets/animations/animation_point.json',
                fit: BoxFit.cover,
                repeat: true,
                frameRate: FrameRate.max,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.lock_rounded, size: 72, color: _pink),
                        const SizedBox(height: 14),
                        Text(
                          'Set a new password',
                          textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _pink,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password + eye
                        ValueListenableBuilder<bool>(
                          valueListenable: _ob1,
                          builder: (_, ob, __) {
                            return TextFormField(
                              controller: _pass,
                              validator: _validatePass,
                              obscureText: ob,
                              style: const TextStyle(color: Colors.white),
                              decoration: _deco(
                                'New password',
                                suffix: IconButton(
                                  onPressed: () => _ob1.value = !ob,
                                  icon: Icon(
                                    ob ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirm + eye
                        ValueListenableBuilder<bool>(
                          valueListenable: _ob2,
                          builder: (_, ob, __) {
                            return TextFormField(
                              controller: _pass2,
                              validator: _validatePass2,
                              obscureText: ob,
                              style: const TextStyle(color: Colors.white),
                              decoration: _deco(
                                'Confirm new password',
                                suffix: IconButton(
                                  onPressed: () => _ob2.value = !ob,
                                  icon: Icon(
                                    ob ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        AnimatedBuilder(
                          animation: _vm,
                          builder: (_, __) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _vm.loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _pink,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _vm.loading
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Reset password'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
