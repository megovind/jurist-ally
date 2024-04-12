import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Localization/application.dart';
import 'package:juristally/Localization/localization.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/Providers/SmallTalkProvider/smalltalk_provider.dart';
import 'package:juristally/helper/crop_image.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/drop-down.model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/models/small_talk_model.dart';
import 'package:juristally/pages/AudioChat/audio_chat.dart';
import 'package:juristally/pages/AudioChat/chat_screen.dart';
import 'package:juristally/pages/Profile/UpdateProfile/update-profile.dart';
import 'package:juristally/pages/Profile/events-card.dart';
import 'package:juristally/pages/Profile/smalltalk-card.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:juristally/widget/Checkbox/checkbox.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "/profile-page";
  final String? id;
  ProfilePage({Key? key, this.id}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _pagingControllerEvents = PagingController<int, EventModel>(firstPageKey: 1);
  final _pagingControllerSmallTalks = PagingController<int, SmallTalkModel>(firstPageKey: 1);
  int _pageSize = 20;
  bool _isLoading = false;
  String _errorMessage = "Not Found";
  UserModel? _user, _loggedInUser;
  File? _selectedFile;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> _formData = {};
  DropDownModel? _selectedLangues = languagesList.firstWhere((element) => element.type == 'en');

  @override
  void initState() {
    super.initState();
    _loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    Future.delayed(Duration.zero, () {
      _getProfile();
    });
    _pagingControllerEvents.addPageRequestListener((pageKey) => _fetchEvents(pageKey));
    _pagingControllerSmallTalks.addPageRequestListener((pageKey) => _fetchSmallTalks(pageKey));
  }

  Future<void> _getProfile() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).fetchProfile(id: widget.id);
      setState(() {
        _user = Provider.of<AuthProvider>(context, listen: false).userProfile;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _followUnFollow() async {
    try {
      final message = await Provider.of<AuthProvider>(context, listen: false).followUnFollow(id: _user?.id);
      Get.snackbar("", message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  _languesSheet() {
    return _scaffoldKey.currentState!.showBottomSheet((context) => Card(
          child: ListView.builder(
            itemCount: languagesList.length,
            itemBuilder: (context, index) => CustomCheckBox(
              labelText: translatedString(context, languagesList[index].type),
              isSelected: languagesList[index].type == _selectedLangues?.type,
              onChanged: (value) {
                _scaffoldKey.currentState!.setState((() => _selectedLangues = languagesList[index]));
                application.onLocaleChanged!.call(Locale(_selectedLangues!.type));
              },
            ),
          ),
        ));
  }

  bool _isItMe() => _user?.id == _loggedInUser?.id;

  bool _checkIfFollower(String user, List<UserModel> followers) {
    bool contains = followers.contains((element) => element.id == user);
    return contains;
  }

  _navigateToUpdateProfle() =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile(user: _user)));

  Future<void> _fetchEvents(int index) async {
    try {
      final newItems =
          await Provider.of<EventProvider>(context, listen: false).fetchEvents(page: index, status: "live");
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerEvents.appendLastPage(newItems);
      } else {
        final nextPageKey = index + 1;
        _pagingControllerEvents.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingControllerEvents.error = e;
    }
  }

  Future<void> _fetchSmallTalks(int index) async {
    try {
      final newItems = await Provider.of<SmallTalkProvider>(context, listen: false).fetchSmallTalks();
      print("NEWITEMS $newItems");
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerSmallTalks.appendLastPage(newItems);
      } else {
        final nextPageKey = index + 1;
        _pagingControllerSmallTalks.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingControllerSmallTalks.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          )),
      backgroundColor: Color(0xFFE5E5E5),
      body: _isLoading
          ? Align(alignment: Alignment.center, child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _getProfile),
                child: _user != null
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Container(
                                  margin: EdgeInsets.only(top: 20, left: MediaQuery.of(context).size.width * 0.21),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // alignment: Alignment.center,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (_user?.avatar != null) {
                                                  showDialog(
                                                    context: context,
                                                    routeSettings: RouteSettings(),
                                                    builder: (context) => Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: CachedNetworkImageProvider(_user?.avatar ?? ""),
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: DisplayPicture(
                                                radius: 50,
                                                url: _user?.avatar,
                                                name: _user?.fullName,
                                                profileFile: _selectedFile,
                                                fontSize: 50,
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.bottomCenter,
                                              margin: EdgeInsets.only(top: 60, left: 80),
                                              child: _isItMe()
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        try {
                                                          final file = await cropImage(context: context);
                                                          setState(() {
                                                            _selectedFile = file;
                                                            _formData['profile'] = file;
                                                            _formData["resize"] = {"width": 60, "height": 60};
                                                          });
                                                          await Provider.of<AuthProvider>(context, listen: false)
                                                              .updateUser(data: _formData);
                                                        } catch (e) {
                                                          Get.snackbar("", "Profile not updated");
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                      ))
                                                  : Container(),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          Util.capitalize(_user?.fullName ?? ""),
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _isItMe()
                                      ? IconButton(
                                          onPressed: () => _navigateToUpdateProfle(),
                                          icon: Icon(Icons.settings),
                                        )
                                      : Container(),
                                  IconButton(onPressed: _languesSheet, icon: Icon(Icons.translate_outlined)),
                                  IconButton(
                                    onPressed: !_isItMe()
                                        ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(user: _user),
                                              ),
                                            )
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AudioChat(),
                                              ),
                                            ),
                                    icon: RotationTransition(
                                      turns: AlwaysStoppedAnimation(315 / 360),
                                      child: Icon(Icons.send, color: Colors.black),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Card(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Text("Follower ${_user?.connections?.followers?.length ?? 0}"),
                                  ),
                                  _verticalDivider(),
                                  Container(
                                    child: Text("Votes ${_user?.connections?.votes?.length ?? 0}"),
                                  ),
                                  _verticalDivider(),
                                  Container(
                                    child: Text("Allies ${_user?.connections?.allies?.length ?? 0}"),
                                  )
                                ],
                              ),
                            ),
                          ),
                          !_isItMe()
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: CustomElevatedButton(
                                    onPressed: () => _followUnFollow(),
                                    child: Text(
                                      _checkIfFollower(_loggedInUser?.id ?? "",
                                              _user!.connections != null ? _user!.connections!.followers ?? [] : [])
                                          ? "Unfollow"
                                          : "Follow",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    buttonColor: Colors.white,
                                  ),
                                )
                              : Container(),
                          Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: _user?.designation != null
                                  ? Text(
                                      _user!.designation ?? "",
                                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                                    )
                                  : Container()),
                          _user?.summary != null
                              ? Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(Util.capitalize(_user?.summary ?? "")),
                                )
                              : Container(),

                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              "Education",
                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                            ),
                          ),
                          _user!.educations!.length > 0
                              ? Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: ListView.builder(
                                    itemCount: _user?.educations!.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final edu = _user?.educations![index];
                                      return ListTile(
                                        title: Text("${edu!.instituteName}, ${edu.degree}"),
                                        subtitle: Text(
                                          "${DateFormat.yM().format(edu.startDate ?? DateTime.now())} - ${edu.isPursuing ? 'Present' : DateFormat.yM().format(edu.endDate ?? DateTime.now())}",
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: _isItMe()
                                      ? CustomElevatedButton(
                                          onPressed: () => _navigateToUpdateProfle(),
                                          child: Text(
                                            "+ Education",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : Container(),
                                ),

                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              "Experience",
                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                            ),
                          ),
                          _user!.expereinces!.length > 0
                              ? Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: ListView.builder(
                                    itemCount: _user?.expereinces!.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final exp = _user?.expereinces![index];
                                      return ListTile(
                                        title: Text("${exp?.company}, ${exp?.position}"),
                                        subtitle: Text(
                                            "${DateFormat.yM().format(exp!.startDate ?? DateTime.now())}- ${exp.isCurrently ? 'Currently working' : DateFormat.yM().format(exp.endDate ?? DateTime.now())} "),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: _isItMe()
                                      ? CustomElevatedButton(
                                          onPressed: () => _navigateToUpdateProfle(),
                                          child: Text(
                                            "+ Experience",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : Container(),
                                ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              "Achievements",
                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                            ),
                          ),
                          _user!.achievements!.length > 0
                              ? Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: ListView.builder(
                                      itemCount: _user?.achievements!.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final ach = _user?.achievements![index];
                                        return ListTile(
                                          title: Text("${ach?.eventName}, ${ach?.location?.place ?? ''}"),
                                          subtitle: Text("${DateFormat.yM().format(ach!.date ?? DateTime.now())}"),
                                        );
                                      }),
                                )
                              : Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: _isItMe()
                                      ? CustomElevatedButton(
                                          onPressed: () => _navigateToUpdateProfle(),
                                          child: Text(
                                            "+ Achievement",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : Container(),
                                ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(20),
                            child: Text(
                              "Upcoming Events",
                              style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
                            ),
                          ),
                          Container(
                            height: 270,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            child: PagedListView<int, EventModel>(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              pagingController: _pagingControllerEvents,
                              builderDelegate: PagedChildBuilderDelegate(
                                itemBuilder: (context, event, index) {
                                  return EventsCard(event: event);
                                },
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(20),
                            child: Text(
                              "Small Talks",
                              style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
                            ),
                          ),
                          //Small Talks
                          Container(
                            height: 230,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.topLeft,
                            child: PagedListView<int, SmallTalkModel>(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              pagingController: _pagingControllerSmallTalks,
                              builderDelegate: PagedChildBuilderDelegate(
                                itemBuilder: (context, smallTalk, index) {
                                  return SmallTalkCard(smallTalk: smallTalk);
                                },
                              ),
                            ),
                          ),
                          // Container(
                          //   alignment: Alignment.topLeft,
                          //   margin: EdgeInsets.all(20),
                          //   child: Text(
                          //     "Debates/Moots",
                          //     style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
                          //   ),
                          // ),
                          //Debates moots
                          // Container(
                          //   constraints: BoxConstraints.expand(height: 480),
                          //   alignment: Alignment.topLeft,
                          //   // padding: EdgeInsets.symmetric(horizontal: 10),
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: 10,
                          //     itemBuilder: (context, index) => Container(
                          //       child: Container(
                          //         margin: EdgeInsets.symmetric(horizontal: 5),
                          //         child: DebateMootCard(eventModel: _eventModel),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   alignment: Alignment.topLeft,
                          //   margin: EdgeInsets.all(20),
                          //   child: Text(
                          //     "Conversations",
                          //     style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
                          //   ),
                          // ),
                          //Conversation
                          // Container(
                          //   constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, 300)),
                          //   alignment: Alignment.topLeft,
                          //   margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          //   child: ListView.builder(
                          //     shrinkWrap: true,
                          //     physics: NeverScrollableScrollPhysics(),
                          //     itemCount: 5,
                          //     itemBuilder: (context, index) => Container(
                          //       child: Container(
                          //         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          //         child: ConversationReply(
                          //           byYou: index != 2,
                          //           audioComments: _eventModel.audioComments![0],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   alignment: Alignment.topLeft,
                          //   margin: EdgeInsets.all(20),
                          //   child: Text(
                          //     "Saved",
                          //     style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
                          //   ),
                          // ),
                          // Container(
                          //   height: 450,
                          //   alignment: Alignment.topLeft,
                          //   margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: 10,
                          //     itemBuilder: (context, index) => Container(
                          //       child: Container(
                          //         margin: EdgeInsets.symmetric(horizontal: 5),
                          //         child: ArticleCard(),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    : Container(
                        child: Center(
                          child: Text(_errorMessage),
                        ),
                      ),
              ),
            ),
    );
  }

  _verticalDivider() {
    return Container(height: 20, child: VerticalDivider(color: Colors.grey));
  }
}
