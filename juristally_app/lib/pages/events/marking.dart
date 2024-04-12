import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:provider/provider.dart';

class MarkingTeams extends StatefulWidget {
  final EventModel? event;
  final bool isModerator;
  MarkingTeams({Key? key, required this.event, this.isModerator = false}) : super(key: key);

  @override
  _MarkingTeamsState createState() => _MarkingTeamsState();
}

class _MarkingTeamsState extends State<MarkingTeams> {
  bool _isLoading = false;
  Map<String, dynamic> _formData = {};

  EventModel? _event;
  List<Participant>? _opposeParticipants = [];
  List<Participant>? _favourParticipants = [];
  Participant? _meAsParticipant;
  UserModel? _loggedInUser;
  int _fact = 0;
  int _law = 0;
  int _argument = 0;
  int _memo = 0;
  double _average = 0;
  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _meAsParticipant =
        _event!.participants!.firstWhere((el) => el.user?.id == _loggedInUser?.id, orElse: () => Participant());
    _opposeParticipants = _event?.participants!.where((el) => el.type == 'oppose').toList();
    _favourParticipants = _event?.participants!.where((el) => el.type == 'favour').toList();
  }

  bool _amIJudge() => _loggedInUser!.id == _meAsParticipant!.id && _meAsParticipant!.type == 'judge';

  _submitMarking(String? id, String pid, int fact, int law, int argument, int memo) async {
    try {
      setState(() {
        _isLoading = true;
        _formData['participant'] = pid;
        _formData['fact'] = "";
      });
      final marks = await Provider.of<EventProvider>(context, listen: false).markingByJudges(id: id, data: _formData);
      setState(() {});
    } catch (e) {
      Get.snackbar("", "There is some issue while marking");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_amIJudge()) {
      _fact = _meAsParticipant?.marking?.factsPoints ?? 0;
      _law = _meAsParticipant?.marking?.lawsPoints ?? 0;
      _argument = _meAsParticipant?.marking?.argumentPoints ?? 0;
      _memo = _meAsParticipant?.marking?.memoCount ?? 0;
      _average = (_fact + _law + _argument + _memo) / 4;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Marking"),
        leading:
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(CupertinoIcons.back, color: Colors.black)),
      ),
      body: !_amIJudge() || widget.isModerator
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${_meAsParticipant?.user?.fullName}",
                    style: TextStyle(fontSize: 20, color: Colors.blueGrey, letterSpacing: 1),
                  ),
                ),
                _marks(title: "Facts", marks: _fact),
                _marks(title: "Law", marks: _law),
                _marks(title: "Arguments", marks: _argument),
                _marks(title: "Memo", marks: _memo),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$_average",
                    style: TextStyle(fontSize: 20, color: Colors.blueGrey, letterSpacing: 1),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Favour",
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey, letterSpacing: 1),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _favourParticipants?.length,
                      itemBuilder: (context, index) => ListItem(
                          participant: _favourParticipants![index],
                          submitMarking: _submitMarking,
                          isModetator: widget.isModerator),
                    ),
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Oppose",
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey, letterSpacing: 1),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _opposeParticipants?.length,
                      itemBuilder: (context, index) => ListItem(
                          participant: _opposeParticipants![index],
                          submitMarking: _submitMarking,
                          isModetator: widget.isModerator),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  _marks({int marks = 0, String? title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(child: Text("$title:", style: TextStyle(fontSize: 20))),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("$marks/10", style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class ListItem extends StatefulWidget {
  final Participant participant;
  final Function submitMarking;
  final bool isModetator;
  ListItem({Key? key, required this.participant, required this.submitMarking, this.isModetator = false})
      : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  int _factMark = 0;
  int _argumentMark = 0;
  int _lawMark = 0;
  int _memoMark = 0;

  _markingButton({required Function()? onIncrease, required Function()? onDecrease, int marks = 0, String? title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(child: Text("$title:", style: TextStyle(fontSize: 20))),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            !widget.isModetator
                ? IconButton(onPressed: onDecrease, icon: Icon(Icons.remove_circle, size: 16, color: Colors.redAccent))
                : Container(),
            Text("$marks/10", style: TextStyle(fontSize: 12)),
            !widget.isModetator
                ? IconButton(onPressed: onIncrease, icon: Icon(Icons.add_circle, size: 16, color: Colors.green))
                : Container()
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    double _average = (_factMark + _argumentMark + _lawMark + _memoMark) / 4;
    return ExpansionTile(
      leading: DisplayPicture(
        url: participant.user?.avatar,
        name: participant.user?.fullName,
        radius: 20,
      ),
      title: Text(Util.capitalize("${participant.user?.fullName}")),
      onExpansionChanged: (value) {
        print(value);
        setState(() {
          _factMark = participant.marking?.factsPoints ?? 0;
          _argumentMark = participant.marking?.argumentPoints ?? 0;
          _lawMark = participant.marking?.lawsPoints ?? 0;
          _memoMark = participant.marking?.memoCount ?? 0;
          _average = (_factMark + _argumentMark + _lawMark + _memoMark) / 4;
        });
        if (!value) {
          print("May be the changes is not saved");
        }
      },
      children: [
        _markingButton(
          onIncrease: () => setState(() {
            if (_factMark <= 9) _factMark++;
          }),
          onDecrease: () => setState(() {
            if (_factMark >= 1) _factMark--;
          }),
          marks: _factMark,
          title: "Facts",
        ),
        _markingButton(
          onIncrease: () => setState(() {
            if (_lawMark <= 9) _lawMark++;
          }),
          onDecrease: () => setState(() {
            if (_lawMark >= 1) _lawMark--;
          }),
          marks: _lawMark,
          title: "Law",
        ),
        _markingButton(
          onIncrease: () => setState(() {
            if (_argumentMark <= 9) _argumentMark++;
          }),
          onDecrease: () => setState(() {
            if (_argumentMark >= 1) _argumentMark--;
          }),
          marks: _argumentMark,
          title: "Argument",
        ),
        _markingButton(
            onIncrease: () => setState(() {
                  if (_memoMark <= 9) _memoMark++;
                }),
            onDecrease: () => setState(() {
                  if (_memoMark >= 1) _memoMark--;
                }),
            marks: _memoMark,
            title: "Memo"),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.bottomRight,
          child: Text("Average:  $_average"),
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.8,
          margin: EdgeInsets.only(bottom: 0),
          child: CustomElevatedButton(
            onPressed: () => widget.submitMarking(
                participant.marking?.id, participant.id, _factMark, _lawMark, _argumentMark, _memoMark),
            child: Text(
              "Done",
              style: TextStyle(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
