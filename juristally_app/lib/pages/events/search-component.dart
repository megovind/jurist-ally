import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/pages/SharedWidgets/popup-dialogue.dart';
import 'package:provider/provider.dart';

class SearchComponent extends StatefulWidget {
  final List<SelectedBottomItems> selectList;
  final String type;
  final bool isInvites;
  // final Function onSelect;
  SearchComponent({Key? key, required this.selectList, required this.type, this.isInvites = false}) : super(key: key);

  @override
  _SearchComponentState createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  List<UserModel> _list = [];
  // List<dynamic> _selectedItems = [];
  List<SelectedBottomItems> _selectedBottomItems = [];
  String _errorMessage = "Users Not Found";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchUsers();
    _setInitItems();
  }

  _setInitItems() {
    _selectedBottomItems = widget.selectList;
    // for (var item in widget.selectList) {
    //   _list.removeWhere((element) => element.id == item.user?.id);
    // }
  }

  _searchUsers() async {
    setState(() => _isLoading = true);
    try {
      final usrs = await Provider.of<AuthProvider>(context, listen: false).fetchUsers();
      setState(() {
        _list = usrs;
        for (var item in widget.selectList) {
          _list.removeWhere((element) => element.id == item.user?.id);
        }
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  _removeBottomItem(UserModel? user) {
    final index = _selectedBottomItems.indexWhere((element) => element.user!.id == user?.id);
    setState(() {
      _selectedBottomItems.removeAt(index);
      _list.insert(0, user ?? UserModel());
    });
  }

  _bottomBottomBar() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedBottomItems.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DisplayPicture(
                url: _selectedBottomItems[index].user?.avatar,
                name: _selectedBottomItems[index].user?.fullName,
                radius: 30,
                fontSize: 30,
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () {
                    _removeBottomItem.call(_selectedBottomItems[index].user);
                  },
                  icon: Icon(Icons.remove, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: TextField(
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              hintText: "Search...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
          onChanged: (value) => setState(
            () => _list = _list.where((element) => element.fullName == value).toList(),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, _selectedBottomItems),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: _selectedBottomItems.length > 0
            ? [
                IconButton(
                  onPressed: () => Navigator.pop(context, _selectedBottomItems),
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                )
              ]
            : [],
      ),
      bottomNavigationBar: _selectedBottomItems.length > 0 ? _bottomBottomBar() : Container(height: 0),
      body: SafeArea(
        child: !_isLoading
            ? _list.length > 0
                ? ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, index) => _listCard(user: _list[index]),
                  )
                : Center(
                    child: Text(_errorMessage),
                  )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  _showSelectDialogue({required UserModel user}) {
    return showDialog(
      context: context,
      routeSettings: RouteSettings(),
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setCustomState) => PopUpDialogue(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: Text(
                    widget.isInvites ? "Do you want to invite ${user.fullName}?" : "Please select one of the type",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                widget.isInvites
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel")),
                          SizedBox(width: 20),
                          OutlinedButton(
                              onPressed: () {
                                _selectedBottomItems.add(SelectedBottomItems(type: "guest", user: user));
                                _list.removeWhere((element) => element.id == user.id);
                                Navigator.pop(context);
                              },
                              child: Text("Invite")),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                _selectedBottomItems.add(SelectedBottomItems(type: "favour", user: user));
                                _list.removeWhere((element) => element.id == user.id);
                                Navigator.pop(context);
                              },
                              child: Text("Favour")),
                          SizedBox(width: 20),
                          OutlinedButton(
                              onPressed: () {
                                // widget.onSelect("type", user);
                                setCustomState(() {
                                  _selectedBottomItems.add(SelectedBottomItems(type: "oppose", user: user));
                                  _list.removeWhere((element) => element.id == user.id);
                                });
                                Navigator.pop(context);
                              },
                              child: Text("oppose")),
                          SizedBox(width: 20),
                          widget.type == "moot"
                              ? OutlinedButton(
                                  onPressed: () {
                                    setCustomState(() {
                                      _selectedBottomItems.add(SelectedBottomItems(type: "judge", user: user));
                                      _list.removeWhere((element) => element.id == user.id);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("Judge"))
                              : Container(width: 0),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    ).then(
      (value) => setState(
        () {
          _selectedBottomItems = _selectedBottomItems;
          _list = _list;
          print(_selectedBottomItems);
        },
      ),
    );
  }

  _listCard({required UserModel user}) {
    return GestureDetector(
      onTap: () => widget.type == 'letsTalk'
          ? setState(() {
              _selectedBottomItems.add(SelectedBottomItems(type: "guest", user: user));
              _list.removeWhere((element) => element.id == user.id);
            })
          : _showSelectDialogue(user: user),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(color: Colors.black26)),
        child: ListTile(
          minVerticalPadding: 20,
          leading: DisplayPicture(
            url: user.avatar,
            name: user.fullName ?? "Juristally",
            radius: 30,
          ),
          title: Text(
            Util.capitalize(user.fullName ?? ""),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.summary ?? "Re-Search|THisIs God || THis is also afunction gpogi"),
        ),
      ),
    );
  }
}

class SelectedBottomItems {
  final String? type;
  final UserModel? user;

  SelectedBottomItems({this.type, this.user});
}
