import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/locale_provider.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(context, 'English', const Locale('en')),
            _languageTile(context, 'اردو', const Locale('ur')),
            _languageTile(context, 'Français', const Locale('fr')),
            _languageTile(context, 'Español', const Locale('es')),
            _languageTile(context, 'العربية', const Locale('ar')),
          ],
        ),
      );
    },
  );
}

Widget _languageTile(BuildContext context, String title, Locale locale) {
  return ListTile(
    title: Text(title),
    onTap: () {
      LocaleProvider.of(context).setLocale(locale);
      Navigator.pop(context);
    },
  );
}
