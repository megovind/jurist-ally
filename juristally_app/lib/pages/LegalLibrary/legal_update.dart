import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/LegalProvider/legal_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/pages/SharedWidgets/pdf_view/pdf.dart';
import 'package:provider/provider.dart';
import 'package:juristally/models/auth_model.dart';

class LegalUpdates extends StatefulWidget {
  static const routename = "/LegalUpdates";
  LegalUpdates({Key? key}) : super(key: key);

  @override
  _LegalUpdatesState createState() => _LegalUpdatesState();
}

class _LegalUpdatesState extends State<LegalUpdates> {
  UserModel? _loggedUser;
  final _pagingController = PagingController<int, LegalUpdateModel>(firstPageKey: 1);
  static const _itemSize = 20;
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _pagingController.addPageRequestListener((pageKey) => _fetchLegalUpdate(pageKey));
  }

  Future<void> _fetchLegalUpdate(int index) async {
    try {
      final newUpdates = await Provider.of<LegalLibraryProvider>(context, listen: false)
          .fetchLegalUpdate(searchQuery: null, page: index);
      final isLastPage = newUpdates.length < _itemSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newUpdates);
      } else {
        final nextPageKey = index + 1;
        _pagingController.appendPage(newUpdates, nextPageKey);
      }
    } catch (e) {
      print(e);
      _pagingController.error = e;
    }
  }

  _searchString(valut) {}

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
                    "Legal Updates",
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
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: Container(
            child: PagedListView(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<LegalUpdateModel>(
                  itemBuilder: (BuildContext context, LegalUpdateModel legalupdate, int index) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPDF(
                            url: legalupdate.file,
                            title: legalupdate.title,
                          ),
                        ),
                      ),
                      child: Card(
                        color: Color(0XFFF2F2F2),
                        elevation: 2,
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.legend_toggle_sharp),
                          title: Text(Util.capitalize(
                              '${legalupdate.title!.length > 35 ? legalupdate.title!.substring(0, 35) : legalupdate.title!}'
                                  .trim())),
                          subtitle: Text('${legalupdate.description!.substring(0, 50)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 50,
                                child: VerticalDivider(
                                  color: Colors.grey,
                                ),
                              ),
                              Text(DateFormat.yM().format(legalupdate.passedOn ?? DateTime.now()))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ));
  }
}
