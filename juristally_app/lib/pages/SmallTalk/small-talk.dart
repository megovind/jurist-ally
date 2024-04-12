import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/SmallTalkProvider/smalltalk_provider.dart';
import 'package:juristally/models/small_talk_model.dart';
import 'package:juristally/pages/SharedWidgets/audio_player.dart';
import 'package:juristally/pages/SmallTalk/create-small-talk.dart';
import 'package:juristally/pages/SmallTalk/rotating_player_disk.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SmallTalk extends StatefulWidget {
  static const routeName = '/small-talk';
  final SmallTalkModel? selectedTalk;
  SmallTalk({Key? key, this.selectedTalk}) : super(key: key);

  @override
  _SmallTalkState createState() => _SmallTalkState();
}

class _SmallTalkState extends State<SmallTalk> {
  bool _isLyrics = false;
  bool _isLoading = false;
  late MediaQueryData queryData;
  SwiperController _controller = SwiperController();

  List<SmallTalkModel> _smallTalks = [];

  _shareContent() {
    return Share.share("Checkout my small taalk");
  }

  @override
  void initState() {
    super.initState();
    _fetchSmallTalks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    queryData = MediaQuery.of(context);
    _controller.addListener(() {
      print("CONTROLLER CHANGED");
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _fetchSmallTalks() async {
    print("CALLED SMALLTLKS");
    setState(() => _isLoading = true);
    try {
      await Provider.of<SmallTalkProvider>(context, listen: false).fetchSmallTalks();
      final talks = Provider.of<SmallTalkProvider>(context, listen: false).smallTalks;
      setState(() => _smallTalks = talks);
    } catch (e) {
      print("EXPETION:: $e");
    }
    setState(() => _isLoading = false);
  }

  _likeDislikeSmallTalk(String id) async {
    try {
      await Provider.of<SmallTalkProvider>(context, listen: false).likeDislikeSmallTalk(id: id);
      //Liked mechnism
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Swiper(
      itemCount: _smallTalks.length,
      viewportFraction: 1,
      scale: 0.9,
      scrollDirection: Axis.vertical,
      controller: _controller,
      pagination: SwiperPagination(),
      itemWidth: queryData.size.width,
      itemHeight: queryData.size.height,
      itemBuilder: (BuildContext context, int index) {
        final smallTalk = _smallTalks[index];
        return Container(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSmallTalk())),
                    icon: Icon(Icons.add_box_outlined, size: 20, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () => _shareContent(),
                    icon: Icon(Icons.share, size: 20, color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              child: RotatingImage(user: smallTalk.user),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${smallTalk.user?.fullName ?? ""}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text("${smallTalk.user?.summary ?? ""}", style: TextStyle(fontSize: 10))
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.topLeft,
                        child: Text("${smallTalk.title}"),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await Provider.of<AuthProvider>(context, listen: false)
                              .followUnFollow(id: smallTalk.user?.id);
                        },
                        child: Text("Follow"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.record_voice_over,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.all(10),
              child: Text(
                "${smallTalk.tags!.join(", ")}",
                style: TextStyle(fontSize: 16, letterSpacing: 2),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    child: NewAudioPlayer(
                      playOnLoad: true,
                      audioUrl: smallTalk.audioClip,
                      isControls: true,
                    ),
                  ),
                  TextButton(onPressed: () => setState(() => _isLyrics = !_isLyrics), child: Text("Lyrics")),
                ],
              ),
            ),
            _isLyrics && smallTalk.lyrics!.isNotEmpty
                ? Container(margin: EdgeInsets.all(10), child: Text("${smallTalk.lyrics}"))
                : Container()
          ],
        ));
      },
    );

    return Scaffold(
      bottomNavigationBar: Card(
        elevation: 10,
        margin: EdgeInsets.only(bottom: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(80), topStart: Radius.circular(80)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomIconButton(onClick: () {}, icon: Icons.headphones, label: "100"),
            _bottomIconButton(
                onClick: () {
                  _likeDislikeSmallTalk("id");
                },
                icon: Icons.favorite,
                label: '100'),
            _bottomIconButton(onClick: () {}, icon: Icons.reply, label: "200")
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _smallTalks.length > 0
              ? _body
              : Center(
                  child: ElevatedButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSmallTalk())),
                      child: Text("Create SmallTalk")),
                ),
    );
  }

  _bottomIconButton({required Function onClick, required IconData icon, required String label, Color? color}) {
    return Container(
      height: 70,
      child: TextButton(
          onPressed: () => onClick(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? Colors.black, size: 24),
              SizedBox(height: 5),
              Text(label, style: TextStyle(fontSize: 8, color: Colors.black))
            ],
          ),
          style: TextButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(10),
            primary: Colors.white,
          )),
    );
  }
}
