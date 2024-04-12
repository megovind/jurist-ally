import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:juristally/pages/Auth/signin_signup.dart';
import 'package:juristally/pages/Auth/signin_up_otp.dart';
import 'package:juristally/pages/Auth/update_signup_details.dart';
import 'package:juristally/pages/Landing/landing.dart';
import 'package:juristally/pages/LegalLibrary/articles.dart';
import 'package:juristally/pages/LegalLibrary/bareact.dart';
import 'package:juristally/pages/LegalLibrary/judgement.dart';
import 'package:juristally/pages/LegalLibrary/legal_library_menu_page.dart';
import 'package:juristally/pages/LegalLibrary/legal_update.dart';
import 'package:juristally/pages/Notification/notificationpage.dart';
import 'package:juristally/pages/SmallTalk/small-talk.dart';
import 'package:juristally/pages/events/ongoving_events.dart';
import 'package:juristally/screens/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => SplashScreen()),
    GetPage(name: SignUpSignIn.routeName, page: () => SignUpSignIn()),
    GetPage(name: '/otp', page: () => SignUpInOTP()),
    GetPage(name: '/signup-details', page: () => SignUpUserUpdate()),
    GetPage(name: '/landing-page', page: () => LandingPage()),
    GetPage(name: OnGoingEvents.routeName, page: () => OnGoingEvents()),
    GetPage(name: SmallTalk.routeName, page: () => SmallTalk()),
    // GetPage(name: Debatecompetition.routename, page: () => Debatecompetition()),
    GetPage(name: LandingPage.routename, page: () => LandingPage()),
    // GetPage(name: Replypage.routename, page: () => Replypage()),
    GetPage(name: LegalLibraryPage.routename, page: () => LegalLibraryPage()),
    GetPage(name: BareActPage.routeName, page: () => BareActPage()),
    GetPage(name: Judgements.routename, page: () => Judgements()),
    GetPage(name: LegalUpdates.routename, page: () => LegalUpdates()),
    GetPage(name: Articles.routename, page: () => Articles()),
    GetPage(name: NotificationPage.routename, page: () => NotificationPage()),
  ];
}
