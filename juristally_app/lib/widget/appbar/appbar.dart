import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

PreferredSizeWidget customAppBar(
    {required BuildContext context,
    Widget? title,
    leadingIcon,
    List<Widget>? actions,
    Color barColor = Colors.white,
    double barHeight = 80,
    bool centerTitle = false,
    bool isLeading = true,
    double iconsize = 20,
    double elevetion = 10}) {
  return AppBar(
    elevation: elevetion,
    centerTitle: centerTitle,
    automaticallyImplyLeading: isLeading,
    title: title,
    toolbarHeight: barHeight,
    backgroundColor: barColor,
    leadingWidth: 80,
    leading: leadingIcon ??
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: iconsize,
          ),
        ),
  );
}
