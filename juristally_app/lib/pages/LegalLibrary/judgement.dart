import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/LegalProvider/legal_library.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/pages/LegalLibrary/judgement_details.dart';
import 'package:provider/provider.dart';

class Judgements extends StatefulWidget {
  static const routename = "/Judgements";
  Judgements({Key? key}) : super(key: key);

  @override
  _JudgementsState createState() => _JudgementsState();
}

class _JudgementsState extends State<Judgements> {
  final _pagingController = PagingController<int, JudgementModel>(firstPageKey: 1);
  static const _itemSize = 20;
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) => _fetchJudgements(pageKey));
  }

  Future<void> _fetchJudgements(int index) async {
    try {
      final newItems = await Provider.of<LegalLibraryProvider>(context, listen: false)
          .fetchJudgements(searchQuery: null, page: index);
      final isLastPage = newItems.length < _itemSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = index + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      print(e);
      _pagingController.error = e;
    }
  }

  _searchString(String value) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
                  "Judgements",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => setState(() => _isSearch = !_isSearch),
            icon: Icon(
              _isSearch ? Icons.clear : Icons.search,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (BuildContext context, JudgementModel judgement, int index) => GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => JudgementDetails(judgement: judgement))),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    tileColor: Color(0XFFF2F2F2),
                    selectedTileColor: Colors.grey,
                    leading: Container(
                      height: 30,
                      width: 30,
                      color: Color(0XFFF2F2F2),
                      child: Center(child: Text("SC")),
                    ),
                    title: Text(Util.capitalize("${judgement.title}")),
                    subtitle: Text(
                        "${judgement.description!.length > 50 ? judgement.description!.substring(0, 50) : judgement.description}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 150,
                          child: VerticalDivider(
                            color: Colors.grey,
                          ),
                        ),
                        Column(
                          children: [
                            Text("DOJ:", style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text(
                              DateFormat.yM().format(judgement.dateOfJudgement ?? DateTime.now()),
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
