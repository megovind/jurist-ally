import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/widget/appbar/appbar.dart';

class BackgroundAudio extends StatefulWidget {
  BackgroundAudio({Key? key}) : super(key: key);

  @override
  _BackgroundAudioState createState() => _BackgroundAudioState();
}

class _BackgroundAudioState extends State<BackgroundAudio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context),
      body: Center(child: Text("Select a background audio")),
    );
  }
}
