import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

class RotatingImage extends StatefulWidget {
  final File? file;
  final UserModel? user;
  RotatingImage({Key? key, this.file, this.user}) : super(key: key);

  @override
  RotatingImageState createState() => RotatingImageState();
}

class RotatingImageState extends State<RotatingImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 10), animationBehavior: AnimationBehavior.preserve)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              DisplayPicture(
                radius: 250,
                profileFile: widget.file,
                url: widget.user?.avatar,
                name: widget.user?.fullName,
              ),
              Container(alignment: Alignment.center, child: Icon(Icons.circle, size: 30, color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }
}
