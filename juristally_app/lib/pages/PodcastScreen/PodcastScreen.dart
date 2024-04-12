import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/SharedWidgets/audio_player.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

class PodcastScreen extends StatefulWidget {
  final EventModel? eventModel;
  PodcastScreen({Key? key, this.eventModel}) : super(key: key);

  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  EventModel? _eventModel;
  List<Participant>? _speakers = [];
  @override
  void initState() {
    _eventModel = widget.eventModel;
    _speakers = _eventModel?.participants!
        .where((el) => el.type == 'favour' || el.type == 'oppose' || el.type == 'judge')
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(Util.capitalize(_eventModel?.status ?? ""), style: TextStyle(color: Colors.black)),
        leading:
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(CupertinoIcons.back, color: Colors.black)),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DisplayPicture(
                      radius: 30,
                      url: _eventModel?.moderator?.avatar,
                      name: _eventModel?.moderator?.fullName,
                      userId: _eventModel?.moderator?.id,
                    ),
                    Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${_eventModel?.moderator?.fullName}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(Icons.check_circle, color: Colors.blue, size: 15),
                                )
                              ],
                            ),
                            _eventModel?.moderator?.designation != null
                                ? Text(
                                    "${_eventModel?.moderator?.designation}",
                                    style: TextStyle(fontSize: 12),
                                  )
                                : Container(),
                            _eventModel?.moderator?.connections?.followers != null
                                ? Text(
                                    "Followers - ${_eventModel?.moderator?.connections?.followers?.length}",
                                    style: TextStyle(fontSize: 12),
                                  )
                                : Container(),
                          ],
                        )),
                  ],
                ),
              ],
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      image: _eventModel?.bannerImage != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(_eventModel?.bannerImage ?? ""),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(image: ExactAssetImage('assets/images/white-logo.png')),
                    ),
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.1),
                    height: MediaQuery.of(context).size.width * 0.6,
                    width: MediaQuery.of(context).size.width * 1.5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Speakers",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  _speakers != null && _speakers!.length > 0
                      ? Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _speakers!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final speaker = _speakers![index];
                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child:
                                    DisplayPicture(radius: 20, url: speaker.user?.avatar, name: speaker.user?.fullName),
                              );
                            },
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: Text("There are no speakrs", style: TextStyle(color: Colors.grey)),
                        ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text("${_eventModel?.topic}"),
                  ),
                  _eventModel?.recordingUrl != null
                      ? Container(
                          padding: EdgeInsets.all(10),
                          child: NewAudioPlayer(audioUrl: _eventModel?.recordingUrl),
                        )
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
