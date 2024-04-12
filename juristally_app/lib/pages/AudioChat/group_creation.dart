import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/ChatProvider/chat_provider.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/audio_chat_models.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/AudioChat/chat_screen.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';

import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GroupCreationPage extends StatefulWidget {
  GroupCreationPage({Key? key}) : super(key: key);

  @override
  _GroupCreationPageState createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  final _pagingController = PagingController<int, UserModel>(firstPageKey: 1);
  int pageSize = 20;
  String? _userId, token;
  List<String> _selectedUsers = [];
  List<UserModel> _previewUsers = [];
  Rooms? _createdGroup;
  bool _isCreatingGroup = false;
  late Socket socket;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<AuthProvider>(context, listen: false).loggedInUser?.id;
    token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    socket = ChatUtils().connectToServer(token);
    _selectedUsers.add(_userId ?? "");
    _pagingController.addPageRequestListener((pageKey) => _searchUsers(pageKey));
    _setNewGroupListner();
  }

  _isSelected(String? id) => _selectedUsers.contains(id);

  _searchUsers(int index) async {
    try {
      final usrs = await Provider.of<AuthProvider>(context, listen: false).fetchUsers();
      final isLastpage = usrs.length < pageSize;
      if (isLastpage) {
        _pagingController.appendLastPage(usrs);
      } else {
        final nextPage = index + 1;
        _pagingController.appendPage(usrs, nextPage);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  Future<void> _createGroup() async {
    try {
      setState(() {
        _formData['members'] = _selectedUsers;
        _formData['is_group'] = true;
        _formData['creator'] = _userId;
      });
      ChatUtils().sendMessageListner(socket: socket, data: _formData);
    } catch (e) {
      print("GROUP CREATE:  $e");
      Get.snackbar("", "Group can't be created", snackPosition: SnackPosition.BOTTOM);
    }
  }

  _setNewGroupListner() {
    ChatUtils().newChatStartListner(
        socket: socket,
        callback: (data) {
          print("NEW ROOM CREATED: $data");
          setState(() {
            _createdGroup = Rooms.fromJson(data);
          });
        });
  }

  _modalGroupName() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border()),
            child: ListView.builder(
                itemCount: _previewUsers.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final user = _previewUsers[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: DisplayPicture(radius: 30, name: user.fullName, url: user.avatar),
                  );
                }),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              scrollPadding: EdgeInsets.all(0),
              decoration: InputDecoration(labelText: "Group Name", contentPadding: EdgeInsets.all(0)),
              onSaved: (value) => setState(() => _formData['name'] = value),
              validator: (value) {
                if (value!.isEmpty)
                  return "Please enter group name";
                else
                  return null;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              OutlinedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Do something like updating SharedPreferences or User Settings etc.
                      _formKey.currentState!.save();
                      await _createGroup();
                      // Navigator.of(context).pop();
                      Navigator.pop(context);
                      setState(() => _isCreatingGroup = !_isCreatingGroup);
                    }
                  },
                  child: Text("Create Group"))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Create Group",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.black,
              )),
          actions: _selectedUsers.length > 2
              ? [
                  IconButton(
                      onPressed: () => setState(() => _isCreatingGroup = !_isCreatingGroup),
                      icon: Icon(
                        _isCreatingGroup ? Icons.clear : Icons.check,
                        color: _isCreatingGroup ? Colors.red : Colors.green,
                      ))
                ]
              : []),
      body: _isCreatingGroup
          ? _modalGroupName()
          : RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (context) => Text("There are no users"),
                  itemBuilder: (context, child, index) {
                    final item = _pagingController.itemList![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), side: BorderSide(color: Colors.black26)),
                      child: ListTile(
                        minVerticalPadding: 20,
                        leading: DisplayPicture(url: item.avatar, name: item.fullName ?? "Juristally", radius: 20),
                        title: Text(
                          Util.capitalize("${item.fullName}"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.summary ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => ChatScreen(user: item))),
                              icon: RotationTransition(
                                turns: AlwaysStoppedAnimation(315 / 360),
                                child: Icon(Icons.send, color: Colors.black, size: 15),
                              ),
                            ),
                            Checkbox(
                                side: BorderSide(color: Colors.black),
                                value: _isSelected(item.id),
                                onChanged: (value) {
                                  setState(() {
                                    if (_isSelected(item.id)) {
                                      _selectedUsers.remove(item.id);
                                      _previewUsers.remove(item);
                                    } else {
                                      _selectedUsers.insert(0, item.id ?? "");
                                      _previewUsers.insert(0, item);
                                    }
                                  });
                                })
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
