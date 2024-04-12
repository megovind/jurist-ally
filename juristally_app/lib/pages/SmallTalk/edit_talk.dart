import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/widget/appbar/appbar.dart';

class EditTalk extends StatefulWidget {
  EditTalk({Key? key}) : super(key: key);

  @override
  _EditTalkState createState() => _EditTalkState();
}

class _EditTalkState extends State<EditTalk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context),
      body: Center(
        child: Text("Edit The Audio"),
      ),
    );
  }
}
