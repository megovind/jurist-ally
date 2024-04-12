import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/events/AudioCall/audio_call.dart';
import 'package:juristally/pages/PodcastScreen/PodcastScreen.dart';
import 'package:juristally/pages/Profile/conversation-reply.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DebateMootCard extends StatelessWidget {
  final EventModel eventModel;
  final Function? likeEvent, commentEvent;
  const DebateMootCard({Key? key, required this.eventModel, this.likeEvent, this.commentEvent}) : super(key: key);

  bool _checkIfBroadCaster({required String? loggedInUserId, required String? moderatorId}) {
    return loggedInUserId == moderatorId;
  }

  bool _checkIfLiked({required String? loggedInUserId, required List<UserModel>? likes}) {
    return likes!.indexWhere((el) => el.id == loggedInUserId) > -1;
  }

  _showmenubar({String? moderatorId, String? loggedInUserId}) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) {
        print(moderatorId);
        print(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: "1", child: Text("Share")),
        PopupMenuItem(value: "3", child: Text("Restrict entry")),
        PopupMenuItem(value: "4", child: Text("Add speakers")),
        PopupMenuItem(value: "5", child: Text("Report")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    return GestureDetector(
      onTap: eventModel.status != 'podcast'
          ? () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PodcastScreen(eventModel: eventModel)))
          : () async {
              await Permission.microphone.request();
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return AudioRoom(
                    role: _checkIfBroadCaster(loggedInUserId: _loggedInUser?.id, moderatorId: eventModel.moderator?.id)
                        ? ClientRole.Broadcaster
                        : ClientRole.Audience,
                    room: eventModel,
                  );
                  //   eventModel.status == 'podcast'
                  // ? Debatecompetition(eventModel: eventModel)
                  // :
                },
              );
            },
      child: Card(
        elevation: 10,
        color: Color(0xfff2f2f2),
        shadowColor: Color(0xfff2f2f2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Wrap(
          children: [
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DisplayPicture(
                          radius: 20,
                          url: eventModel.moderator?.avatar,
                          name: eventModel.moderator?.fullName,
                          userId: eventModel.moderator?.id),
                      Container(
                        margin: EdgeInsets.all(6),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                Util.capitalize(eventModel.moderator!.fullName ?? ""),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(eventModel.moderator?.designation ?? "",
                                  style: TextStyle(fontSize: 10, color: Colors.black54)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 10,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: Text("#${eventModel.type}", style: TextStyle(color: Colors.red, fontSize: 10)),
                          ),
                        ),
                        Card(
                          elevation: 10,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: Text(Util.capitalize(eventModel.status ?? ""),
                                style: TextStyle(color: Colors.red, fontSize: 10)),
                          ),
                        ),
                        _showmenubar(loggedInUserId: _loggedInUser?.id, moderatorId: eventModel.moderator?.id),
                      ],
                    ),
                  )
                ],
              ),
            ),
            //Users display with cover
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("${eventModel.topic}"),
            ),
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 5),
              decoration: eventModel.bannerImage != null
                  ? new BoxDecoration(
                      image: new DecorationImage(
                        colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                        image: CachedNetworkImageProvider(eventModel.bannerImage ?? ""),
                        fit: BoxFit.cover,
                      ),
                    )
                  : new BoxDecoration(color: Colors.grey),
              child: Container(
                height: 130,
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventModel.participants!.length,
                  itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: DisplayPicture(
                          radius: 30,
                          url: eventModel.participants![index].user?.avatar,
                          name: eventModel.participants![index].user?.fullName)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          print("object");
                        },
                        icon: Icon(
                          _checkIfLiked(loggedInUserId: _loggedInUser?.id, likes: eventModel.likes)
                              ? Icons.favorite_sharp
                              : Icons.favorite_border,
                          size: 20,
                          color: _checkIfLiked(loggedInUserId: _loggedInUser?.id, likes: eventModel.likes)
                              ? Colors.redAccent
                              : Colors.black,
                        ),
                        label: Text("${eventModel.likes?.length}"),
                        style: TextButton.styleFrom(primary: Colors.black, textStyle: TextStyle(fontSize: 10)),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.repeat, size: 20),
                        label: Text("${eventModel.audioComments?.length}"),
                        style: TextButton.styleFrom(primary: Colors.black, textStyle: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "${eventModel.participants?.length} Joined",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            Divider(endIndent: 10, indent: 10, color: Colors.black),

            eventModel.audioComments!.length > 0
                ? Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: 4,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ConversationReply(byYou: true),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "View All",
                            style: TextStyle(fontSize: 10),
                          ),
                          style: TextButton.styleFrom(primary: Colors.black),
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
