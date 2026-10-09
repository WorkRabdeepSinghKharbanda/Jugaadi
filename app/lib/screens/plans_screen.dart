import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _checkingOut = false;
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/billing/me') as Map<String, dynamic>;
    return data;
  }

  Future<void> _upgrade() async {
    setState(() => _checkingOut = true);
    try {
      final order = await ApiClient(Config.apiBaseUrl).post('/billing/checkout') as Map<String, dynamic>;
      _razorpay.open({
        'key': order['keyId'],
        'amount': order['amount'],
        'currency': order['currency'],
        'order_id': order['orderId'],
        'name': 'Jugaadi',
        'description': 'Pro plan — 30 days',
      });
    } on ApiException catch (e) {
      if (e.statusCode == 501 && mounted) {
        showAppToast(context, 'Billing not available yet — ask the admin', tone: ToastTone.info);
      } else if (mounted) {
        showAppToast(context, e.message, tone: ToastTone.error);
      }
      if (mounted) setState(() => _checkingOut = false);
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ApiClient(Config.apiBaseUrl).post('/billing/verify', {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });
      if (!mounted) return;
      showAppToast(context, 'Upgraded to Pro!');
      setState(() => _future = _load());
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) showAppToast(context, response.message ?? 'Payment failed', tone: ToastTone.error);
    if (mounted) setState(() => _checkingOut = false);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (mounted) setState(() => _checkingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: 'Plan',
      scroll: true,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorStrip('${snapshot.error}'),
                const SizedBox(height: AppSpacing.md),
                NeuButton(label: 'Retry', expand: false, onPressed: () => setState(() { _future = _load(); })),
              ],
            );
          }
          final billing = snapshot.data!;
          final isPro = billing['plan'] == 'pro';
          final status = billing['status'] as String;
          final trialEndsAt = billing['trial_ends_at'] as String?;
          final daysLeft = trialEndsAt != null ? DateTime.parse(trialEndsAt).difference(DateTime.now()).inDays : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeuCard(
                gradientBorder: isPro,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(isPro ? 'Pro' : 'Free', style: AppText.headline)),
                        PillBadge(label: status, tone: isPro ? PillTone.live : PillTone.neutral),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (status == 'trialing' && daysLeft != null)
                      Text(
                        daysLeft > 0 ? 'Trial: $daysLeft day${daysLeft == 1 ? '' : 's'} left' : 'Trial ended',
                        style: AppText.body.copyWith(color: c.textSecondary),
                      )
                    else if (!isPro)
                      Text(
                        'Owner: ${billing['usageThisMonth']['owner']}/3 job posts this month\nWorker: ${billing['usageThisMonth']['worker']}/3 applications this month',
                        style: AppText.body.copyWith(color: c.textSecondary),
                      )
                    else
                      Text('Unlimited job posts and applications', style: AppText.body.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!isPro) ...[
                SectionHeader('Pro — ₹199/month'),
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unlimited job posts and applications.', style: AppText.body),
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(label: 'Upgrade to Pro', icon: Icons.bolt_rounded, loading: _checkingOut, onPressed: _upgrade),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
