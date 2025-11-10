import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'forgot_controller.dart';
import 'forgot_repository.dart';
import 'forgot_otp_page.dart';
import 'package:lottie/lottie.dart';

class ForgotStartPage extends StatefulWidget {
  const ForgotStartPage({super.key, required this.baseUrl});
  static const routeName = '/auth/forgot';
  final String baseUrl;

  @override
  State<ForgotStartPage> createState() => _ForgotStartPageState();
}

class _ForgotStartPageState extends State<ForgotStartPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  late final ForgotController _vm;

  @override
  void initState() {
    super.initState();
    _vm = ForgotController(ForgotRepository(baseUrl: widget.baseUrl));
  }

  @override
  void dispose() {
    _email.dispose();
    _vm.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final ok = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(v.trim());
    if (!ok) return 'Invalid email';
    return null;
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;
    final err = await _vm.start(_email.text.trim());
    if (!mounted) return;

    if (err == null) {
      Navigator.pushReplacementNamed(
        context,
        ForgotOtpPage.routeName,
        arguments: {'baseUrl': widget.baseUrl, 'email': _email.text.trim()},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final vGap = media.size.height < 700 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot password',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: .2,
            color: Colors.white,
          ),
        ),
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: vGap),
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 72,
                        color: Color(0xFFF3B4C3),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Forgot your password?',
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter your email. We will send a one-time code (OTP) to reset your password.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      SizedBox(height: vGap + 8),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _email,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF3A3150),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white10,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                        animation: _vm,
                        builder: (_, __) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _vm.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3B4C3),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _vm.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Send OTP'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Login'),
                        ),
                      ),
                    ],
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
