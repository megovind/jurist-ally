import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/notification_service.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/AudioChat/audio_chat.dart';
import 'package:juristally/pages/events/upcommings_events.dart';
import 'package:juristally/pages/events/ongoving_events.dart';
import 'package:juristally/pages/LegalLibrary/legal_library_menu_page.dart';
import 'package:juristally/pages/Notification/notificationpage.dart';
import 'package:juristally/pages/Profile/profile.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/pages/SmallTalk/small-talk.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LandingPage extends StatefulWidget {
  static const routename = "/landingpage";
  LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _key = GlobalKey<ScaffoldState>();

  UserModel? _loggedUser;
  int _initialIndex = 0;
  // bool _showModal = false;
  @override
  void initState() {
    super.initState();
    _refreshToken();
    _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _saveDeviceNotificationToken();
    _notigications();
  }

  _refreshToken() async => await Provider.of<AuthProvider>(context, listen: false).refreshToken();

  _notigications() {
    LocalNotificationService.initialize(context);

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];

        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });

    ///forground work
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      // AppleNotification? apple = notification?.apple;
      if (notification != null && !kIsWeb) {
        LocalNotificationService.display(message);
      }
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];

      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }

  _saveDeviceNotificationToken() async {
    final token = FirebaseMessaging.instance.getToken();
    final platform = Platform.operatingSystem;
    try {
      Map<String, dynamic> _formData = {"token": token, "platform": platform};
      await Provider.of<AuthProvider>(context, listen: false).updateRegistrationToken(data: _formData);
    } catch (e) {
      print(e);
    }
  }

  _onBackPressed() {
    bool _close = false;
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text('You Are Going To Exit The Application!'),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () {
                setState(() => _close = false);
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('YES'),
              onPressed: () {
                setState(() => _close = true);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    ).then((value) => _close);
  }

  // PersistentBottomSheetController? _bottomSheetController;

  // void _showOrHide(bool show) {
  //   setState(() => _showModal = show);
  //   if (_showModal) {
  //     _bottomSheetController = _key.currentState!.showBottomSheet(
  //       (_) => Container(
  //         color: Colors.red,
  //         height: MediaQuery.of(context).size.height / 4,
  //         width: MediaQuery.of(context).size.width,
  //         child: Text('This is a BottomSheet'),
  //       ),
  //       backgroundColor: Colors.white,
  //     );
  //   } else {
  //     if (_bottomSheetController != null) _bottomSheetController!.close();
  //     _bottomSheetController = null;
  //   }
  // }

  List<Widget> _widgetOptions = [
    OnGoingEvents(),
    UpcommingEvents(),
    SmallTalk(),
    LegalLibraryPage(),
  ];

  _changeTab(index) => setState(() => _initialIndex = index);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        key: _key,
        primary: false,
        backgroundColor: Colors.white,
        body: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Text(
              "${_loggedUser?.fullName}",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            leading: IconButton(
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(id: _loggedUser?.id))),
                icon: DisplayPicture(
                  radius: 30,
                  name: _loggedUser?.fullName,
                  url: _loggedUser?.avatar,
                  userId: _loggedUser?.id,
                )),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AudioChat()),
                ),
                icon: RotationTransition(
                  turns: AlwaysStoppedAnimation(315 / 360),
                  child: Icon(Icons.send, color: Colors.grey),
                ),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.bell, color: Colors.black26),
                onPressed: () => Navigator.pushNamed(context, NotificationPage.routename),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: (index) => _changeTab(index),
            currentIndex: _initialIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: "Upcoming"),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.waveform), label: "Small Talk"),
              BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/images/library.png')), label: "Legal Library")
            ],
          ),
          body: _widgetOptions.elementAt(_initialIndex),
        ),
      ),
    );
  }
}
