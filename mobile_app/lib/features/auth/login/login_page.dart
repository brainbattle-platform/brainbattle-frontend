import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'login_controller.dart';
import '../verify/verify_otp_page.dart';
import 'package:lottie/lottie.dart';
import '../forgot/forgot_start_page.dart';
import '../../profile/ui/main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = '/auth/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(); // Changed from _email to _username
  final _password = TextEditingController();
  late final LoginController _vm;

  @override
  void initState() {
    super.initState();
    _vm = LoginController();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;

    final ok = await _vm.login(_username.text.trim(), _password.text);
    if (!mounted) return;

    final err = _vm.error.value;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged in!')));
      // Navigate to MainShell (main app after login) - opens at Feed tab (index 2)
      Navigator.of(context).pushReplacementNamed(
        MainShell.routeName,
        arguments: {'initialIndex': 2},
      );
      return;
    }

    if (err == 'EMAIL_NOT_VERIFIED') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpPage(email: _username.text.trim()),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(err ?? 'Login failed')));
  }

  String? _validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your username';
    // Username validation: 3-20 chars, alphanumeric, dots, underscores, hyphens
    final ok = RegExp(r'^[a-zA-Z0-9._-]{3,20}$').hasMatch(v.trim());
    if (!ok) return 'Username must be 3-20 characters (letters, numbers, ., _, -)';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your password';
    if (v.length < 6) return 'At least 6 characters';
    return null;
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
          'Login',
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
                        'Welcome back!',
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue learning.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      SizedBox(height: vGap + 8),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _BBTextField(
                              label: 'Username',
                              controller: _username,
                              keyboardType: TextInputType.text,
                              validator: _validateUsername,
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: _vm.obscurePassword,
                              builder: (_, obscure, __) {
                                return _BBTextField(
                                  label: 'Password',
                                  controller: _password,
                                  obscureText: obscure,
                                  validator: _validatePassword,
                                  suffixIcon: IconButton(
                                    onPressed: _vm.togglePassword,
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(ForgotStartPage.routeName);

                                },
                                child: const Text('Forgot password?'),
                              ),
                            ),

                            const SizedBox(height: 6),
                            ValueListenableBuilder<String?>(
                              valueListenable: _vm.error,
                              builder: (_, msg, __) {
                                if (msg == null ||
                                    msg == 'EMAIL_NOT_VERIFIED') {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    msg,
                                    style: text.bodySmall?.copyWith(
                                      color: Colors.red[300],
                                    ),
                                  ),
                                );
                              },
                            ),

                            ValueListenableBuilder<bool>(
                              valueListenable: _vm.loading,
                              builder: (_, isLoading, __) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
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
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Login'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: vGap),

                      // Social (tuỳ bạn bật sau)
                      Row(
                        children: [
                          Expanded(
                            child: Container(height: 1, color: Colors.white10),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or continue with',
                              style: text.labelMedium?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: Colors.white10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _SocialButton(
                        label: 'Continue with Google',
                        icon: const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          /* TODO */
                        },
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        label: 'Continue with Facebook',
                        icon: const Icon(
                          Icons.facebook_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          /* TODO */
                        },
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/auth/signup',
                          ),
                          child: const Text("Don't have an account? Sign up"),
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

class _BBTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _BBTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.suffixIcon,
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
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white12,
          side: const BorderSide(color: Colors.white24, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
