import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/SplashScreen';
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userId')) Get.offAndToNamed("/home");
    final userId = prefs.getString('userId');
    if (userId == null || userId.length == 0) {
      Get.offAndToNamed('/signin-signup');
    } else {
      Get.offAndToNamed('/landing-page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('./assets/images/black-logo.png', height: 224, width: 224),
      ),
    );
  }
}
