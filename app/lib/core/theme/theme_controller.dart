import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokens.dart';

const _prefsKey = 'theme';

/// App-wide theme choice. Dark is the default (DESIGN language); light is opt-in from
/// Profile. Device-local only — unlike language, a theme is a per-device preference.
class ThemeController extends ChangeNotifier {
  ThemeController._(this._isDark);

  bool _isDark;
  bool get isDark => _isDark;
  AppColors get colors => _isDark ? AppColors.dark : AppColors.light;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeController._(prefs.getString(_prefsKey) != 'light');
  }

  Future<void> setDark(bool dark) async {
    if (dark == _isDark) return;
    _isDark = dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, dark ? 'dark' : 'light');
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope.of() called with no ThemeScope ancestor');
    return scope!.notifier!;
  }
}
