import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // default

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale(); // load saved locale on app start
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode); // save selection
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  static LocaleProvider of(BuildContext context) =>
      Provider.of<LocaleProvider>(context, listen: false);
}
