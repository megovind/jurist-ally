import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/PodcastScreen/PodcastScreen.dart';
import 'package:juristally/pages/events/AudioCall/audio_call.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class EventsCard extends StatelessWidget {
  final EventModel event;
  final Function? acceptInvitation;
  const EventsCard({Key? key, required this.event, this.acceptInvitation}) : super(key: key);

  bool _isModerator(String? id) => event.moderator?.id == id;

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    final meParticipant = event.participants!.firstWhere((el) => el.user?.id == loggedInUser?.id && el.type == 'judge',
        orElse: () => Participant(user: loggedInUser));
    return Card(
      margin: EdgeInsets.all(2),
      elevation: 1,
      shadowColor: Colors.black,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: event.bannerImage != null
              ? DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.hardLight),
                  image: CachedNetworkImageProvider(event.bannerImage ?? ""),
                  fit: BoxFit.cover,
                )
              : DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.hardLight),
                  image: ExactAssetImage('assets/images/white-logo.png'),
                  fit: BoxFit.cover,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              child: Text(
                DateFormat.yMEd().add_jm().format(event.commenceDate ?? DateTime.now()),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: Text(
                Util.capitalize("${event.type}"),
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "${event.topic}",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.notifications_active_outlined, color: Colors.white, size: 30),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            Container(
              height: 30,
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: event.participants!.length,
                itemBuilder: (context, index) {
                  final participant = event.participants![index];
                  return DisplayPicture(
                    radius: 30,
                    name: participant.user?.fullName,
                    url: participant.user?.avatar,
                    userId: participant.user?.id,
                  );
                },
              ),
            ),
            _isModerator(loggedInUser!.id)
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: event.status == 'podcast'
                            ? () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => PodcastScreen(eventModel: event)))
                            : () async {
                                await Permission.microphone.request();
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return AudioRoom(
                                      role:
                                          _isModerator(loggedInUser.id) ? ClientRole.Broadcaster : ClientRole.Audience,
                                      room: event,
                                    );
                                  },
                                );
                              },
                        child: Text("Go On...")),
                  )
                : Container(),
            meParticipant.type == 'judge' && event.status == 'yet_to_start'
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Divider(),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "${Util.capitalize(event.moderator?.fullName ?? "")} has invited to be a judge at a moot.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      meParticipant.invitationAccepted
                          ? Container(
                              child: ElevatedButton(onPressed: () {}, child: Text("Accepted")),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomElevatedButton(
                                  verticalPadding: 5,
                                  horizontalPadding: 20,
                                  onPressed: () {
                                    acceptInvitation!(event.id, meParticipant.id, false);
                                  },
                                  child: Text("Cancel", style: TextStyle(color: Colors.black)),
                                ),
                                CustomElevatedButton(
                                  verticalPadding: 5,
                                  horizontalPadding: 20,
                                  onPressed: () {
                                    acceptInvitation!(event.id, meParticipant.id, true);
                                  },
                                  child: Text("Accepts", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            )
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
