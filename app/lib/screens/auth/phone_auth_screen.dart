import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'otp_verify_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  String get _e164Phone {
    final raw = _phoneController.text.trim();
    return raw.startsWith('+') ? raw : '+91$raw';
  }

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: _e164Phone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone: _e164Phone)),
      );
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scroll: true,
      resizeForKeyboard: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jugaadi', style: AppText.display.copyWith(color: context.colors.accent)),
            const SizedBox(height: AppSpacing.sm),
            Text('Find help, or find work — same day.', style: AppText.body.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: AppSpacing.xxl),
            NeuTextField(
              label: 'Phone number',
              controller: _phoneController,
              hint: '98765 43210',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[
              ErrorStrip(_error!),
              const SizedBox(height: AppSpacing.lg),
            ],
            NeuButton(label: 'Send OTP', icon: Icons.arrow_forward_rounded, loading: _loading, onPressed: _sendOtp),
          ],
        ),
      ),
    );
  }
}
