import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/verify/verify_otp_controller.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.email,
  });

  static const routeName = '/auth/verify';
  final String email; // truyền từ bước Verify email

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  static const _pinkBrain = Color(0xFFFF8FAB);
  static const _pinkBattle = Color(0xFFF3B4C3);

  late final VerifyOtpController _vm;

  // 6 ô nhập
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  // resend
  static const _cooldown = 60;
  int _left = _cooldown;
  Timer? _timer;

  // tạo code từ 6 ô
  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _vm = VerifyOtpController();
    _startTimer();
    // focus ô đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    _vm.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left == 0) {
        t.cancel();
      } else {
        setState(() => _left--);
      }
    });
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    final code = _code;
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    final ok = await _vm.verify(email: widget.email, code: code);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verified! (stub)')),
      );
      Navigator.pop(context); // hoặc điều hướng sang tạo mật khẩu / home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Invalid code')),
      );
      // clear tất cả để nhập lại
      for (final c in _controllers) c.clear();
      _nodes.first.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_left > 0) return;
    HapticFeedback.selectionClick();
    final ok = await _vm.resend(email: widget.email);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code resent to ${widget.email}')),
      );
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Unable to resend')),
      );
    }
  }

  // Dán 6 số từ clipboard
  Future<void> _handlePaste(int index) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 6) {
      for (var i = 0; i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _nodes[5].requestFocus();
      await Future.delayed(const Duration(milliseconds: 80));
      _submit();
    }
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
            Icon(Icons.verified_rounded, color: _pinkBrain, size: 20),
            SizedBox(width: 8),
            Text(
              'Enter code',
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

                  // Logo + tiêu đề
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
                    'We sent a 6-digit code',
                    textAlign: TextAlign.center,
                    style: t.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: _pinkBattle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check your inbox at\n${_maskEmail(widget.email)}',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: vGap + 10),

                  // 6 ô code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return _OtpBox(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        onChanged: (val) {
                          if (val.isNotEmpty && i < 5) {
                            _nodes[i + 1].requestFocus();
                          }
                          if (val.isNotEmpty && i == 5) {
                            _submit();
                          }
                        },
                        onBackspace: () {
                          if (_controllers[i].text.isEmpty && i > 0) {
                            _nodes[i - 1].requestFocus();
                            _controllers[i - 1].clear();
                          }
                        },
                        onPaste: () => _handlePaste(i),
                      );
                    }),
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

                  // Verify button
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                                        strokeWidth: 2),
                                  )
                                : const Text('Verify'),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // resend
                  Center(
                    child: TextButton(
                      onPressed: _left == 0 ? _resend : null,
                      child: Text(
                        _left == 0
                            ? 'Resend code'
                            : 'Resend in 00:${_left.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color:
                              _left == 0 ? _pinkBattle : Colors.white60,
                          fontWeight:
                              _left == 0 ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
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

  String _maskEmail(String email) {
    // ví dụ: a***@g***.com
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

/// Ô nhập OTP đơn
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.onPaste,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (e) {
          if (e is RawKeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: GestureDetector(
          onLongPress: onPaste, // giữ để dán nhanh
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFF3A3150),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
