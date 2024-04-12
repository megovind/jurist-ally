import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/Providers/SmallTalkProvider/smalltalk_provider.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/small_talk_model.dart';
import 'package:juristally/pages/events/create-event.dart';
import 'package:juristally/pages/Profile/debate-moot-card.dart';
import 'package:juristally/pages/Profile/smalltalk-card.dart';
import 'package:provider/provider.dart';

class OnGoingEvents extends StatefulWidget {
  static const routeName = "/ongoing-events";
  OnGoingEvents({Key? key}) : super(key: key);

  @override
  _OnGoingEventsState createState() => _OnGoingEventsState();
}

class _OnGoingEventsState extends State<OnGoingEvents> {
  bool _create = false;
  final _pagingController = PagingController(firstPageKey: 1);
  final _scrollController = ScrollController();
  static const _pageSize = 20;
  bool _isLoadingTalks = false;
  UserModel? _loggedUser;
  List<SmallTalkModel>? _smallTalks = [];

  @override
  void initState() {
    super.initState();
    _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _pagingController.addPageRequestListener((pageKey) => _fetchEvents(pageKey));
    _scrollController.addListener(_scrollListner);
    _fetchSmallTalks();
  }

  _scrollListner() {
    print("SCROLLING");
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchEvents(int index) async {
    try {
      final newItems =
          await Provider.of<EventProvider>(context, listen: false).fetchEvents(page: index, status: "live");
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = index + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  _fetchSmallTalks() async {
    setState(() => _isLoadingTalks = true);
    try {
      await Provider.of<SmallTalkProvider>(context, listen: false).fetchSmallTalks();
      final talks = Provider.of<SmallTalkProvider>(context, listen: false).smallTalks;
      setState(() => _smallTalks = talks);
    } catch (e) {
      print("EXPETION:: $e");
    }
    setState(() => _isLoadingTalks = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _create
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white30,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEvent(type: "letsTalk"),
                              ),
                            ),
                        child: Text("Lets Talk")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white30,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEvent(type: "debate"),
                          )),
                      child: Text("Debate"),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white30,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEvent(type: "moot"),
                            )),
                        child: Text("Moot")),
                  ],
                )
              : Container(height: 0, width: 0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () => setState(() => _create = !_create),
            child: Text(
              "Create",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Container(
        child: RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: PagedListView.separated(
              pagingController: _pagingController,
              // scrollController: _scrollController,
              builderDelegate: PagedChildBuilderDelegate(
                noItemsFoundIndicatorBuilder: (context) => Container(
                  child: Center(
                    child: Text(
                      "There is no events found!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                itemBuilder: (context, object, index) => Container(
                    padding: EdgeInsets.only(top: index != 0 ? 16 : 0, left: 0, right: 0, bottom: 10),
                    child: DebateMootCard(eventModel: _pagingController.itemList![index]) //Text("Seperator delelgate"),
                    ),
              ),

              separatorBuilder: (context, index) => _isLoadingTalks
                  ? Container(child: CircularProgressIndicator())
                  : _smallTalks!.length > 0
                      ? Container(
                          padding: EdgeInsets.only(top: 10),
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _smallTalks?.length,
                            itemBuilder: (context, index) => SmallTalkCard(smallTalk: _smallTalks![index]),
                          ),
                        )
                      : Container(height: 0, width: 0),
            )),
      ),
    );
  }
}
