import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

class Replypage extends StatefulWidget {
  static const routename = "/Replypage";
  Replypage({Key? key}) : super(key: key);

  @override
  _ReplypageState createState() => _ReplypageState();
}

class _ReplypageState extends State<Replypage> {
  bool _isSilent = false;
  _showmenubar() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      onSelected: (value) => {print(value)},
      itemBuilder: (context) => [
        PopupMenuItem(value: "1", child: Text("Share")),
        PopupMenuItem(value: "2", child: Text("Podcast")),
        PopupMenuItem(value: "3", child: Text("Restrict")),
        PopupMenuItem(value: "4", child: Text("Designation"))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        title: Text(
          "Manish",
          style: TextStyle(color: Colors.black),
        ),
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          child: DisplayPicture(radius: 20),
        ),
        actions: [
          IconButton(
              onPressed: () => setState(() => _isSilent = !_isSilent),
              icon: Icon(_isSilent ? Icons.mic_off : Icons.mic),
              color: Colors.black),
          _showmenubar(),
        ],
      ),
    );
  }
}
