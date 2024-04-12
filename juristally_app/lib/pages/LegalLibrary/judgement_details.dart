import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:substring_highlight/substring_highlight.dart';

class JudgementDetails extends StatefulWidget {
  final JudgementModel judgement;
  JudgementDetails({Key? key, required this.judgement}) : super(key: key);

  @override
  _JudgementDetailsState createState() => _JudgementDetailsState();
}

class _JudgementDetailsState extends State<JudgementDetails> {
  JudgementModel? _judgementModel;
  List<String> _highlights = [];
  bool _isSearch = false;

  @override
  void initState() {
    _judgementModel = widget.judgement;
    super.initState();
  }

  _dynamicText({required String text}) {
    return SubstringHighlight(
        caseSensitive: false,
        textStyleHighlight: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
        terms: _highlights,
        text: text,
        textAlign: TextAlign.left,
        textStyle: TextStyle(color: Colors.black54, letterSpacing: 1),
        words: true);
  }

  _searchString(String searchString) {
    setState(() {
      _highlights = searchString.split(" ");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Wrap(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: _isSearch
                  ? TextField(
                      onChanged: (value) => _searchString(value),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: "Search...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                    )
                  : Container(
                      child: Text(
                        "Judgement details",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _isSearch = !_isSearch),
                  icon: Icon(
                    _isSearch ? Icons.clear : Icons.search,
                    color: Colors.black,
                  ),
                )
              ],
            ),
            _borderedContainer(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "${_judgementModel?.title}",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(blurRadius: 15, color: Colors.white),
                            Shadow(blurRadius: 5, color: Colors.black)
                          ],
                          fontSize: 30),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Criminal Appeal No. 132 of 1954 |25-01-1995",
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "(${_judgementModel!.courtName ?? "Juristally"})",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_add_outlined)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        "DOJ: ${DateFormat.yMEd().format(_judgementModel?.dateOfJudgement ?? DateTime.now())}",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
                      ),
                      style: OutlinedButton.styleFrom(primary: Colors.black54, shape: StadiumBorder()),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(primary: Colors.black54, shape: StadiumBorder()),
                      onPressed: () {},
                      child: Text(
                        'Advocates',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(primary: Colors.black54, shape: StadiumBorder()),
                      onPressed: () {},
                      child: Text(
                        "Judges",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ],
            )),
            _borderedContainer(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10),
                child: _dynamicText(
                    text: "Law Area Reffered: ${_judgementModel!.lawArea!.map((e) => e.title).join(", ")}"),
              ),
            ),
            _borderedContainer(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10),
                child: _dynamicText(text: "Sections Reffered: ${_judgementModel!.sections!.map((e) => e).join(", ")}"),
              ),
            ),
            _borderedContainer(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10),
                child: _dynamicText(
                    text: "Bare Acts Reffered: ${_judgementModel!.bareActs!.map((e) => e.title).join(", ")}"),
              ),
            ),
            _borderedContainer(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(10),
                child: _dynamicText(text: "Cited In: ${_judgementModel!.citedIn!.map((e) => e).join(", ")}"),
              ),
            ),
            _borderedContainer(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.9,
                child: _dynamicText(
                  text: _judgementModel?.content ?? "",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _borderedContainer({required Widget child}) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child);
  }
}
