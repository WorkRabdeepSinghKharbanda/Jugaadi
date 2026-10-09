import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/location.dart';
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
  late Future<List<dynamic>> _future;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    try {
      final profile = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
      if (mounted) setState(() => _isAdmin = profile['is_admin'] == true);
    } catch (_) {
      // not critical — the admin icon just stays hidden
    }
  }

  Future<List<dynamic>> _load() async {
    final api = ApiClient(Config.apiBaseUrl);
    double lat, lng;
    try {
      final profile = await api.get('/profile/me') as Map<String, dynamic>;
      if (profile['lat'] == null || profile['lng'] == null) throw Exception('no saved location');
      lat = (profile['lat'] as num).toDouble();
      lng = (profile['lng'] as num).toDouble();
    } catch (_) {
      // No saved location yet (shouldn't normally happen post-setup) — fall back to a live GPS fix.
      final position = await getCurrentPositionOrThrow();
      lat = position.latitude;
      lng = position.longitude;
    }
    final data = await api.get('/jobs/nearby', {'lat': lat, 'lng': lng});
    return data as List<dynamic>;
  }

  void _refresh() => setState(() { _future = _load(); });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Nearby jobs'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Admin console',
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
            ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Post a job instead',
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OwnerHomeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bolt_outlined),
            tooltip: 'Plan',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Update location',
            onPressed: () async {
              await editLocation(context);
              _refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: c.accent,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
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
                      NeuButton(label: 'Retry', expand: false, onPressed: _refresh),
                    ],
                  ),
                ),
              );
            }
            final jobs = snapshot.data!;
            if (jobs.isEmpty) return const EmptyState(icon: Icons.search_off_rounded, text: 'No open jobs nearby');
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
              itemCount: jobs.length,
              itemBuilder: (context, i) {
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
                              Text(job['title'] as String, style: AppText.title),
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
