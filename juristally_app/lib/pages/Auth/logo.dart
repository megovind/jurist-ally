import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 80, horizontal: 10),
      child: Image.asset('assets/images/white-logo.png', height: 224, width: 254),
    );
  }
}
