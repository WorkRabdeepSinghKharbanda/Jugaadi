import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  late Future<(List<dynamic>, List<dynamic>)> _future;
  late int _hiredCount = widget.job['hired_count'] as int? ?? 0;
  late final int _workersNeeded = widget.job['workers_needed'] as int? ?? 1;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<dynamic>, List<dynamic>)> _load() async {
    final api = ApiClient(Config.apiBaseUrl);
    final results = await Future.wait([
      api.get('/jobs/${widget.job['id']}/applicants'),
      api.get('/jobs/${widget.job['id']}'),
    ]);
    final applicants = results[0] as List<dynamic>;
    final hiredWorkers = (results[1] as Map<String, dynamic>)['hired_workers'] as List<dynamic>? ?? const [];
    return (applicants, hiredWorkers);
  }

  Future<void> _hire(String workerId) async {
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${widget.job['id']}/hire/$workerId');
      if (!mounted) return;
      showAppToast(context, 'Worker hired');
      setState(() {
        _hiredCount++;
        _future = _load();
      });
    } catch (e) {
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final full = _hiredCount >= _workersNeeded;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: _workersNeeded > 1 ? 'Applicants ($_hiredCount/$_workersNeeded hired)' : 'Applicants',
      fullBleed: true,
      body: Column(
        children: [
          if (full)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, 0),
              child: ErrorStrip('All slots filled — this job no longer appears in Nearby.', warning: true),
            ),
          Expanded(
            child: RefreshIndicator(
              color: c.accent,
              onRefresh: () async => setState(() {
                _future = _load();
              }),
              child: FutureBuilder<(List<dynamic>, List<dynamic>)>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(child: CircularProgressIndicator(color: c.accent));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: AppSpacing.screen,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ErrorStrip('${snapshot.error}'),
                            const SizedBox(height: AppSpacing.md),
                            NeuButton(
                              label: 'Retry',
                              expand: false,
                              onPressed: () => setState(() {
                                _future = _load();
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final (applicants, hiredWorkers) = snapshot.data!;
                  if (applicants.isEmpty && hiredWorkers.isEmpty) {
                    return const EmptyState(icon: Icons.people_outline_rounded, text: 'No applicants yet');
                  }
                  final hiredSection = hiredWorkers.isNotEmpty ? hiredWorkers.length + 1 : 0;
                  final pendingSection = applicants.isNotEmpty ? 1 : 0;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
                    itemCount: hiredSection + pendingSection + applicants.length,
                    itemBuilder: (context, i) {
                      if (i < hiredSection) {
                        if (i == 0) return SectionHeader('Hired (${hiredWorkers.length})');
                        final w = hiredWorkers[i - 1] as Map<String, dynamic>;
                        final wVerified = w['is_verified'] == true;
                        final wSkills = (w['worker_skills'] as List<dynamic>?)?.map((s) => s['skill'] as String).toList() ?? const [];
                        final wBio = w['bio'] as String?;
                        final wCity = w['city'] as String?;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: NeuCard(
                            gradientBorder: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: c.live),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(w['full_name'] as String? ?? '-', style: AppText.title),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.phone_rounded, size: 14, color: c.textTertiary),
                                              const SizedBox(width: 4),
                                              Text(w['phone'] as String? ?? '-', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (wVerified) const PillBadge.verified(),
                                  ],
                                ),
                                if (wCity != null && wCity.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Icon(Icons.location_city_rounded, size: 16, color: c.textTertiary),
                                      const SizedBox(width: 4),
                                      Text(wCity, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                                    ],
                                  ),
                                ],
                                if (wBio != null && wBio.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(wBio, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                                ],
                                if (wSkills.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.xs,
                                    runSpacing: AppSpacing.xs,
                                    children: wSkills.map((s) => PillBadge(label: s)).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                      var i2 = i - hiredSection;
                      if (pendingSection == 1) {
                        if (i2 == 0) return SectionHeader('Pending (${applicants.length})');
                        i2 -= 1;
                      }
                      final a = applicants[i2] as Map<String, dynamic>;
                      final worker = a['worker'] as Map<String, dynamic>?;
                      final verified = worker?['is_verified'] == true;
                      final skills = (worker?['worker_skills'] as List<dynamic>?)?.map((s) => s['skill'] as String).toList() ?? const [];
                      final bio = worker?['bio'] as String?;
                      final city = worker?['city'] as String?;
                      final phone = worker?['phone'] as String?;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: NeuCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: c.surfaceHigh,
                                    child: Icon(Icons.person_rounded, color: c.textSecondary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(worker?['full_name'] as String? ?? 'Unknown', style: AppText.title),
                                        const SizedBox(height: 4),
                                        verified ? const PillBadge.verified() : PillBadge(label: 'Pending verification'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (phone != null && phone.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Icon(Icons.phone_rounded, size: 16, color: c.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(phone, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                                  ],
                                ),
                              ],
                              if (city != null && city.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Icon(Icons.location_city_rounded, size: 16, color: c.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(city, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                                  ],
                                ),
                              ],
                              if (bio != null && bio.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(bio, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                              ],
                              if (skills.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: skills.map((s) => PillBadge(label: s)).toList(),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              NeuButton(
                                label: 'Hire',
                                height: 44,
                                onPressed: full ? null : () => _hire(a['worker_id'] as String),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
