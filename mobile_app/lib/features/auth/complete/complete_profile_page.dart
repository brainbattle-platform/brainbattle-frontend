import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../signup/signup_controller.dart';

class CompleteProfilePage extends StatefulWidget {
  final String email;
  final String otp;
  const CompleteProfilePage({super.key, required this.email, required this.otp});
  static const routeName = '/auth/complete';

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _display = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final SignUpController _vm;
  final _obscure = ValueNotifier<bool>(true);

  static const _pink = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = SignUpController();
  }

  @override
  void dispose() {
    _display.dispose();
    _password.dispose();
    _confirm.dispose();
    _vm.dispose();
    _obscure.dispose();
    super.dispose();
  }

  String? _validateDisplay(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter a display name';
    if (v.trim().length < 2) return 'Too short';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;

    final ok = await _vm.completeRegistration(
      email: widget.email,
      otp: widget.otp,
      password: _password.text,
      displayName: _display.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created!')),
      );
      Navigator.popUntil(context, (r) => r.isFirst); // về đầu, hoặc push vào Home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Register failed')),
      );
    }
  }

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
        title: const Text('Create your profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Hero(
                    tag: 'bb_logo',
                    child: Image(
                      image: AssetImage('assets/brainbattle_logo_light_pink.png'),
                      width: 72, height: 72,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Set your display name & password',
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: _pink,
                      )),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _BBTextField(
                          label: 'Display name',
                          controller: _display,
                          validator: _validateDisplay,
                        ),
                        const SizedBox(height: 14),
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscure,
                          builder: (_, ob, __) {
                            return _BBTextField(
                              label: 'Password',
                              controller: _password,
                              validator: _validatePassword,
                              obscureText: ob,
                              suffixIcon: IconButton(
                                onPressed: () => _obscure.value = !ob,
                                icon: Icon(
                                  ob ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _BBTextField(
                          label: 'Confirm password',
                          controller: _confirm,
                          validator: _validateConfirm,
                          obscureText: true,
                        ),
                      ],
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
                            backgroundColor: _pink,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Create account'),
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
    );
  }
}

class _BBTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _BBTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    // ignore: unused_element_parameter
    this.keyboardType,
    this.suffixIcon,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
