import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/helper/file_upload.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/SharedWidgets/pdf_view/pdf.dart';
import 'package:provider/provider.dart';

class DocumentsPage extends StatefulWidget {
  final EventModel? event;
  DocumentsPage({Key? key, required this.event}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _isLoading = false;
  Map<String, dynamic> _formData = {};
  EventDocuments? _opposeMemo;
  EventDocuments? _favourMemo;
  List<EventDocuments> _opposeEvidence = [];
  List<EventDocuments> _favourEvidence = [];
  EventModel? _event;
  UserModel? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _event = widget.event;
    _favourMemo = _event?.documents
        ?.firstWhere((el) => el.type == 'memo' && el.itIsFor == 'favour', orElse: () => EventDocuments());
    _opposeMemo = _event?.documents
        ?.firstWhere((el) => el.type == 'memo' && el.itIsFor == 'oppose', orElse: () => EventDocuments());
    _favourEvidence = _event!.documents!.where((el) => el.type == 'evidence' && el.itIsFor == 'favour').toList();
    _opposeEvidence = _event!.documents!.where((el) => el.type == 'evidence' && el.itIsFor == 'oppose').toList();
  }

  _uploadDocument({String? type, File? file, String? isitFor}) async {
    try {
      setState(() {
        _isLoading = true;
        _formData['type'] = type;
        _formData['is_it_for'] = isitFor;
      });
      await Provider.of<EventProvider>(context).uploadDocuemts(event: _event?.id, data: _formData, file: file);
    } catch (e) {
      print("SOME PROBLEM OCCURED: $e");
    }
    setState(() => _isLoading = false);
  }

  bool _isInFavour() =>
      _event!.participants!.indexWhere((el) => el.type == 'favour' && el.user!.id == _loggedInUser!.id) > -1;
  bool _isInOppose() =>
      _event!.participants!.indexWhere((el) => el.type == 'oppose' && el.user!.id == _loggedInUser!.id) > -1;
  bool _isJudge() =>
      _event!.participants!.indexWhere((el) => el.type == 'judge' && el.user!.id == _loggedInUser!.id) > -1;
  bool _isModerator() => _event!.moderator?.id == _loggedInUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documents"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(title: "Event Props"),
            _documentRow(title: "Proposition", docUrl: _event?.proposition),
            _heading(title: "favour Memo"),
            _favourMemo != null && _favourMemo?.fileUrl != null
                ? _documentRow(title: "Memo", docUrl: _favourMemo?.fileUrl)
                : _isJudge() || _isModerator()
                    ? _notFound()
                    : _uploadDoc(type: "memo", title: "Memo", isItFor: "favour"),
            _heading(title: "Oppose  Memo"),
            _opposeMemo != null && _opposeMemo?.fileUrl != null
                ? _documentRow(title: "Memo", docUrl: _opposeMemo?.fileUrl)
                : _isJudge() || _isModerator()
                    ? _notFound()
                    : _uploadDoc(type: "memo", title: "Memo", isItFor: "oppose"),
            _heading(title: "Favour Evidence's"),
            _favourEvidence.length > 0
                ? Container(
                    child: ListView.builder(
                      itemCount: _favourEvidence.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _documentRow(title: "Evidence #$index", docUrl: _favourEvidence[index].fileUrl),
                    ),
                  )
                : _notFound(),
            _isJudge() || _isModerator() || _isInOppose()
                ? Container()
                : _uploadDoc(type: "evidence", title: "Evidence", isItFor: "favour"),
            _heading(title: "Oppose Evidence's"),
            _opposeEvidence.length > 0
                ? Container(
                    child: ListView.builder(
                      itemCount: _opposeEvidence.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _documentRow(title: "Evidence #$index", docUrl: _opposeEvidence[index].fileUrl),
                    ),
                  )
                : _notFound(),
            _isJudge() || _isModerator() || _isInFavour()
                ? Container()
                : _uploadDoc(type: "evidence", title: "Evidence", isItFor: "oppose")
          ],
        ),
      ),
    );
  }

  _heading({required String title}) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Text(
        "$title",
        style: TextStyle(letterSpacing: 1, fontSize: 20),
      ),
    );
  }

  _notFound() => Container(
      alignment: Alignment.center, child: Text("Document Not uploaded", style: TextStyle(color: Colors.grey)));

  File? _selectedFile;
  _uploadDoc({String? type, String? title, String? isItFor}) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final file = await selectSingleFile(types: ['pdf']);
              setState(() => _selectedFile = file);
            },
            child: Text(
              _selectedFile != null ? "${_selectedFile!.path.split("/").last}" : "Select File($title)",
              style: TextStyle(color: Colors.blue.shade200),
            ),
          ),
          _isLoading
              ? Container(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () => _uploadDocument(type: type, file: _selectedFile, isitFor: isItFor),
                  child: Text("Upload", style: TextStyle(color: Colors.black)))
        ],
      ),
    );
  }

  _documentRow({String? title, String? docUrl}) {
    return docUrl != null
        ? Container(
            child: ListTile(
              leading: Icon(CupertinoIcons.doc),
              title: Text("$title"),
              trailing: IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPDF(url: docUrl))),
                icon: Icon(CupertinoIcons.eye),
              ),
            ),
          )
        : _notFound();
  }
}
