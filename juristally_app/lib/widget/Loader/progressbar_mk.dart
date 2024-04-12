import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Progressbar extends StatelessWidget {
  final Widget? child;
  final bool? inAsyncCall;
  final double opacity;
  final Color color;
  final Animation<Color>? valueColor;

  Progressbar({
    Key? key,
    @required this.child,
    @required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child ?? Container());
    if (inAsyncCall ?? false) {
      final modal = new Stack(
        children: [
          new Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          new Center(
            child: new CircularProgressIndicator(
              valueColor: valueColor,
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}
