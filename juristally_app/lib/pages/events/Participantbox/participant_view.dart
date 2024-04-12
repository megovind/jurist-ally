import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

class ParticipantView extends StatelessWidget {
  final Function? onVote, onMuteUnmute;
  final Participant? participant;
  final bool isVote, isModerator, showAllMics, isAudence, voted;
  const ParticipantView({
    Key? key,
    this.onVote,
    this.onMuteUnmute,
    this.isModerator = false,
    this.isVote = false,
    this.showAllMics = false,
    this.isAudence = false,
    this.voted = false,
    this.participant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isJudge = participant?.type == 'judge' || participant?.type == 'audience';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: participant!.isSpeaking ? 35 : 30,
                backgroundColor: Colors.black26,
                child: DisplayPicture(
                  radius: 30,
                  fontSize: 30,
                  url: participant?.user?.avatar,
                  name: participant?.user?.fullName,
                ),
              ),
              isModerator && showAllMics
                  ? GestureDetector(
                      onTap: () => onMuteUnmute!.call(participant?.user?.uid),
                      child: Icon(CupertinoIcons.mic_slash),
                    )
                  : Container(height: 0, width: 0),
              participant!.handRaised
                  ? GestureDetector(onTap: () {}, child: Icon(CupertinoIcons.hand_raised, color: Colors.blue))
                  : Container(height: 0, width: 0),
              !_isJudge
                  ? !isVote
                      ? participant!.audienceVotes!.length != null
                          ? Container(
                              alignment: Alignment.bottomRight,
                              margin: EdgeInsets.only(top: 55, left: 55),
                              child: Text("v${participant!.audienceVotes!.length}", style: TextStyle(fontSize: 10)),
                            )
                          : Container(height: 0, width: 0)
                      : Container(height: 0, width: 0)
                  : Container(
                      height: 0,
                      width: 0,
                    ),
              isVote
                  ? Container(
                      margin: EdgeInsets.only(top: 20, left: 10),
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () => onVote!.call(participant?.user!.id),
                        icon: Icon(Icons.check, color: Colors.red),
                      ),
                    )
                  : Container(height: 0, width: 0)
            ],
          ),
          Container(
            alignment: Alignment.center,
            child: Column(children: [
              Text(
                "${participant?.user?.fullName?.split(" ").first}",
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              participant?.user?.designation != null
                  ? Text(
                      "${participant?.user?.designation}",
                      style: TextStyle(fontSize: 8),
                    )
                  : Container()
            ]),
          ),
        ],
      ),
    );
  }
}
