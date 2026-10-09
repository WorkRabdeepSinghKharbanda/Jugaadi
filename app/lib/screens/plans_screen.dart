import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/billing/me') as Map<String, dynamic>;
    return data;
  }

  Future<void> _upgrade() async {
    setState(() => _checkingOut = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/billing/checkout');
    } on ApiException catch (e) {
      if (e.statusCode == 501 && mounted) {
        showAppToast(context, 'Billing not available yet — ask the admin', tone: ToastTone.info);
      } else if (mounted) {
        showAppToast(context, '$e', tone: ToastTone.error);
      }
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
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
