import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

class ConversationReply extends StatelessWidget {
  final bool byYou;
  final AudioComments? audioComments;
  const ConversationReply({Key? key, this.audioComments, this.byYou = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: byYou
            ? [
                _userAndRecord(), _controlAndReply(),
                // !byYou ? _controlAndReply() : _userAndRecord(),
              ]
            : [
                _controlAndReply(),
                _userAndRecord(),
              ],
      ),
    );
  }

  _controlAndReply() {
    return Row(
      children: byYou
          ? [
              IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.reply)),
            ]
          : [
              IconButton(onPressed: () {}, icon: Icon(Icons.reply)),
              IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow_outlined)),
            ],
    );
  }

  _userAndRecord() {
    return Row(
      children: byYou
          ? [
              DisplayPicture(radius: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Govind"),
                    Text('-----------------'),
                    Text(
                      "Great bro...",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            ]
          : [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Govind"),
                    Text('-----------------'),
                    Text(
                      "Great bro...",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              DisplayPicture(radius: 40),
            ],
    );
  }
}
