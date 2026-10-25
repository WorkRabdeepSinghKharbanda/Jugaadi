import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../main.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: _otpController.text.trim(),
        phone: widget.phone,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootRouter()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: context.tr('enter_otp_title'),
      subtitle: '${context.tr('otp_sent_to')} ${widget.phone}',
      scroll: true,
      resizeForKeyboard: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuTextField(
            label: context.tr('otp_code'),
            controller: _otpController,
            hint: '······',
            icon: Icons.password_rounded,
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ...[
            ErrorStrip(_error!),
            const SizedBox(height: AppSpacing.lg),
          ],
          NeuButton(
            label: context.tr('verify'),
            icon: Icons.check_rounded,
            loading: _loading,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}
