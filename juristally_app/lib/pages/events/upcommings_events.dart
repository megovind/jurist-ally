import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:juristally/Providers/EventProvider/event_provider.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/pages/Profile/events-card.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:provider/provider.dart';

class UpcommingEvents extends StatefulWidget {
  final Function? changeTab;
  UpcommingEvents({Key? key, this.changeTab}) : super(key: key);

  @override
  _UpcommingEventsState createState() => _UpcommingEventsState();
}

class _UpcommingEventsState extends State<UpcommingEvents> {
  final _pagingController = PagingController<int, EventModel>(firstPageKey: 1);
  static const _pageSize = 20;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) => _fetchEvents(pageKey));
  }

  Future<void> _fetchEvents(int index) async {
    try {
      final newItems =
          await Provider.of<EventProvider>(context, listen: false).fetchEvents(page: index, status: "yet_to_start");
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

  _acceptInvitation(String event, String pid, bool accepting) async {
    Map<String, dynamic>? _data;
    try {
      setState(() {
        _isLoading = true;
        _data = {"invitation_accepted": accepting};
      });
      await Provider.of<EventProvider>(context, listen: false).acceptInvitation(event: event, pid: pid, data: _data);
      widget.changeTab!(1);
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Progressbar(
        inAsyncCall: _isLoading,
        child: Container(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: PagedListView(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<EventModel>(
                noItemsFoundIndicatorBuilder: (context) => Container(
                  child: Center(
                    child: Text(
                      "There is no events found!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                itemBuilder: (context, event, index) => EventsCard(event: event, acceptInvitation: _acceptInvitation),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
