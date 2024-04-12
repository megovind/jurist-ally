import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:juristally/Providers/LegalProvider/legal_library.dart';
import 'package:juristally/helper/strings_format.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/pages/SharedWidgets/pdf_view/pdf.dart';
import 'package:provider/provider.dart';

class BareActPage extends StatefulWidget {
  static const routeName = "/Bareact";
  BareActPage({Key? key}) : super(key: key);

  @override
  _BareActPageState createState() => _BareActPageState();
}

class _BareActPageState extends State<BareActPage> {
  final _pagingController = PagingController<int, BareActModel>(firstPageKey: 1);
  static const _itemSize = 20;
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) => _fetchBareActs(pageKey));
  }

  Future<void> _fetchBareActs(int index) async {
    try {
      final newItems =
          await Provider.of<LegalLibraryProvider>(context, listen: false).fetchBareActs(searchQuery: null, page: index);
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
                  "Bare Acts",
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
              itemBuilder: (BuildContext context, BareActModel bareAct, int index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPDF(url: bareAct.fileUrl, title: bareAct.title),
                    ),
                  ),
                  child: Card(
                    color: Color(0XFFF2F2F2),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.legend_toggle_sharp),
                      title: Text(Util.capitalize(
                          "${bareAct.title!.length > 30 ? bareAct.title!.substring(0, 30) : bareAct.title}")),
                      subtitle: Text(
                          "${bareAct.description!.length > 50 ? bareAct.description!.substring(0, 50) : bareAct.description}"),
                      trailing: bareAct.territory != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 50,
                                  child: VerticalDivider(
                                    color: Colors.grey,
                                  ),
                                ),
                                Text("${bareAct.territory}")
                              ],
                            )
                          : Container(height: 0, width: 0),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
