import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Simple JSON-based localization loader.
class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    final String languageCode = locale.languageCode;
    final String path = 'assets/l10n/$languageCode.json';
    try {
      final jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to English if specific locale not found
      if (languageCode != 'en') {
        try {
          final jsonString = await rootBundle.loadString('assets/l10n/en.json');
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
          return true;
        } catch (_) {}
      }
      _strings = <String, String>{};
      return false;
    }
  }

  String t(String key) => _strings[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
