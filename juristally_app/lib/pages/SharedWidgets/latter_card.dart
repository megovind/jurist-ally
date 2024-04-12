import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LetterCard extends StatelessWidget {
  final String title;
  final double fontSize, margin, radius;
  final Color color;

  const LetterCard(
      {required this.title,
      this.fontSize = 20,
      this.margin = 10,
      this.radius = 30,
      this.color = Colors.indigo,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstletter = title.substring(0, 1).toUpperCase();

    return CircleAvatar(
      backgroundColor: color,
      radius: radius, // RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        " $firstletter ",
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}
