import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/small_talk_model.dart';
import 'package:juristally/pages/SmallTalk/small-talk.dart';

class SmallTalkCard extends StatelessWidget {
  final SmallTalkModel? smallTalk;
  const SmallTalkCard({Key? key, this.smallTalk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SmallTalk(selectedTalk: smallTalk),
        ),
      ),
      child: Card(
        elevation: 20,
        color: Color(0XFFF2F2F2),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Container(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.headphones, size: 15, color: Colors.blueGrey),
                    Text(
                      "${smallTalk?.heardBy != null ? smallTalk!.heardBy!.length.toString() : "0"}",
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      // padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.multitrack_audio, color: Colors.grey[900], size: 40),
                          Icon(Icons.multitrack_audio, color: Colors.grey[900], size: 40),
                          Icon(Icons.multitrack_audio, color: Colors.grey[900], size: 40)
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "${smallTalk?.user?.fullName}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: smallTalk?.cover != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(smallTalk?.cover ?? ""),
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.saturation),
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.darken),
                    image: ExactAssetImage('assets/images/white-logo.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}
