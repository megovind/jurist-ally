import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PopUpDialogue extends StatefulWidget {
  final Widget child;

  PopUpDialogue({Key? key, required this.child}) : super(key: key);

  @override
  PopUpDialogueState createState() => PopUpDialogueState();
}

class PopUpDialogueState extends State<PopUpDialogue> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    // scaleAnimation.
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: ShapeDecoration(
                color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
