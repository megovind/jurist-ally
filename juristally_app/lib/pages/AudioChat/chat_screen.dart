import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/ChatProvider/chat_provider.dart';
import 'package:juristally/Providers/uploadfile.dart';
import 'package:juristally/helper/file_upload.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/audio_chat_models.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/SharedWidgets/audio_player.dart';
import 'package:juristally/pages/SharedWidgets/audio_record_button.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/pages/SharedWidgets/view_images.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatScreen extends StatefulWidget {
  static const routename = "/chatScreen";
  final UserModel? user;
  final Rooms? group;
  ChatScreen({Key? key, this.user, this.group}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController(initialScrollOffset: 0.0);
  UserModel? _loggedIsUser;
  bool _isLoading = false;
  Rooms? _currentRoom;
  List<ChatMessage> _messages = [];
  List<Media> _mediaFiles = [];
  List<File> _selectedFiles = [];
  String? _token;
  late Socket socket;

  @override
  void initState() {
    _loggedIsUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _currentRoom = widget.group;
    _token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    socket = ChatUtils().connectToServer(_token);
    super.initState();
    _onRecieveMessageListner();
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

  _saveFile(path, txtMsg) async {
    try {
      final otherFiles = await _uploadAllFIles();
      final savedAudioFile = await UploadFile().uploadFile(File(path));
      _sendMessage(savedAudioFile['file_url'], txtMsg, otherFiles);
    } catch (e) {
      print('RECORDINGNN  $e');
      Get.snackbar("", "Message not sent!", snackPosition: SnackPosition.BOTTOM);
    }
  }

  _selectFiles({required List<String> types}) async {
    List<File> newFiles = await selectMultipleFiles(types: types);
    setState(() => _selectedFiles = newFiles);
  }

  Future<List<dynamic>> _uploadAllFIles() async {
    List<Map<String, dynamic>> _fileData = [];
    if (_selectedFiles.length > 0) {
      for (var item in _selectedFiles) {
        print('RECORDINGNN file $item');
        Map<String, dynamic> _fileMap = {};
        final uploadedFile = await UploadFile().uploadFile(item);
        _fileMap['media_url'] = uploadedFile['file_url'];
        _fileMap['type'] = uploadedFile['file_url'].split(".").last;
        _fileData.add(_fileMap);
        _mediaFiles.add(Media(mediaUrl: _fileMap['media_url'], type: _fileMap['type']));
      }
    }
    return _fileData;
  }

  _sendMessage(String audioFile, String? txtMsg, List media) {
    setState(() => _isLoading = true);
    try {
      final _data = {
        "txt_msg": txtMsg,
        "audio_msg": audioFile,
        "group_id": _currentRoom?.id,
        "creator": _loggedIsUser?.id,
        "userId": _loggedIsUser?.id,
        "members": _currentRoom != null && _currentRoom!.isGroup ? [] : [widget.user?.id, _loggedIsUser?.id],
        "media": media
      };
      ChatUtils().sendMessage(socket: socket, data: _data);
      _chatListScrollToBottom();
    } catch (e) {
      print(e);
      Get.snackbar("", "Message not sent!", snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _isLoading = false);
  }

  _onRecieveMessageListner() {
    ChatUtils().handleMessage(
        socket: socket,
        callBack: (data) {
          print("CHAT: NEW MESSAGE Recieved , $data");
          final _message = ChatMessage.fromJson(data);
          setState(() => _messages.add(_message));
          _chatListScrollToBottom();
        });
    _loadMessages();
  }

  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 200), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
  }

  _loadMessages() async {
    setState(() => _isLoading = true);
    await ChatUtils().loadMessages(
      socket: socket,
      data: {"group_id": _currentRoom?.id},
      callback: _setLoadMessagesListner,
    );
    setState(() => _isLoading = false);
  }

  _setLoadMessagesListner(data) {
    setState(() {
      _messages = listMessages(data);
      _chatListScrollToBottom(); //Timer(Duration(milliseconds: 500), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    String? title, subtitle;
    UserModel? member;
    if (_currentRoom != null && _currentRoom!.isGroup) {
      title = _currentRoom?.name;
      subtitle = _currentRoom!.members!.map((e) => e.user!.fullName).join(", ");
    } else {
      member = _currentRoom?.members?.firstWhere((element) => element.user?.id != _loggedIsUser?.id).user;
      title = member?.fullName;
      subtitle = member?.summary;
      if (widget.user != null) {
        title = widget.user?.fullName;
      }
    }

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  iconSize: 20,
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
              Container(
                child: _currentRoom != null && _currentRoom!.isGroup
                    ? DisplayPicture(radius: 20, name: _currentRoom?.name)
                    : DisplayPicture(radius: 20, name: title, url: member?.avatar, userId: member?.id),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Util.capitalize("$title"),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    Container(
                      child: subtitle != null
                          ? Text("${subtitle.length > 40 ? subtitle.substring(0, 40) + '...' : subtitle}",
                              style: TextStyle(color: Colors.grey, fontSize: 12), softWrap: true)
                          : Container(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AudioRecordButton(saveRecoring: _saveFile),
              IconButton(
                onPressed: () => _selectFiles(types: ['jpg', 'png', 'jpeg', 'svg', 'gif', 'pdf']),
                icon: Icon(Icons.add_a_photo_outlined),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(5),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _messages.length > 0
                            ? ListView.builder(
                                controller: _scrollController,
                                reverse: false,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(10),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) => Align(
                                  alignment:
                                      _fromMe(id: _messages[index].user?.id) ? Alignment.topRight : Alignment.topLeft,
                                  child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: _fromMe(id: _messages[index].user?.id)
                                            ? Colors.blueGrey[50]
                                            : Colors.grey[50],
                                      ),
                                      child: _messageCard(message: _messages[index])),
                                ),
                              )
                            : Container(
                                child: Center(
                                  child: Text("Start conversations"),
                                ),
                              ),
                      )
                    ],
                  ),
          ),
        ));
  }

  bool _fromMe({required String? id}) => id == _loggedIsUser!.id;

  _messageCard({required ChatMessage message}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: _fromMe(id: message.user?.id) ? MainAxisAlignment.end : MainAxisAlignment.start,
      // crossAxisAlignment: _fromMe(id: message.user?.id) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _fromMe(id: message.user?.id) ? Container() : _userBox(message.user),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisAlignment: _fromMe(id: message.user?.id) ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: _fromMe(id: message.user?.id) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _nameContainer(name: message.user?.fullName),
              _playerWidget(audioMsg: message.audioMsg, fromMe: _fromMe(id: message.user?.id)),
              _txtMessageContainer(msg: message.txtMsg, fromMe: _fromMe(id: message.user?.id)),
              message.media!.length > 0
                  ? TextButton.icon(
                      onPressed: () => _viewFiles(files: message.media ?? []),
                      icon: Icon(Icons.visibility),
                      label: Text(
                        "View",
                        style: TextStyle(fontSize: 12),
                      ))
                  : Container()
            ],
          ),
        ),
        _fromMe(id: message.user?.id) ? _userBox(message.user) : Container(),
      ],
    );
  }

  _viewFiles({required List<Media>? files}) {
    return showDialog(
      context: context,
      routeSettings: RouteSettings(),
      builder: (context) => AlertDialog(
        content: ViewImagesPopup(images: files ?? []),
        actions: [OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("OKAY"))],
      ),
    );
  }

  _txtMessageContainer({required String? msg, bool fromMe = false}) {
    return Container(
      padding: EdgeInsets.all(5),
      child: msg != null
          ? Text("${msg.length > 20 ? msg.substring(0, 20) : msg}",
              style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: fromMe ? TextAlign.right : TextAlign.left)
          : Container(),
    );
  }

  _nameContainer({required String? name, bool fromMe = false}) {
    return Container(
        alignment: fromMe ? Alignment.topRight : Alignment.topLeft, padding: EdgeInsets.all(2), child: Text("$name"));
  }

  _playerWidget({required String? audioMsg, bool fromMe = false}) {
    return Container(
      alignment: fromMe ? Alignment.topRight : Alignment.topLeft,
      width: MediaQuery.of(context).size.width * 0.7,
      child: RotatedBox(quarterTurns: fromMe ? 2 : 0, child: NewAudioPlayer(audioUrl: audioMsg, isControls: true)),
    );
  }

  _userBox(UserModel? user) {
    return Container(
      child: DisplayPicture(radius: 25, url: user?.avatar, name: user?.fullName),
    );
  }
}
