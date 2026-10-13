import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
import '../../core/location.dart';
import '../../core/paginated_list.dart';
import '../../core/theme/tokens.dart';
import '../../core/update_location.dart';
import '../../core/widgets/widgets.dart';
import '../admin/admin_home_screen.dart';
import '../job_detail_screen.dart';
import '../owner/owner_home_screen.dart';
import '../plans_screen.dart';
import '../profile_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  late Future<void> _future;
  late final _pager = PaginatedList<dynamic>(fetchPage: _fetchPage);
  final _scrollController = ScrollController();
  bool _isAdmin = false;
  double? _lat, _lng;

  @override
  void initState() {
    super.initState();
    _pager.attachScrollController(_scrollController, () => setState(() {}));
    _future = _loadFirst();
    _checkAdmin();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAdmin() async {
    try {
      final profile = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
      if (mounted) setState(() => _isAdmin = profile['is_admin'] == true);
    } catch (_) {
      // not critical — the admin icon just stays hidden
    }
  }

  Future<List<dynamic>> _fetchPage(int offset, int limit) async {
    final data = await ApiClient(Config.apiBaseUrl).get('/jobs/nearby', {'lat': _lat, 'lng': _lng, 'limit': limit, 'offset': offset});
    return data as List<dynamic>;
  }

  Future<void> _loadFirst() async {
    final api = ApiClient(Config.apiBaseUrl);
    try {
      final profile = await api.get('/profile/me') as Map<String, dynamic>;
      if (profile['lat'] == null || profile['lng'] == null) throw Exception('no saved location');
      _lat = (profile['lat'] as num).toDouble();
      _lng = (profile['lng'] as num).toDouble();
    } catch (_) {
      // No saved location yet (shouldn't normally happen post-setup) — fall back to a live GPS fix.
      final position = await getCurrentPositionOrThrow();
      _lat = position.latitude;
      _lng = position.longitude;
    }
    await _pager.loadFirstPage();
  }

  void _refresh() => setState(() { _future = _loadFirst(); });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: context.tr('nearby_jobs_title'),
      fullBleed: true,
      actions: [
        if (_isAdmin)
          NeuIconButton(
            icon: Icons.admin_panel_settings_outlined,
            semanticLabel: context.tr('admin_console'),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
          ),
        NeuIconButton(
          icon: Icons.swap_horiz_rounded,
          semanticLabel: context.tr('post_job_instead'),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OwnerHomeScreen())),
        ),
        NeuIconButton(
          icon: Icons.bolt_outlined,
          semanticLabel: context.tr('plan'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansScreen(role: 'worker'))),
        ),
        NeuIconButton(
          icon: Icons.location_on_outlined,
          semanticLabel: context.tr('update_location'),
          onPressed: () async {
            await editLocation(context);
            _refresh();
          },
        ),
        NeuIconButton(
          icon: Icons.person_outline_rounded,
          semanticLabel: context.tr('profile_title'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
      ],
      body: RefreshIndicator(
        color: c.accent,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<void>(
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
                      ErrorStrip(errorMessage(context, snapshot.error!)),
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(label: context.tr('retry'), expand: false, onPressed: _refresh),
                    ],
                  ),
                ),
              );
            }
            final jobs = _pager.items;
            if (jobs.isEmpty) return EmptyState(icon: Icons.search_off_rounded, text: context.tr('no_open_jobs_nearby'));
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
              itemCount: jobs.length + (_pager.hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == jobs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator(color: c.accent)),
                  );
                }
                final job = jobs[i] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NeuCard(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job, isOwner: false)),
                      );
                      _refresh();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(job['title'] as String, style: AppText.title)),
                                  if (job['my_application_status'] != null) PillBadge.status(job['my_application_status'] as String),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(job['skill_needed'] as String, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                              const SizedBox(height: 4),
                              Text('${job['start_date']} → ${job['end_date']}', style: AppText.bodySmall.copyWith(color: c.textTertiary)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: c.textTertiary),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
