import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'signup_controller.dart';
import '../verify/verify_otp_page.dart';
import 'package:lottie/lottie.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  static const routeName = '/auth/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  late final SignUpController _vm;

  // ignore: unused_field
  static const _pinkBrain = Color(0xFFFF8FAB);
  static const _pinkBattle = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = SignUpController();
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
    final email = _email.text.trim();

    final ok = await _vm.startRegistration(email);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification code sent!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerifyOtpPage(email: email)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Failed to send code')),
      );
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
        title: const _HeaderTitle(
          icon: Icons.mark_email_unread_rounded,
          text: 'Verify email',
        ),
      ),
      body: Stack(
        children: [
          // 🔹 Lottie background layer
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // nhẹ để không làm rối UI
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
                      const Hero(
                        tag: 'bb_logo',
                        child: Image(
                          image: AssetImage(
                            'assets/brainbattle_logo_light_pink.png',
                          ),
                          width: 90,
                          height: 90,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Verify your email',
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: _pinkBattle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We will send a 6-digit code to your inbox.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: vGap + 8),

                      Form(
                        key: _formKey,
                        child: _BBTextField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                      ),
                      const SizedBox(height: 18),

                      ValueListenableBuilder<bool>(
                        valueListenable: _vm.loading,
                        builder: (_, isLoading, __) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pinkBattle,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: const Color(0x44FB6F92),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Send code'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 26),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/auth/login',
                          ),
                          child: const Text('Already have an account? Login'),
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

class _HeaderTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Icon(icon, color: Color(0xFFFF8FAB), size: 20),
        const SizedBox(width: 8),
        const Text(
          'Verify email',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: .2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BBTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _BBTextField({
    required this.label,
    required this.controller,
    this.validator,
    // ignore: unused_element_parameter
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF3A3150),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(14),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
