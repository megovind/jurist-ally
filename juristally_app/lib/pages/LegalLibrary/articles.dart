import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:juristally/Providers/LegalProvider/legal_library.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/pages/Profile/article-card.dart';
import 'package:provider/provider.dart';

class Articles extends StatefulWidget {
  static const routename = "/Articles";
  Articles({Key? key}) : super(key: key);

  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  final _pagingController = PagingController<int, Article>(firstPageKey: 1);
  int _itemSize = 20;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) => _fetchArticles(pageKey));
  }

  Future<void> _fetchArticles(int index) async {
    try {
      final newItems =
          await Provider.of<LegalLibraryProvider>(context, listen: false).fetchArticles(searchQuery: null, page: index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView(
          pagingController: _pagingController,
          builderDelegate:
              PagedChildBuilderDelegate<Article>(itemBuilder: (BuildContext context, Article article, int index) {
            return ArticleCard(
              article: article,
            );
          }),
        ),
      ),
    );
  }
}
