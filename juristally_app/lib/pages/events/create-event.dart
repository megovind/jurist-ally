import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/helper/crop_image.dart';
import 'package:juristally/helper/file_upload.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/events/AudioCall/audio_call.dart';
import 'package:juristally/pages/events/search-component.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CreateEvent extends StatefulWidget {
  final String type;
  CreateEvent({Key? key, required this.type}) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  bool _isGuideline = false;
  bool _isPublic = true;
  bool _isLoading = false;
  late EventModel _eventModel;
  DateTime? _eventStartDate;
  final _formKey = GlobalKey<FormState>();
  List<SelectedBottomItems> _participants = [];
  List<SelectedBottomItems> _favourTeam = [];
  List<SelectedBottomItems> _opposeTeam = [];
  List<SelectedBottomItems> _judges = [];
  List<SelectedBottomItems> _invites = [];
  List<SelectedBottomItems> _guests = [];
  Map<String, dynamic> _formData = {};
  File? _propsFile, _bannerImage;

  _showAnackBar(message) => Get.snackbar("", message, snackPosition: SnackPosition.BOTTOM);

  Future<void> _submit() async {
    Size _size = MediaQuery.of(context).size;
    if (!_formKey.currentState!.validate() || _participants.length < 0) {
      _showAnackBar("Please make sure that you have provided all the required details");
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _formData['type'] = widget.type;
      _formData['users'] = [..._participants, ..._invites].map((e) => {"type": e.type, "user": e.user?.id}).toList();
      _formData['commence_date'] = _eventStartDate != null ? _eventStartDate.toString() : DateTime.now().toString();
      _formData['resize'] = {"width": (_size.width * 0.9).floor(), "height": 180};
    });
    try {
      final newEventModel = await Provider.of<EventProvider>(context, listen: false).createEvent(data: _formData);
      setState(() => _eventModel = newEventModel);
    } catch (e) {
      _showAnackBar(e.toString());
    }
    setState(() => _isLoading = false);
  }

  _selectCommenceDate() async {
    DateTime initialDateTime = DateTime.now();
    int initialMinute = initialDateTime.minute;

    if (initialDateTime.minute % 15 != 0) {
      initialMinute = initialDateTime.minute - initialDateTime.minute % 15 + 15;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (conetxt) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black)],
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.white),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day,
                  initialDateTime.hour, initialMinute),
              minimumDate: DateTime.now(),
              maximumDate: DateTime(DateTime.now().year + 2),
              minuteInterval: 15,
              onDateTimeChanged: (DateTime newDateTime) {
                // Do something
                setState(() {
                  _eventStartDate = newDateTime;
                  _formData['commence_date'] = _eventStartDate.toString();
                });
              },
            ),
          ),
          Row(
            children: [
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextButton(
                    onPressed: () {
                      setState(() => _eventStartDate = null);
                      Navigator.pop(context);
                    },
                    child: Text("Now")),
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextButton(onPressed: () => Navigator.pop(context), child: Text("OKAY")),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Create debate"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          TextButton(
            onPressed: _selectCommenceDate,
            child: _eventStartDate != null
                ? Text(DateFormat("dd/MM/yy:hh:mm").format(_eventStartDate ?? DateTime.now()))
                : Text("NOW", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                await _submit();
                if (_eventModel != null) {
                  if (_eventStartDate == null) {
                    await Permission.microphone.request();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return AudioRoom(role: ClientRole.Broadcaster, room: _eventModel);
                      },
                    );
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("${_eventStartDate != null ? 'Schedule' : 'Go On...'}"))
        ],
      ),
      body: Progressbar(
        inAsyncCall: _isLoading,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(primary: _isPublic ? Colors.blue : Colors.black),
                        onPressed: () => setState(() {
                          _isPublic = true;
                          _formData['is_public'] = true;
                        }),
                        icon: Icon(Icons.public),
                        label: Text("Public"),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(primary: !_isPublic ? Colors.blue : Colors.black),
                        onPressed: () => setState(() {
                          _isPublic = false;
                          _formData['is_public'] = false;
                        }),
                        icon: Icon(Icons.lock_outline),
                        label: Text("Private"),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: InputField(
                      hintText: "+ Topic",
                      onSubmit: (value) {
                        setState(() {
                          _formData['event_topic'] = value;
                        });
                      },
                      onChanged: (value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter the topic for ${widget.type}";
                        }
                        return null;
                      },
                    ),
                  ),
                  widget.type == 'moot'
                      ? Container(
                          margin: EdgeInsets.all(10),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                            onPressed: () async {
                              final _file = await selectSingleFile(types: ['pdf']);
                              setState(() {
                                _propsFile = _file;
                                _formData['props'] = _file;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 14),
                              child: _propsFile != null
                                  ? Text(_propsFile!.path.split("/").last)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("Upload Props(.pdf only)")
                                      ],
                                    ),
                            ),
                          ),
                        )
                      : Container(),
                  _titleText(title: widget.type == 'letsTalk' ? "Invite Guests" : "Add People"),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: InputField(
                      isReadOnly: true,
                      onSubmit: (value) {},
                      onChanged: (value) {},
                      onTap: () async {
                        try {
                          List<SelectedBottomItems> backData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchComponent(
                                selectList: _participants,
                                type: widget.type,
                              ),
                            ),
                          );
                          setState(() {
                            _participants = backData;
                            _favourTeam = _participants.where((element) => element.type == 'favour').toList();
                            _opposeTeam = _participants.where((element) => element.type == 'oppose').toList();
                            _judges = _participants.where((element) => element.type == 'judge').toList();
                            _guests = _participants.where((element) => element.type == 'guest').toList();
                          });
                        } catch (e) {
                          print(e);
                          _showAnackBar(e.toString());
                        }
                      },
                      // hintText: "Search...",
                    ),
                  ),
                  _guests.length > 0
                      ? Container(
                          height: 40,
                          margin: EdgeInsets.all(10),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _guests.length,
                              itemBuilder: (context, index) => _nameCard(_guests[index].user!.fullName ?? "")),
                        )
                      : Container(),
                  widget.type == 'moot' ? _titleText(title: "Judges") : Container(),
                  widget.type == 'moot'
                      ? _judges.length > 0
                          ? Container(
                              height: 40,
                              margin: EdgeInsets.all(10),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _judges.length,
                                  itemBuilder: (context, index) => _nameCard(_judges[index].user!.fullName ?? "")),
                            )
                          : Container()
                      : Container(),
                  widget.type != 'letsTalk' ? _titleText(title: "Fovour") : Container(),
                  widget.type != 'letsTalk'
                      ? _favourTeam.length > 0
                          ? Container(
                              height: 40,
                              margin: EdgeInsets.all(10),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _favourTeam.length,
                                  itemBuilder: (context, index) => _nameCard(_favourTeam[index].user!.fullName ?? "")),
                            )
                          : Container()
                      : Container(),
                  widget.type != 'letsTalk' ? _titleText(title: "Oppose") : Container(),
                  widget.type != 'letsTalk'
                      ? _opposeTeam.length > 0
                          ? Container(
                              height: 40,
                              margin: EdgeInsets.all(10),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _opposeTeam.length,
                                  itemBuilder: (context, index) => _nameCard(_opposeTeam[index].user!.fullName ?? "")),
                            )
                          : Container()
                      : Container(),
                  widget.type != 'letsTalk'
                      ? _textButton(
                          text: "Invite +",
                          onClick: () async {
                            try {
                              List<SelectedBottomItems> backData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchComponent(selectList: _invites, type: widget.type, isInvites: true)));
                              setState(() {
                                _invites = backData;
                              });
                            } catch (e) {
                              _showAnackBar(e.toString());
                            }
                          })
                      : Container(),
                  _invites.length > 0
                      ? Container(
                          height: 40,
                          margin: EdgeInsets.all(10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _invites.length,
                            itemBuilder: (context, index) => _nameCard(_invites[index].user!.fullName ?? ""),
                          ),
                        )
                      : Container(),
                  widget.type != "letsTalk"
                      ? Column(
                          children: [
                            _textButton(
                                text: "Guideline  +", onClick: () => setState(() => _isGuideline = !_isGuideline)),
                            _isGuideline
                                ? Container(
                                    margin: EdgeInsets.all(10),
                                    child: InputField(
                                      onSubmit: (value) => setState(() => _formData['guidelines'] = value),
                                      onChanged: (value) => setState(() => _formData['guidelines'] = value),
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return "Guidelines are required to comment the event";
                                        else
                                          return null;
                                      },
                                      hintText: "Giudelines...",
                                      maxLines: 5,
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      : Container(),
                  TextButton(
                    onPressed: () async {
                      final banner = await cropImage(context: context);
                      setState(() {
                        _bannerImage = banner;
                        _formData['banner'] = banner;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width * 0.9, height: 180),
                      decoration: _bannerImage != null
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(image: FileImage(_bannerImage ?? File("path")), fit: BoxFit.cover))
                          : BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                      child: _bannerImage != null ? Text("") : Text("Upload banner"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _titleText({String? title}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(10),
      child: Text(
        title ?? "",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  _textButton({Function? onClick, String? text}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(10),
      child: TextButton(
        onPressed: () => onClick!.call(),
        child: Text(text ?? ""),
      ),
    );
  }

  _nameCard(String name) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(5),
            child: Text(name.split(" ").first),
          ),
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.clear,
          //       color: Colors.red,
          //       size: 15,
          //     ))
        ],
      ),
    );
  }
}
