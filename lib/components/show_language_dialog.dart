import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/locale_provider.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final currentLocale = LocaleProvider.of(context).locale;
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Select Language",
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(context, 'English', const Locale('en'), currentLocale),
            _languageTile(context, 'اردو', const Locale('ur'), currentLocale),
            _languageTile(context, 'Français', const Locale('fr'), currentLocale),
            _languageTile(context, 'Español', const Locale('es'), currentLocale),
            _languageTile(context, 'العربية', const Locale('ar'), currentLocale),
          ],
        ),
      );
    },
  );
}

Widget _languageTile(BuildContext context, String title, Locale locale, Locale currentLocale) {
  bool isSelected = locale.languageCode == currentLocale.languageCode;

  return ListTile(
    title: Text(title),
    trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
    onTap: () {
      LocaleProvider.of(context).setLocale(locale);
      Navigator.pop(context);
    },
  );
}
