import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:juristally/Localization/application.dart';
import 'package:juristally/Localization/localization.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/Providers/LegalProvider/legal_library.dart';
import 'package:juristally/Providers/SmallTalkProvider/smalltalk_provider.dart';
import 'package:juristally/Routes/app_routes.dart';

import 'package:juristally/pages/Auth/signin_signup.dart';
import 'package:juristally/pages/Landing/landing.dart';

import 'package:juristally/screens/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> handleBackgroundNotification(RemoteMessage remoteMessage) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => LegalLibraryProvider()),
        ChangeNotifierProvider(create: (_) => SmallTalkProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.
  late AppTranslationsDelegate _newLocaleDelegate = AppTranslationsDelegate(newLocale: Locale("en"));

  Future<bool>? tryAuth;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;
    tryAuth = Provider.of<AuthProvider>(context, listen: false).tryAutoSigin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) => ValueListenableBuilder<ThemeVariation>(
        valueListenable: themeNotifier,
        builder: (context, value, child) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Juristally',
            theme: ThemeData(
              appBarTheme: AppBarTheme(color: const Color(0xFFFFFFFF)),
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              primarySwatch: value.color,
              brightness: value.brightness,
              unselectedWidgetColor: Colors.black,
            ),
            localizationsDelegates: [
              _newLocaleDelegate,
              const AppTranslationsDelegate(),
              //provides localised strings
              GlobalMaterialLocalizations.delegate,
              //provides RTL support
              GlobalWidgetsLocalizations.delegate,
            ],
            home: FutureBuilder<bool>(
              future: tryAuth,
              builder: (ctx, snapshot) {
                print(snapshot.connectionState);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SplashScreen();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (auth.isLoggedIn) {
                    return LandingPage();
                  } else {
                    return SignUpSignIn();
                  }
                }
                return SplashScreen();
              },
            ),
            initialRoute: '/',
            getPages: AppRoutes.routes),
      ),
    );
  }

  void onLocaleChange(Locale locale) => setState(() => _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale));
}

var themeNotifier = ValueNotifier<ThemeVariation>(
  const ThemeVariation(Colors.blue, Brightness.light),
);

class ThemeVariation {
  const ThemeVariation(this.color, this.brightness);
  final MaterialColor color;
  final Brightness brightness;
}

const primaryColor = const Color(0xFF000000);

ThemeData buildTheme() {
  final ThemeData base = ThemeData();
  return base.copyWith(
    hintColor: Colors.white,
  );
}
