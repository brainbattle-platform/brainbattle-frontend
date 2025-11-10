import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'forgot_new_password_page.dart';
import 'package:lottie/lottie.dart';

class ForgotOtpPage extends StatefulWidget {
  const ForgotOtpPage({
    super.key,
    required this.baseUrl,
    required this.email,
  });

  static const routeName = '/auth/forgot/otp';
  final String baseUrl;
  final String email;

  @override
  State<ForgotOtpPage> createState() => _ForgotOtpPageState();
}

class _ForgotOtpPageState extends State<ForgotOtpPage> {
  final _cells = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  static const _pink = Color(0xFFF3B4C3);

  @override
  void dispose() {
    for (final c in _cells) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _cells.map((c) => c.text).join();

  String? _validate() {
    return RegExp(r'^\d{6}$').hasMatch(_otp) ? null : 'Please enter the 6-digit code';
  }

  void _continue() {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      ForgotNewPasswordPage.routeName,
      arguments: {
        'baseUrl': widget.baseUrl,
        'email': widget.email,
        'otp': _otp,
      },
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Hero(
                        tag: 'bb_logo',
                        child: Image(
                          image: AssetImage('assets/brainbattle_logo_light_pink.png'),
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Enter the 6-digit code',
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _pink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We sent a code to ${widget.email}',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),

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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
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
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pink,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
        ],
      ),
    );
  }
}
