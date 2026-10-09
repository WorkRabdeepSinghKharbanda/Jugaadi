import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';

class PlansScreen extends StatefulWidget {
  /// Which side of the marketplace this upgrade is priced for — owner (job posting, pricier)
  /// or worker (applying, cheaper). Null when opened generically (e.g. an admin viewing their
  /// own plan icon before picking a role); falls back to the profile's default role.
  const PlansScreen({super.key, this.role});

  final String? role;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _checkingOut = false;
  late final Razorpay _razorpay;
  String? _role;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
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
    final api = ApiClient(Config.apiBaseUrl);
    final data = await api.get('/billing/me') as Map<String, dynamic>;
    if (_role == null) {
      final profile = await api.get('/profile/me') as Map<String, dynamic>;
      _role = profile['role'] as String? ?? 'worker';
    }
    return data;
  }

  Future<void> _upgrade() async {
    setState(() => _checkingOut = true);
    try {
      final order = await ApiClient(Config.apiBaseUrl).post('/billing/checkout', {'role': _role}) as Map<String, dynamic>;
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
      // Whoever opened this screen (home, or a plan-limit redirect from apply/post) is right
      // below on the stack — pop back to them instead of leaving the user stranded here.
      Navigator.of(context).pop();
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
      title: widget.role == 'owner' ? 'Plan — Posting jobs' : widget.role == 'worker' ? 'Plan — Finding work' : 'Plan',
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
          final isOwner = _role == 'owner';
          final price = (billing['priceByRole'] as Map<String, dynamic>?)?[_role ?? 'worker'];
          final priceLabel = price == null ? '' : '₹$price/month';
          final benefit = isOwner ? 'Unlimited job posts' : 'Unlimited applications';
          final freeLimitLine = isOwner
              ? '${billing['usageThisMonth']['owner']}/3 job posts this month'
              : '${billing['usageThisMonth']['worker']}/3 applications this month';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeuCard(
                gradientBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isPro ? 'Pro — $priceLabel' : priceLabel, style: AppText.headline),
                    const SizedBox(height: AppSpacing.xs),
                    if (!isPro) Text('7-day free trial, then $priceLabel', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                    const SizedBox(height: AppSpacing.lg),
                    _Benefit(isOwner ? Icons.post_add_rounded : Icons.send_rounded, benefit),
                    if (!isPro) ...[
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(label: 'Upgrade to Pro', icon: Icons.bolt_rounded, loading: _checkingOut, onPressed: _upgrade),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader('Your status'),
              NeuCard(
                variant: NeuVariant.pressed,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isPro ? 'Pro' : 'Free', style: AppText.body.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          if (status == 'trialing' && daysLeft != null)
                            Text(
                              daysLeft > 0 ? 'Trial: $daysLeft day${daysLeft == 1 ? '' : 's'} left' : 'Trial ended',
                              style: AppText.bodySmall.copyWith(color: c.textSecondary),
                            )
                          else if (!isPro)
                            Text(freeLimitLine, style: AppText.bodySmall.copyWith(color: c.textSecondary))
                          else
                            Text(isOwner ? 'Unlimited job posts' : 'Unlimited applications', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                    PillBadge(label: status, tone: isPro ? PillTone.live : PillTone.neutral),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: c.accent, size: 20),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(child: Text(text, style: AppText.body.copyWith(color: c.textPrimary))),
        ],
      ),
    );
  }
}
