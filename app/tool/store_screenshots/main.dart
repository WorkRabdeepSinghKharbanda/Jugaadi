// Play Store screenshot harness. Lives outside lib/, never ships.
//
// HOW TO RERUN (from the repo's app/ dir; see capture.sh for the whole flow incl. emulator sizes):
//   1. python3 tool/store_screenshots/mock_server.py 8787          # demo backend (needs Pillow)
//   2. flutter run -d emulator-5554 -t tool/store_screenshots/main.dart \
//        --dart-define=API_BASE_URL=http://10.0.2.2:8787 \
//        --dart-define=SUPABASE_URL=https://example.supabase.co \
//        --dart-define=SUPABASE_ANON_KEY=dummy
//   3. tool/store_screenshots/capture.sh <phone|tablet-7|tablet-10>   # shows each screen, taps, screencaps
// The app polls the mock server (GET /__screen) and navigates when the driver POSTs /__screen?n=N.
// Screen numbers: 1 nearby, 2 task detail, 3 post job, 4 owner home, 5 applicants, 6 booked detail,
// 7 profile, 8 plans, 9 my applications, 10 task detail (for the share sheet).
// POST /__fill with a JSON list fills the visible text fields (used for the Post-a-job form).
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jugaadi/api_client.dart';
import 'package:jugaadi/config.dart';
import 'package:jugaadi/core/i18n/lang.dart';
import 'package:jugaadi/core/theme/app_theme.dart';
import 'package:jugaadi/core/theme/theme_controller.dart';
import 'package:jugaadi/main.dart' show WorkerTabs;
import 'package:jugaadi/screens/job_detail_screen.dart';
import 'package:jugaadi/screens/owner/job_applicants_screen.dart';
import 'package:jugaadi/screens/owner/owner_home_screen.dart';
import 'package:jugaadi/screens/owner/post_job_screen.dart';
import 'package:jugaadi/screens/plans_screen.dart';
import 'package:jugaadi/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _nav = GlobalKey<NavigatorState>();
late ThemeController _theme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: deprecated_member_use -- mirrors lib/main.dart, which still uses anonKey
  await Supabase.initialize(url: Config.supabaseUrl, anonKey: Config.supabaseAnonKey);
  final lang = await LangController.load();
  await lang.setLang(Lang.en);
  final theme = await ThemeController.load();
  await theme.setDark(true);
  _theme = theme;
  // ThemeScope: Profile/WorkerTabs read it. Screen numbers >= 20 show the light-theme
  // variant of screen n-20.
  runApp(ThemeScope(
    controller: theme,
    child: LangScope(
      controller: lang,
      child: ListenableBuilder(
        listenable: theme,
        builder: (_, __) => MaterialApp(
          navigatorKey: _nav,
          title: 'Jugaadi',
          theme: theme.isDark ? AppTheme.dark : AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(),
        ),
      ),
    ),
  ));
  _poll();
}

Future<void> _poll() async {
  var seen = -1;
  var seenFill = 0;
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    try {
      final res = await http.get(Uri.parse('${Config.apiBaseUrl}/__screen'));
      final s = jsonDecode(res.body) as Map<String, dynamic>;
      if (s['frev'] != seenFill) {
        seenFill = s['frev'] as int;
        _fill((s['fill'] as List<dynamic>).cast<String>());
      }
      if (s['rev'] == seen) continue;
      seen = s['rev'] as int;
      var n = s['n'] as int;
      await _theme.setDark(n < 20);
      if (n >= 20) n -= 20;
      final screen = await _build(n);
      if (screen != null) {
        _nav.currentState?.pushAndRemoveUntil(PageRouteBuilder<void>(pageBuilder: (_, __, ___) => screen, transitionDuration: Duration.zero), (_) => false);
      }
    } catch (_) {
      // server not up yet — keep polling
    }
  }
}

Future<Map<String, dynamic>> _job(int id) async => await ApiClient(Config.apiBaseUrl).get('/jobs/$id') as Map<String, dynamic>;

Future<Widget?> _build(int n) async => switch (n) {
      1 || 9 => const WorkerTabs(),
      2 || 10 => JobDetailScreen(job: await _job(103), isOwner: false),
      3 => const PostJobScreen(),
      4 => const OwnerHomeScreen(),
      5 => JobApplicantsScreen(job: await _job(201)),
      6 => JobDetailScreen(job: await _job(202), isOwner: true),
      7 => const ProfileScreen(),
      8 => const PlansScreen(role: 'worker'),
      _ => null,
    };

/// Sets the text of every on-screen text field in tree order (avoids flaky IME typing over adb).
void _fill(List<String> values) {
  var i = 0;
  void visit(Element e) {
    if (e.widget is EditableText && i < values.length) (e.widget as EditableText).controller.text = values[i++];
    e.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
}
