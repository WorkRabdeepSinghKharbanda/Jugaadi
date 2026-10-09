import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'api_client.dart';
import 'config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'core/widgets/widgets.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/owner/owner_home_screen.dart';
import 'screens/worker/my_jobs_screen.dart';
import 'screens/worker/worker_home_screen.dart';

final _clarityConfig = ClarityConfig(projectId: Config.clarityProjectId, logLevel: LogLevel.None);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Config.supabaseUrl.isEmpty || Config.supabaseAnonKey.isEmpty) {
    runApp(ClarityWidget(app: const _NotConfiguredApp(), clarityConfig: _clarityConfig));
    return;
  }
  await Supabase.initialize(url: Config.supabaseUrl, anonKey: Config.supabaseAnonKey);
  runApp(ClarityWidget(app: const JugaadiApp(), clarityConfig: _clarityConfig));
}

class _NotConfiguredApp extends StatelessWidget {
  const _NotConfiguredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: AppScaffold(
        body: Center(
          child: Text(
            'Supabase isn\'t configured yet.\n\n'
            'Run with:\n'
            '--dart-define=SUPABASE_URL=...\n'
            '--dart-define=SUPABASE_ANON_KEY=...\n'
            '--dart-define=API_BASE_URL=...',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
        ),
      ),
    );
  }
}

class JugaadiApp extends StatelessWidget {
  const JugaadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jugaadi',
      theme: AppTheme.dark,
      home: const RootRouter(),
    );
  }
}

/// Decides what to show on launch: sign-in, role pick, or role-based home.
class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    if (Supabase.instance.client.auth.currentSession == null) return null;
    try {
      final data = await ApiClient(Config.apiBaseUrl).get('/profile/me');
      return data as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return {};
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentSession == null) {
      return const PhoneAuthScreen();
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
          final c = context.colors;
          return Scaffold(backgroundColor: c.bg, body: Center(child: CircularProgressIndicator(color: c.accent)));
        }
        if (snapshot.hasError) {
          final c = context.colors;
          return Scaffold(
            backgroundColor: c.bg,
            body: Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ErrorStrip('Couldn\'t load your profile. Check your connection.'),
                    const SizedBox(height: AppSpacing.md),
                    NeuButton(
                      label: 'Retry',
                      expand: false,
                      onPressed: () => setState(() => _profileFuture = _loadProfile()),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final profile = snapshot.data;
        if (profile == null || profile.isEmpty) return const RoleSelectScreen();
        if (profile['is_admin'] == true) return const AdminHomeScreen();
        return profile['role'] == 'owner' ? const OwnerHomeScreen() : const WorkerTabs();
      },
    );
  }
}

class WorkerTabs extends StatefulWidget {
  const WorkerTabs({super.key});

  @override
  State<WorkerTabs> createState() => _WorkerTabsState();
}

class _WorkerTabsState extends State<WorkerTabs> {
  int _index = 0;
  // Bumped every time "My jobs" is selected so MyJobsScreen gets a fresh key —
  // otherwise its State (and the one-shot fetch in initState) persists across
  // tab switches and never picks up a job applied to from the other tab.
  int _myJobsGen = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const WorkerHomeScreen(), MyJobsScreen(key: ValueKey(_myJobsGen))];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          if (i == 1) _myJobsGen++;
          _index = i;
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Nearby'),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), label: 'My jobs'),
        ],
      ),
    );
  }
}
