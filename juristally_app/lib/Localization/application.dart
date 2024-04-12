import 'dart:ui';

class Application {
  static final Application _application = Application._internal();

  factory Application() => _application;

  Application._internal();

  final List<String> supportedLanguages = [
    "English",
    "Hindi",
  ];

  final List<Locale> supportedLanguagesCodes = [
    Locale("en", "UK"),
    Locale("hi", "IN"),
  ];

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) => Locale(language.languageCode, language.countryCode));

  //function to be invoked when changing the language
  LocaleChangeCallback? onLocaleChanged;
}

Application application = Application();

typedef void LocaleChangeCallback(Locale locale);
