import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/SmallTalkProvider/smalltalk_provider.dart';
import 'package:juristally/helper/crop_image.dart';
import 'package:juristally/pages/SharedWidgets/audio_player.dart';
import 'package:juristally/pages/SharedWidgets/audio_record_button.dart';
import 'package:juristally/pages/SharedWidgets/background_audio.dart';
import 'package:juristally/pages/SmallTalk/content_library.dart';
import 'package:juristally/pages/SmallTalk/edit_talk.dart';
import 'package:juristally/pages/SmallTalk/rotating_player_disk.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:juristally/widget/appbar/appbar.dart';
import 'package:provider/provider.dart';

class CreateSmallTalk extends StatefulWidget {
  CreateSmallTalk({Key? key}) : super(key: key);

  @override
  _CreateSmallTalkState createState() => _CreateSmallTalkState();
}

class _CreateSmallTalkState extends State<CreateSmallTalk> with TickerProviderStateMixin {
  final _audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  bool _isRecording = false;
  bool _isRecorded = false;
  bool _isBottom = false;
  bool _isLoading = false;
  String _availableTo = "public";
  File? _coverImage;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _bottmSheetController;
  Map<String, dynamic> _formData = {};
  @override
  void initState() {
    super.initState();
    _bottmSheetController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(seconds: 1),
    );
  }

  _submit(String? savedAs) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });
    try {
      setState(() {
        _formData['available_to'] = _availableTo;
        _formData['saved_as'] = savedAs;
      });
      print(_formData);
      await Provider.of<SmallTalkProvider>(context, listen: false).createSmallTalk(data: _formData);
      Navigator.pop(context);
    } catch (error) {
      print(error);
    }
    setState(() {
      _isLoading = false;
    });
  }

  _postSheet() {
    setState(() => _isBottom = true);
    return _scaffoldKey.currentState!.showBottomSheet(
        (context) => StatefulBuilder(
              builder: (context, StateSetter setCustomState) => Container(
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.4,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                primary: _availableTo != 'public' ? Colors.black : Colors.blueAccent),
                            onPressed: () => setCustomState(() => _availableTo = "public"),
                            icon: Icon(Icons.public),
                            label: Text("Public"),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                primary: _availableTo != 'private' ? Colors.black : Colors.blueAccent),
                            onPressed: () => setCustomState(() => _availableTo = "private"),
                            icon: Icon(Icons.lock_outline),
                            label: Text("Private"),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                primary: _availableTo != 'allies' ? Colors.black : Colors.blueAccent),
                            onPressed: () => setCustomState(() => _availableTo = "allies"),
                            icon: Icon(Icons.people),
                            label: Text("Allies"),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: InputField(
                          onSubmit: (value) {
                            setCustomState(() => _formData['title'] = value);
                          },
                          hintText: "Title max 90 words*",
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: InputField(
                          onSubmit: (value) {},
                          hintText: "Tag people",
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: InputField(
                          onSubmit: (value) {
                            setCustomState(() => _formData['tags'] = value);
                          },
                          hintText: "Add hash tags",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        transitionAnimationController: _bottmSheetController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: customAppBar(
        // barColor: Color(0xffE5E5E5),
        context: context,
        isLeading: true,
        elevetion: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentLibrary(),
                    ),
                  ),
              icon: Icon(
                Icons.stream_outlined,
                color: Colors.black,
              ))
        ],
        title: Text(
          "Record",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: !_isBottom
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _controlButtons(icon: Icons.album_rounded, iconSize: 30, onClick: () {}),
                  AudioRecordButton(saveRecoring: (path, txtMsg) {
                    setState(() {
                      _isRecorded = true;
                      _formData['audio_file'] = File(path);
                      _formData['text_msg'] = txtMsg;
                      _isRecording = !_isRecording;
                    });
                  }),
                  _controlButtons(
                      icon: Icons.arrow_forward_ios, iconSize: 40, onClick: () => {if (_isRecorded) _postSheet()})
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomElevatedButton(
                  onPressed: () {
                    setState(() => _isBottom = !_isBottom);
                    _submit("draft");
                  },
                  child: Text("Save As Draft", style: TextStyle(color: Colors.black)),
                ),
                CustomElevatedButton(
                  onPressed: () {
                    setState(() => _isBottom = !_isBottom);
                    _submit("live");
                  },
                  child: Text(
                    "Make it Live",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
      body: SingleChildScrollView(
        child: Progressbar(
          inAsyncCall: _isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.add_box_outlined)),
                      SizedBox(height: 50),
                      _controlButtons(
                          icon: Icons.add_photo_alternate_outlined,
                          onClick: () async {
                            final file = await cropImage(context: context);
                            setState(() => _coverImage = file);
                          }),
                      _controlButtons(
                          icon: Icons.music_note_outlined,
                          onClick: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BackgroundAudio(),
                                ),
                              )),
                      // _controlButtons(icon: _trackSpeed(track: _track), onClick: () => _changeTrackSpeed()),
                      _controlButtons(
                        icon: Icons.tune_outlined,
                        onClick: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTalk(),
                          ),
                        ),
                      ),
                      _controlButtons(
                        icon: Icons.cancel_outlined,
                        onClick: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 50),
                    height: 500,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: RotatingImage(file: _coverImage),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10, top: 120),
                    height: 300,
                    width: 30,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: NewAudioPlayer(audioUrl: _audioUrl),
                    ),
                  ),
                  // playButton(_player);
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _track = "1x";

  _changeTrackSpeed() {
    setState(() {
      if (_track == '1x') {
        _track = "1.5x";
      } else if (_track == '1.5x') {
        _track = "2x";
      } else if (_track == '2x') {
        _track = "1x";
      }
    });
  }

  IconData _trackSpeed({required String track}) {
    var icon = Icons.one_x_mobiledata;
    if (track == "2x") {
      icon = Icons.double_arrow_sharp;
    } else if (track == "1.5x") {
      icon = Icons.trip_origin_outlined;
    }
    return icon;
  }

  _controlButtons({required IconData icon, required Function onClick, double iconSize = 20}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () => onClick(),
        child: Icon(icon, color: Colors.black, size: iconSize),
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shape: CircleBorder(),
          padding: EdgeInsets.all(10),
          primary: Colors.white,
          onPrimary: Colors.black,
        ),
      ),
    );
  }
}
