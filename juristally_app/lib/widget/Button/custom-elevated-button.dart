import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomElevatedButton extends StatelessWidget {
  final Function? onPressed;
  final Widget? child;
  final Color buttonColor;
  final double horizontalPadding, verticalPadding;
  const CustomElevatedButton(
      {required this.onPressed,
      this.child,
      this.buttonColor = Colors.white,
      this.verticalPadding = 10,
      this.horizontalPadding = 15,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(10, 5),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            primary: buttonColor,
            onSurface: buttonColor,
            textStyle: TextStyle(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => onPressed!.call(),
        child: child,
      ),
    );
  }
}
