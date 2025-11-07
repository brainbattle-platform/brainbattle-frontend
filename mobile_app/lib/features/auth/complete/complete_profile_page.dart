import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/complete/complete_profile_controller.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({
    super.key,
    required this.email,
  });

  static const routeName = '/auth/complete-profile';
  final String email; // truyền từ bước verify OTP

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final CompleteProfileController _vm;

  static const _pinkBrain = Color(0xFFFF8FAB);
  static const _pinkBattle = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = CompleteProfileController();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _password.dispose();
    _confirm.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    if (!_formKey.currentState!.validate()) return;

    final ok = await _vm.setCredentials(
      email: widget.email,
      displayName: _displayName.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! (stub)')),
      );
      // TODO: Điều hướng vào app/home
      Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Unable to complete profile')),
      );
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your display name';
    if (v.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your password';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  // hint strength đơn giản
  String _passwordHint(String v) {
    if (v.isEmpty) return '';
    int score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v)) score++;

    if (score >= 4) return 'Strong password';
    if (score >= 2) return 'Good password';
    return 'Weak password';
  }

  Color _passwordHintColor(String v) {
    final h = _passwordHint(v);
    if (h == 'Strong password') return const Color(0xFF79E0A8);
    if (h == 'Good password') return const Color(0xFFF6D365);
    if (h == 'Weak password') return const Color(0xFFF39C9C);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
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
        title: Row(
          children: const [
            SizedBox(width: 4),
            Icon(Icons.badge_rounded, color: _pinkBrain, size: 20),
            SizedBox(width: 8),
            Text(
              'Set your profile',
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

                  // Header logo + sub
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
                    'Create your profile',
                    textAlign: TextAlign.center,
                    style: t.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: _pinkBattle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set your display name and password for\n${_maskEmail(widget.email)}',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: vGap + 8),

                  // FORM
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _BBTextField(
                          label: 'Display name',
                          controller: _displayName,
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
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
                              onChanged: (_) => setState(() {}),
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

                        // strength hint
                        Builder(
                          builder: (_) {
                            final hint = _passwordHint(_password.text);
                            if (hint.isEmpty) return const SizedBox(height: 8);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  hint,
                                  style: t.bodySmall?.copyWith(
                                    color: _passwordHintColor(_password.text),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),
                        _BBTextField(
                          label: 'Confirm password',
                          controller: _confirm,
                          obscureText: true,
                          validator: _validateConfirm,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // lỗi tổng
                  ValueListenableBuilder<String?>(
                    valueListenable: _vm.error,
                    builder: (_, msg, __) {
                      if (msg == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: t.bodySmall?.copyWith(color: Colors.red[300]),
                        ),
                      );
                    },
                  ),

                  // Nút hoàn tất
                  ValueListenableBuilder<bool>(
                    valueListenable: _vm.loading,
                    builder: (_, isLoading, __) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 14,
                              offset: Offset(0, 6),
                              color: Color(0x44FB6F92),
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
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Create account'),
                          ),
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

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    String mask(String s) {
      if (s.length <= 1) return s;
      return s[0] + '*' * (s.length - 1);
    }
    final name = mask(parts[0]);
    final domParts = parts[1].split('.');
    if (domParts.isEmpty) return '$name@${mask(parts[1])}';
    domParts[0] = mask(domParts[0]);
    return '$name@${domParts.join('.')}';
  }
}

/// TextField tái dùng
class _BBTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const _BBTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
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
