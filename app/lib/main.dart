import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'api_client.dart';
import 'config.dart';
import 'core/i18n/lang.dart';
import 'core/i18n/strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/tokens.dart';
import 'core/widgets/widgets.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/owner/owner_home_screen.dart';
import 'screens/worker/my_jobs_screen.dart';
import 'screens/worker/worker_home_screen.dart';

final _clarityConfig = ClarityConfig(
  projectId: Config.clarityProjectId,
  logLevel: LogLevel.None,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final langController = await LangController.load();
  final themeController = await ThemeController.load();
  if (Config.supabaseUrl.isEmpty || Config.supabaseAnonKey.isEmpty) {
    runApp(
      ClarityWidget(
        app: ThemeScope(
          controller: themeController,
          child: LangScope(
            controller: langController,
            child: const _NotConfiguredApp(),
          ),
        ),
        clarityConfig: _clarityConfig,
      ),
    );
    return;
  }
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  runApp(
    ClarityWidget(
      app: ThemeScope(
        controller: themeController,
        child: LangScope(controller: langController, child: const JugaadiApp()),
      ),
      clarityConfig: _clarityConfig,
    ),
  );
}

class _NotConfiguredApp extends StatelessWidget {
  const _NotConfiguredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeScope.of(context).isDark ? AppTheme.dark : AppTheme.light,
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
    final theme = ThemeScope.of(context);
    return MaterialApp(
      title: 'Jugaadi',
      theme: theme.isDark ? AppTheme.dark : AppTheme.light,
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
      final data =
          await ApiClient(Config.apiBaseUrl).get('/profile/me')
              as Map<String, dynamic>;
      if (mounted) {
        LangScope.controllerOf(
          context,
        ).syncFromProfile(data['lang'] as String?);
      }
      return data;
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
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          final c = context.colors;
          return Scaffold(
            backgroundColor: c.bg,
            body: Center(child: CircularProgressIndicator(color: c.accent)),
          );
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
                    ErrorStrip(
                      'Couldn\'t load your profile. Check your connection.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NeuButton(
                      label: 'Retry',
                      expand: false,
                      onPressed: () => setState(() {
                        _profileFuture = _loadProfile();
                      }),
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
        return profile['role'] == 'owner'
            ? const OwnerHomeScreen()
            : const WorkerTabs();
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
  // Bumped every time a tab is (re)selected so that screen gets a fresh key —
  // otherwise its State (and the one-shot fetch in initState) persists across
  // tab switches and never picks up e.g. a job posted elsewhere while this tab sat idle.
  int _nearbyGen = 0;
  int _myJobsGen = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      WorkerHomeScreen(key: ValueKey(_nearbyGen)),
      MyJobsScreen(key: ValueKey(_myJobsGen)),
    ];
    return Scaffold(
      backgroundColor: context.colors.bg,
      extendBody: true,
      body: pages[_index],
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _index,
        onSelected: (i) => setState(() {
          if (i == 0) _nearbyGen++;
          if (i == 1) _myJobsGen++;
          _index = i;
        }),
        items: [
          GlassNavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: context.tr('tab_nearby'),
          ),
          GlassNavItem(
            icon: Icons.work_outline_rounded,
            activeIcon: Icons.work_rounded,
            label: context.tr('tab_my_jobs'),
          ),
        ],
      ),
    );
  }
}
