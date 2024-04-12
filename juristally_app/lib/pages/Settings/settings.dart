import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/widget/appbar/appbar.dart';

class SettingsAudioChat extends StatefulWidget {
  SettingsAudioChat({Key? key}) : super(key: key);

  @override
  _SettingsAudioChatState createState() => _SettingsAudioChatState();
}

class _SettingsAudioChatState extends State<SettingsAudioChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(elevetion: 0, context: context, actions: []),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.width * 1,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Notification Tone'),
                Text("Mute Notifications"),
                Text("Blocked Profiles"),
                Text("Media Auto Download On Wifi"),
                Text("Invite a Friend")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
