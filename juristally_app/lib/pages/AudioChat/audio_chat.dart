import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/ChatProvider/chat_provider.dart';
import 'package:juristally/models/audio_chat_models.dart';

import 'package:juristally/pages/AudioChat/chat_screen.dart';
import 'package:juristally/pages/AudioChat/group_creation.dart';

import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AudioChat extends StatefulWidget {
  static const routename = "/audioChat";

  AudioChat({Key? key}) : super(key: key);

  @override
  _AudioChatState createState() => _AudioChatState();
}

class _AudioChatState extends State<AudioChat> {
  bool _isLoading = false;
  List<Rooms> _rooms = [];
  String? _userId, _token;
  late Socket socket;
  @override
  void initState() {
    _isLoading = true;
    _userId = Provider.of<AuthProvider>(context, listen: false).loggedInUser?.id;
    _token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    socket = ChatUtils().connectToServer(_token);
    _fetchRooms();
    _listenNewChats();
    super.initState();
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _listenNewChats() {
    ChatUtils().newChatStartListner(
      socket: socket,
      callback: (data) => {
        setState(
          () => _rooms.add(Rooms.fromJson(data)),
        ),
      },
    );
  }

  _fetchRooms() => ChatUtils().fetchAllRoomsListners(socket: socket, fetchAllRooms: fetchAllRooms, userId: _userId);

  fetchAllRooms(data) {
    print("FETCHING ALL ROOMS");
    if (data == null || data.length == 0) {
      setState(() => _isLoading = false);
      return;
    }
    ;
    List<Rooms> _roomList = listRooms(data);
    _setRooms(_roomList);
  }

  _setRooms(List<Rooms> listRooms) => setState(() {
        _rooms = listRooms;
        _isLoading = false;
      });

  @override
  void dispose() {
    ChatUtils().diconnectocket(socket);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Audio Chat", style: TextStyle(color: Colors.black, fontSize: 16)),
        leading:
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(CupertinoIcons.back, color: Colors.black)),
        actions: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupCreationPage()),
        ),
        backgroundColor: Colors.white,
        child: Icon(
          Icons.group_add_outlined,
          color: Colors.black,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _rooms.length > 0
              ? ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return !room.isGroup ? _singleChatCard(room: room) : _groupChatCard(room: room);
                  },
                )
              : Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No People to chat"),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupCreationPage(),
                            ),
                          ),
                          child: Text("Search people to chat"),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  _singleChatCard({required Rooms room}) {
    room.members!.removeWhere((element) => element.user != null && element.user!.id == _userId);
    final member = room.members!.firstWhere((element) => element.user != null && element.user!.id != _userId);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(group: room, user: member.user),
        ),
      ),
      child: Card(
        color: Color(0xfff2f2f2),
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  DisplayPicture(
                    radius: 20,
                    name: member.user?.fullName,
                    url: member.user?.avatar,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.user!.fullName ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        room.lastMessage?.txtMsg != null
                            ? Text(
                                "${room.lastMessage!.txtMsg!.length > 30 ? room.lastMessage?.txtMsg?.substring(0, 30) : room.lastMessage?.txtMsg} ")
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.mic, color: Colors.grey),
                Container(
                    width: 25,
                    child: Text("${room.unReadCount.toString()}", style: TextStyle(fontSize: 12, color: Colors.red))),
                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _groupChatCard({required Rooms room}) {
    room.members?.removeWhere((element) => element.user!.id == _userId);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(group: room),
        ),
      ),
      child: Card(
        color: Color(0xfff2f2f2),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                width: MediaQuery.of(context).size.width * 0.7,
                height: room.members!.length > 5
                    ? MediaQuery.of(context).size.height * 0.15
                    : MediaQuery.of(context).size.height * 0.06,
                margin: EdgeInsets.symmetric(vertical: 5),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                  itemCount: room.members!.length > 10 ? 10 : room.members!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final member = room.members![index];
                    return Container(
                      padding: EdgeInsets.all(5),
                      child: DisplayPicture(
                        radius: 20,
                        name: member.user?.fullName,
                        url: member.user?.avatar,
                      ),
                    );
                  },
                ),
              ),
              room.members!.length > 10
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "+ ${room.members!.length - 10}",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  : Container()
            ],
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        room.name ?? "",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      room.lastMessage?.txtMsg != null
                          ? Text(
                              "${room.lastMessage!.txtMsg!.length > 30 ? room.lastMessage?.txtMsg?.substring(0, 30) : room.lastMessage?.txtMsg} ")
                          : Container(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.mic, color: Colors.grey),
                    Container(
                      width: 25,
                      child: Text(
                        "${room.unReadCount.toString()}",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
