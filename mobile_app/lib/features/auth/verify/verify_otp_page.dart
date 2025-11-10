import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../signup/signup_controller.dart';
import '../complete/complete_profile_page.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});
  static const routeName = '/auth/verify-otp';

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _cells = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  late final SignUpController _vm;
  int _seconds = 60;
  Timer? _timer;

  static const _pink = Color(0xFFF3B4C3);

  @override
  void initState() {
    super.initState();
    _vm = SignUpController();
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _cells) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    _vm.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) t.cancel();
      });
    });
  }

  String get _otp => _cells.map((c) => c.text).join();

  Future<void> _resend() async {
    if (_seconds > 0) return;
    final ok = await _vm.resendOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent')),
      );
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage ?? 'Cannot resend code')),
      );
    }
  }

  void _goNext() {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompleteProfilePage(email: widget.email, otp: _otp),
      ),
    );
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
        title: const Text('Verify code'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
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
                  Text('Enter the 6-digit code',
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: _pink,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    'We sent a code to ${widget.email}',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  // OTP cells
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 46,
                        child: TextField(
                          controller: _cells[i],
                          focusNode: _nodes[i],
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
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
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                            if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // Resend
                  TextButton(
                    onPressed: _seconds > 0 ? null : _resend,
                    child: Text(
                      _seconds > 0 ? 'Resend in $_seconds s' : 'Resend code',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Continue
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Continue'),
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
