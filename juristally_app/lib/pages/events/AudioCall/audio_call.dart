import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/ChatProvider/chat_provider.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/data/config.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/events/Participantbox/participant_view.dart';
import 'package:juristally/pages/events/documents.dart';
import 'package:juristally/pages/events/marking.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AudioRoom extends StatefulWidget {
  final EventModel room;
  final ClientRole role;
  AudioRoom({Key? key, required this.role, required this.room}) : super(key: key);

  @override
  _AudioRoomState createState() => _AudioRoomState();
}

class _AudioRoomState extends State<AudioRoom> {
  EventModel? _room;
  List<Participant?> _participants = [];
  UserModel? _loggedUser;
  bool _isModeratorSpeaking = false;
  bool _showAllMic = false;
  late RtcEngine _engine;
  Participant? _meParticipant;
  String? _token;
  late String recordingPath;
  late Socket socket;

  @override
  void initState() {
    _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    socket = ChatUtils().connectToServer(_token);
    _room = widget.room;
    _participants = _room!.participants!.toList();
    super.initState();
    initialize();
    _onEvenActivitytListioner();
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    ChatUtils().diconnectocket(socket);
    super.dispose();
  }

  Future<void> initialize() async {
    final token = await _getToken();
    print("UIDD ${_loggedUser!.uid}");
    if (token.isNotEmpty) {
      await _initAgoraRtcEngine();
      _addAgoraEventsHandler();
      await _engine.joinChannel(token, "${_room?.id}", null, _loggedUser!.uid);
    }
  }

  Future<String> _getToken() async {
    try {
      final data = {"channelName": "${_room!.id}", "uid": _loggedUser!.uid, "role": widget.role.index};
      return await Provider.of<AuthProvider>(context, listen: false).fetchAgoraToken(data: data);
    } catch (e) {
      print(e);
      Get.snackbar("", e.toString());
      return "";
    }
  }

  Future<void> _initAgoraRtcEngine() async {
    try {
      RtcEngineContext ctnxt = RtcEngineContext(Configs.APPID);

      _engine = await RtcEngine.createWithContext(ctnxt);

      await _engine.enableAudio();
      await _engine.setChannelProfile(ChannelProfile.Communication);
      // await _engine.setClientRole(widget.role);
      await _engine.setEnableSpeakerphone(true);
      // await _engine.enableLocalAudio(true)
      // await _engine.setRemoteVoicePosition(uid, pan, gain)
      await _engine.enableAudioVolumeIndication(1000, 3, false);
    } catch (e) {
      print(e);
      Get.snackbar("", e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  void _addAgoraEventsHandler() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: _onError,
        joinChannelSuccess: _onJoinChannelSuccess,
        leaveChannel: _onLeaveChannel,
        userJoined: _onUserJoind,
        userOffline: (uid, reason) {},
        audioVolumeIndication: _onAudioVolumeIndication,
        tokenPrivilegeWillExpire: (token) async {
          await _engine.renewToken(token);
        },
      ),
    );
  }

  _onAudioVolumeIndication(List<AudioVolumeInfo> speakers, int volume) {
    for (var speaker in speakers) {
      // print("SPEAKER ${speaker.uid}");
      // print("MUID ${_room?.moderator?.uid}");
      setState(() {
        if (_room!.moderator!.uid == speaker.uid && speaker.volume > 1)
          _isModeratorSpeaking = true;
        else
          _isModeratorSpeaking = false;

        // int index = _participants.indexWhere((el) => el!.user!.uid == speaker.uid);
        final _parts = _participants.firstWhere((el) => el!.user!.uid == speaker.uid,
            orElse: () => Participant(user: _loggedUser));
        _parts?.isSpeaking = speaker.volume > 1;
        // _participants.insert(0, _parts);
      });
    }
  }

  _muteUnmuteUser({required int uid, bool muted = false}) async {
    _onMuteUnMuteUser(uid: uid);
    await _engine.muteRemoteAudioStream(uid, muted);
  }

  _onMuteUnMuteUser({required int uid}) {
    final usr = _participants.firstWhere((el) => el!.user!.uid == uid, orElse: () => Participant(user: _loggedUser));
    ChatUtils().muteAUser(socket: socket, data: {"pid": usr?.id, "event": _room!.id, "is_mute": usr!.isMute});
  }

  _onError(ErrorCode code) async {
    print(code);
    // Get.snackbar("", "There is some issue while connectiong");
  }

  _onJoinChannelSuccess(String channel, int uid, int elapsed) {
    print("ITS THE UID: $uid");
    _userJoinEventHandler();
  }

  _onLeaveChannel(RtcStats stats) => _leaveTheChannelHandler();

  _onUserJoind(int uid, int elapsed) {
    print("JOINEDDD");
  }

  _startRocording() async {
    final tempDir = await getTemporaryDirectory();
    recordingPath = '${tempDir.path}/${_room?.type}_${_room?.id}.wav';
    final configs = AudioRecordingConfiguration(
      recordingPath,
      recordingQuality: AudioRecordingQuality.Low,
      recordingSampleRate: AudioSampleRateType.values[16000],
    );
    await _engine.startAudioRecordingWithConfig(configs);
  }

  _userJoinEventHandler() async {
    if (_isModerator()) {
      _startEventHandler();
      _startRocording();
    } else {
      final _participant = _findPartcipant(_loggedUser?.id);
      String? _type = _participant?.type;
      if (_participant != null) {
        _participantJoiningHandler(user: _participant.user!.id, type: _type, pid: _participant.id);
      } else {
        await _engine.muteLocalAudioStream(true);
        setState(() => _type = "audience");
        _participantJoiningHandler(user: _loggedUser!.id, type: _type);
      }
    }
  }

  _saveRecordedFile() async {
    try {
      await Provider.of<EventProvider>(context, listen: false)
          .createEvent(id: _room?.id, data: {"recorded_file": File(recordingPath)});
    } catch (e) {
      print("RECORDING NOT SAVED:: $e");
    }
  }

  _leaveTheChannelHandler() {
    print("LEAVIING:: ${_isModerator()} ");
    if (_isModerator()) {
      _endEventHandler();
      _saveRecordedFile();
    } else {
      final _pts = _findPartcipant(_loggedUser?.id);
      String? _type = _pts?.type;
      if (_pts == null && _pts?.type == null) {
        setState(() => _type = "audience");
      }
      _participantLeavingEventHandler(user: _loggedUser!.id, type: _type, pid: _pts?.id);
    }
  }

  Participant? _findPartcipant(String? id) {
    print("JOINGING PARTSIIIS:  $id ::: ${_participants.length} ");
    final clientss = _participants.where((el) => el?.user?.id == _loggedUser?.id);
    print("client:: $clientss");
    final _parts = _participants.first;
    return _parts;
  }

  _startEventHandler() {
    final _data = {"event": _room?.id};
    ChatUtils().startEventHandler(socket: socket, data: _data);
  }

  _endEventHandler() {
    final _data = {"event": _room?.id};
    ChatUtils().endEventHandler(socket: socket, data: _data);
  }

  _participantJoiningHandler({required String? user, required String? type, String? pid}) {
    final _data = {"event": _room?.id, "user": user, "type": type, "pid": pid, "status": "JOINED"};
    ChatUtils().participantJoinEventHandler(socket: socket, data: _data);
  }

  _participantLeavingEventHandler({required String? user, required String? type, String? pid}) {
    final _data = {"event": _room?.id, "user": user, "type": type, "pid": pid, "status": "LEFT"};
    ChatUtils().particpantLeavingEventHandler(socket: socket, data: _data);
  }

  bool _isModerator() => _room?.moderator?.id == _loggedUser?.id;

  _onEvenActivitytListioner() {
    ChatUtils().onRefreshEventHandler(
        socket: socket,
        refreshEvent: (data) {
          print("REFRESHHSEDD REJOIN: $data");
          _parseEventModel(data);
        });
    ChatUtils().onHandRaised(socket: socket, callback: _handRaisedhandler);
    ChatUtils().onEventErrorHandler(socket: socket, onErrorCallBack: _onEventErrorHandler);
  }

  _onEventErrorHandler(data) {
    print(data);
  }

  _handRaisedhandler(data) {
    if (_isModerator()) {
      Get.snackbar(
        '',
        data.message,
        snackPosition: SnackPosition.TOP,
        icon: Icon(
          CupertinoIcons.hand_raised_fill,
          color: Colors.green,
        ),
      );
    }
    return;
  }

  _parseEventModel(data) {
    print("PARITPANT JOINED OR SOME EVENT $data");
    try {
      setState(() {
        _room = EventModel.fromJson(data);
        _participants = _room!.participants!.toList();
      });
    } catch (e) {
      print("ERROROOR: $e");
      Get.snackbar('', "Something went wrong!", snackPosition: SnackPosition.TOP);
    }
  }

  _leaveorEndMeeting() {
    _leaveTheChannelHandler();
    if (_engine != null) {
      _engine.leaveChannel();
      _engine.destroy();
    }
  }

  bool _isMute = false;
  bool _isVote = false;

  _onVote({String? votingTo}) {
    final _data = {"uid": _loggedUser?.id, "pid": votingTo, "event": _room!.id};
    ChatUtils().voteForParticipant(socket: socket, data: _data);
  }

  _raiseHandHandler(String? pid) {
    final _data = {"event": _room!.id, "pid": pid};
    ChatUtils().raiseHandHandler(socket: socket, data: _data);
  }

  _opposeFavourEventHandler({String? type}) {
    final _data = {"event": _room?.id, "uid": _loggedUser!.id, "type": type};
    ChatUtils().opposeFavourEvent(socket: socket, data: _data);
  }

  bool _isAudience(String? id) => _participants.indexWhere((el) => el!.user!.id == id && el.type == 'audience') > -1;
  bool _opposed(String? uid) => _room!.opposeLikes!.indexWhere((el) => el.id == uid) > -1;
  bool _favoured(String? uid) => _room!.favourLikes!.indexWhere((el) => el.id == uid) > -1;
  bool _youHaveVotedFor(String? pid) => _room!.requestsToTalk!.indexWhere((el) => el.id == pid) > -1;
  bool _handraised(String? pid) => _room!.requestsToTalk!.indexWhere((el) => el.id == pid) > -1;

  _micButton(Participant? partcips) {
    Widget _button = IconButton(
      onPressed: () async {
        await _engine.muteLocalAudioStream(partcips!.isMute);
        _onMuteUnMuteUser(uid: partcips.user!.uid);
      },
      icon: Icon(partcips!.isMute ? Icons.mic_off : Icons.mic),
      color: partcips.isMute ? Colors.red : Colors.black,
    );
    if (_isModerator()) {
      _button = IconButton(
        onPressed: () async {
          print("MUTEDUNMUTE");
          await _engine.muteLocalAudioStream(!_isMute);
          setState(() => _isMute = !_isMute);
        },
        icon: Icon(_isMute ? Icons.mic_off : Icons.mic),
        color: _isMute ? Colors.red : Colors.black,
      );
    } else if (_isAudience(partcips.user?.id)) {
      _button = Container();
    }

    return _button;
  }

  @override
  Widget build(BuildContext context) {
    _meParticipant =
        _participants.firstWhere((el) => el?.user?.id == _loggedUser?.id, orElse: () => Participant(user: _loggedUser));
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: _room?.bannerImage != null ? 200 : 80,
        flexibleSpace: _room?.bannerImage != null
            ? Container(
                height: 200,
                color: Colors.blueGrey,
                decoration:
                    BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(_room?.bannerImage ?? ""))),
              )
            : Container(),
        title: Text(
          _room?.moderator?.fullName ?? "",
          style: TextStyle(color: Colors.black),
        ),
        leading: Container(
          padding: EdgeInsets.only(left: 10),
          child: DisplayPicture(
            name: _room?.moderator?.fullName,
            url: _room?.moderator?.avatar,
            userId: _room?.moderator?.id,
            radius: 20,
          ),
        ),
        actions: [
          _micButton(_meParticipant),
          _showmenubar(),
        ],
      ),
      floatingActionButton: _floatingButtons(_meParticipant),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              alignment: Alignment.center,
              child: Wrap(
                children: [_judgesWidget(), _participantsWidget(), _audienceWidget()],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _bottomSheet(_meParticipant),
          )
        ],
      ),
    );
  }

  _floatingButtons(Participant? currentParticipant) {
    return Container(
      margin: EdgeInsets.only(bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _room?.type == 'debate'
              ? Container(
                  margin: EdgeInsets.only(top: 100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Colors.white, blurRadius: 8),
                      BoxShadow(color: Colors.black38, blurRadius: 10)
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text.rich(
                      TextSpan(
                        text: 'F ',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        children: <InlineSpan>[
                          TextSpan(
                            text: '${_room!.favourLikes!.length}  ',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          TextSpan(
                            text: 'O  ',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${_room!.opposeLikes!.length} ',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _isModerator()
                  ? _roundedElevetedButton(
                      onClick: () => setState(() => _showAllMic = !_showAllMic),
                      icon: Icons.mic_off_outlined,
                      label: "Silent")
                  : Container(),
              SizedBox(height: 10),
              _room?.type == 'debate'
                  ? _roundedElevetedButton(
                      icon: Icons.how_to_vote_outlined,
                      label: "Vote",
                      onClick: () => setState(() => _isVote = !_isVote))
                  : Container(),
              _room?.type == 'moot' ||
                      currentParticipant?.type == 'judge' && currentParticipant?.type == 'oppose' ||
                      currentParticipant?.type == 'favour' ||
                      _isModerator()
                  ? Column(
                      children: [
                        _roundedElevetedButton(
                          onClick: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarkingTeams(
                                  event: _room,
                                  isModerator: _isModerator(),
                                ),
                              )),
                          icon: Icons.rate_review,
                          label: 'Marking',
                        ),
                        SizedBox(height: 10),
                        _roundedElevetedButton(
                            onClick: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DocumentsPage(event: _room),
                                  ),
                                ),
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'Doc'),
                      ],
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  _roundedElevetedButton({required Function onClick, required IconData icon, required String label}) {
    return ElevatedButton(
      onPressed: () => onClick(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Icon(icon, color: Colors.black, size: 30), Text(label, style: TextStyle(fontSize: 8))],
      ),
      style: ElevatedButton.styleFrom(
        elevation: 10,
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        primary: Colors.white,
        onPrimary: Colors.black,
      ),
    );
  }

  _bottomSheet(Participant? participant) {
    return Card(
      margin: EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(80))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextButton(
                child: Text("Leave", style: TextStyle(fontSize: 20, color: Colors.black)),
                onPressed: () {
                  _leaveorEndMeeting();
                  Navigator.pop(context);
                }),
          ),
          _room?.type != "letsTalk"
              ? _bottomIconButton(
                  onClick: () {
                    _opposed(participant!.user!.id)
                        ? Get.snackbar("", "You already opposed!")
                        : _opposeFavourEventHandler(type: "favour");
                  },
                  isDisabled: _opposed(participant!.user!.id),
                  icon: Icons.thumb_up_outlined,
                  label: "Favour")
              : Container(height: 0, width: 0),
          _room?.type != 'letsTalk'
              ? _bottomIconButton(
                  onClick: () {
                    _favoured(participant!.user!.id)
                        ? Get.snackbar("", "You already favoured!")
                        : _opposeFavourEventHandler(type: "oppose");
                  },
                  isDisabled: _favoured(participant!.user!.id),
                  icon: Icons.thumb_down_outlined,
                  label: "Oppose")
              : Container(height: 0, width: 0),
          !_isModerator()
              ? _bottomIconButton(
                  onClick: () => _raiseHandHandler(participant!.id),
                  icon: Icons.pan_tool_outlined,
                  color: _handraised(participant!.id) ? Colors.blueAccent : Colors.black,
                  label: "Raise")
              : Container(height: 0, width: 0),
          _bottomIconButton(
            onClick: () {
              print("object");
            },
            icon: Icons.arrow_forward_ios_outlined,
            label: "Replies",
          )
        ],
      ),
    );
  }

  _bottomIconButton({
    required Function onClick,
    required IconData icon,
    required String label,
    Color color = Colors.black,
    bool isDisabled = false,
  }) {
    return Container(
      height: 70,
      child: TextButton(
        onPressed: isDisabled ? () {} : () => onClick(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDisabled ? Colors.blue : color, size: 24),
            SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 8, color: Colors.black))
          ],
        ),
        style: TextButton.styleFrom(
            shape: CircleBorder(), padding: EdgeInsets.all(10), primary: isDisabled ? Colors.white24 : Colors.white),
      ),
    );
  }

  _showmenubar() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) => {print(value)},
      itemBuilder: (context) => [
        PopupMenuItem(value: "1", child: Text("Share")),
        PopupMenuItem(value: "3", child: Text("Restrict entry")),
        PopupMenuItem(value: "4", child: Text("Add speakers")),
        PopupMenuItem(value: "5", child: Text("Report")),
      ],
    );
  }

  _judgesWidget() {
    final List<Participant?> _judges = _participants.where((el) => el!.type == 'judge').toList();
    return _room?.type == 'moot'
        ? Wrap(
            children: [
              _heading("Judges"),
              _participantsCard(_judges, msg: "Judges yet to Join"),
            ],
          )
        : Container();
  }

  _participantsWidget() {
    final _opposeTeam = _participants.where((el) => el?.type == 'oppose').toList();
    final _favourTeam = _participants.where((el) => el?.type == 'favour').toList();
    final _guests = _participants.where((el) => el?.type == 'guest').toList();
    return Wrap(
      children: _room?.type != 'letsTalk'
          ? [
              _heading(_room?.type == "debate" ? "Favour" : "Team Favour"),
              _participantsCard(_favourTeam),
              _heading(_room?.type == "debate" ? "Oppose" : "Team Oppose"),
              _participantsCard(_opposeTeam),
            ]
          : [_heading('Guests'), _participantsCard(_guests)],
    );
  }

  _heading(String header, {EdgeInsets? margin, Alignment alignment = Alignment.centerLeft}) => Container(
        margin: margin,
        alignment: alignment,
        child: Text(header, style: TextStyle(color: Colors.grey, letterSpacing: 1, fontSize: 20)),
      );
  _notFoundMsg(String msg) => Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(20),
        child: Text(msg),
      );

  Widget _participantsCard(List<Participant?> list, {String msg = "No Participants found!"}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 20,
        child: list.length > 0 ? _horizListParticipant(list: list) : _notFoundMsg(msg),
      ),
    );
  }

  _horizListParticipant({required List<Participant?> list}) {
    return Center(
      child: ListView.builder(
        itemCount: list.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final participant = list[index];
          return _commonParticipantView(participant: participant);
        },
      ),
    );
  }

  _commonParticipantView({required Participant? participant}) {
    return ParticipantView(
      onVote: _onVote,
      isVote: _isVote,
      showAllMics: _showAllMic,
      onMuteUnmute: _muteUnmuteUser,
      isAudence: _isAudience(participant!.user?.id),
      voted: _youHaveVotedFor(participant.id),
      participant: participant,
    );
  }

  _audienceWidget() {
    List<Participant?> _audiences = _participants.where((el) => el!.type == 'audience').toList();
    return Column(
      children: [
        _heading("Audience", margin: EdgeInsets.symmetric(vertical: 20)),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: _audiences.length > 0
              ? GridView.builder(
                  itemCount: _audiences.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                  itemBuilder: (context, index) {
                    final audi = _audiences[index];
                    return _commonParticipantView(participant: audi);
                  },
                )
              : _notFoundMsg("Audience is yet to join"),
        )
      ],
    );
  }
}
