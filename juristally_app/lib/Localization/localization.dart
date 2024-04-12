import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppTranslations {
  Locale locale = Locale("en");
  static Map<dynamic, dynamic>? _localisedValues;

  AppTranslations(Locale locale) {
    this.locale = locale;
    _localisedValues = null;
  }

  static AppTranslations? of(BuildContext context) => Localizations.of<AppTranslations>(context, AppTranslations);
  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations(locale);
    String jsonContent = await rootBundle.loadString("assets/lang/${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  String get currentLanguage => locale.languageCode;
  String translate(String? key) => _localisedValues != null && key != null ? _localisedValues![key] : "....";
}

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  final Locale? newLocale;
  const AppTranslationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) => ["en", "hi"].contains(locale.languageCode);

  @override
  Future<AppTranslations> load(Locale locale) => AppTranslations.load(newLocale ?? locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) => true;
}

String translatedString(BuildContext context, String str) => AppTranslations.of(context)!.translate(str);
