import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Lang {
  en,
  hi,
  hinglish;

  static Lang fromString(String? value) {
    for (final l in values) {
      if (l.name == value) return l;
    }
    return Lang.en;
  }
}

const _prefsKey = 'lang';

/// App-wide current language. The profile row (`profiles.lang`) is the source of truth across
/// devices — this just caches it locally so the app boots in the right language before
/// `/profile/me` has a chance to resolve, and lets any screen read/change it without plumbing
/// it through constructors.
class LangController extends ChangeNotifier {
  LangController._(this._lang);

  Lang _lang;
  Lang get lang => _lang;

  static Future<LangController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LangController._(Lang.fromString(prefs.getString(_prefsKey)));
  }

  Future<void> setLang(Lang lang) async {
    if (lang == _lang) return;
    _lang = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.name);
  }

  /// Called once `/profile/me` resolves, so a different device's choice (or a fresh install
  /// before any local cache exists) wins over whatever's cached locally.
  void syncFromProfile(String? profileLang) {
    final resolved = Lang.fromString(profileLang);
    if (resolved != _lang) {
      _lang = resolved;
      notifyListeners();
    }
  }
}

class LangScope extends InheritedNotifier<LangController> {
  const LangScope({
    super.key,
    required LangController controller,
    required super.child,
  }) : super(notifier: controller);

  static Lang of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LangScope>();
    return scope?.notifier?.lang ?? Lang.en;
  }

  static LangController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LangScope>();
    assert(
      scope != null,
      'LangScope.controllerOf() called with no LangScope ancestor',
    );
    return scope!.notifier!;
  }
}

extension LangX on BuildContext {
  Lang get lang => LangScope.of(this);
}
