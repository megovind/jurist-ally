import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/pages/Profile/profile.dart';
import 'package:juristally/pages/SharedWidgets/latter_card.dart';

class DisplayPicture extends StatefulWidget {
  final double radius;
  final String? url, userId;
  final String? name;
  final File? profileFile;
  final double fontSize;
  const DisplayPicture(
      {Key? key, this.radius = 80, this.url, this.profileFile, this.name, this.fontSize = 20, this.userId})
      : super(key: key);
  _DisplayPicture createState() => _DisplayPicture();
}

class _DisplayPicture extends State<DisplayPicture> {
  Color color = Colors.white;

  @override
  void initState() {
    super.initState();
    color = _colors[nextInt(_colors.length - 1) ?? 0];
  }

  static int? nextInt(int max) => 0 + Random().nextInt((max + 1) - 0);
  static const List<Color> _colors = [
    Colors.amber,
    Colors.black26,
    Colors.blue,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.lightGreen,
    Colors.indigoAccent,
    Colors.purple,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.blueGrey
  ];

  @override
  Widget build(BuildContext context) {
    var _url = DecorationImage(
      image: ExactAssetImage('assets/images/white-logo.png'),
      fit: BoxFit.cover,
    );
    if (widget.url != null && widget.profileFile == null) {
      _url = DecorationImage(
        image: CachedNetworkImageProvider(widget.url ?? ""),
        fit: BoxFit.cover,
      );
    } else if (widget.url == null && widget.profileFile != null) {
      _url = DecorationImage(
        image: FileImage(widget.profileFile ?? File("assets/images/white-logo.png")),
        fit: BoxFit.cover,
      );
    } else if (widget.url != null && widget.profileFile != null) {
      _url = DecorationImage(
        image: FileImage(widget.profileFile ?? File("assets/images/white-logo.png")),
        fit: BoxFit.cover,
      );
    }
    return GestureDetector(
      onTap: widget.userId != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(id: widget.userId),
                ),
              )
          : () {},
      child: widget.url != null
          ? CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: widget.radius,
              child: Container(
                decoration:
                    BoxDecoration(image: _url, shape: BoxShape.circle, border: Border.all(color: Colors.black26)),
              ),
            )
          : LetterCard(
              title: widget.name ?? "Juristally", radius: widget.radius, fontSize: widget.fontSize, color: color),
    );
  }
}
