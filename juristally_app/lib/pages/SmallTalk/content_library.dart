import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/widget/appbar/appbar.dart';

class ContentLibrary extends StatefulWidget {
  ContentLibrary({Key? key}) : super(key: key);

  @override
  _ContentLibraryState createState() => _ContentLibraryState();
}

class _ContentLibraryState extends State<ContentLibrary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context),
      body: Center(
        child: Text("COntent LIbrary"),
      ),
    );
  }
}
