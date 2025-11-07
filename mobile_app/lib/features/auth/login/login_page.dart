import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = '/auth/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final LoginController _vm;

  static const _pinkBrain = Color(0xFFFF8FAB);
  static const _pinkBattle = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = LoginController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;

    final ok = await _vm.login(_email.text.trim(), _password.text);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in (stub)!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Login failed')),
      );
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final ok = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(v.trim());
    if (!ok) return 'Invalid email';
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
    final vGap = media.size.height < 700 ? 12.0 : 16.0; // spacing responsive

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
        title: Row(
          children: const [
            SizedBox(width: 4),
            Icon(Icons.lock_outline_rounded, color: _pinkBrain, size: 20),
            SizedBox(width: 8),
            Text(
              'Login',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: .2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                      image: AssetImage('assets/brainbattle_logo_light_pink.png'),
                      width: 90,
                      height: 90,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: _pinkBattle, 
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue learning.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: vGap + 8),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _BBTextField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
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
                              HapticFeedback.selectionClick();
                              // TODO: Forgot password flow
                            },
                            child: const Text('Forgot password?'),
                          ),
                        ),

                        // Error tổng từ controller (nếu có)
                        ValueListenableBuilder<String?>(
                          valueListenable: _vm.error,
                          builder: (_, msg, __) {
                            if (msg == null) return const SizedBox(height: 8);
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
                            return Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 14,
                                    offset: Offset(0, 6),
                                    color: Color(0x44FB6F92), // pastel glow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _pinkBattle,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Login'),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: Colors.white10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or continue with',
                          style: text.labelMedium?.copyWith(color: Colors.white60),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: Colors.white10)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _SocialButton(
                    label: 'Continue with Google',
                    icon: const Icon(Icons.g_mobiledata_rounded,
                        size: 24, color: Colors.white),
                    background: Colors.white.withOpacity(0.08),
                    onPressed: () {
                      // TODO: OAuth Google
                    },
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Facebook',
                    icon: const Icon(Icons.facebook_rounded, color: Colors.white),
                    background: Colors.white.withOpacity(0.08),
                    onPressed: () {
                      // TODO: OAuth Facebook
                    },
                  ),

                  SizedBox(height: vGap + 10),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/auth/signup'),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? background;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.background,
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
          backgroundColor: background ?? Colors.white12,
          side: const BorderSide(color: Colors.white24, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
