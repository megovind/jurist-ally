import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';
import 'package:juristally/models/notification_models.dart';
import 'package:juristally/pages/SharedWidgets/display-picture.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  static const routename = "/notification-page";
  NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _pagingController = PagingController<int, NotificationModel>(firstPageKey: 1);
  int _pageSize = 20;
  UserModel? _loggedUser;

  @override
  void initState() {
    super.initState();
    _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    _pagingController.addPageRequestListener((pageKey) => _fetchEvents(pageKey));
  }

  Future<void> _fetchEvents(int index) async {
    try {
      final newItems = await Provider.of<AuthProvider>(context, listen: false).fetchNotifications(page: index);
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

  _acceptOrIgnore({String? pid, bool isAccept = false}) {}

  _updateNotification({String? nid}) async {
    await Provider.of<AuthProvider>(context, listen: false).updateNotification(nId: nid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.black),
        ),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, NotificationModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, notification, index) => _notificationlistcard(notification: notification),
            ),
          ),
        ),
      ),
    );
  }

  Participant? _isParticipant({required List<Participant>? participants}) =>
      participants!.firstWhere((el) => el.user?.id == _loggedUser?.id);

  _notificationlistcard({NotificationModel? notification}) {
    return GestureDetector(
      onTap: () => _updateNotification(nid: notification?.id),
      child: Card(
        elevation: 10,
        color: notification!.opened ? Colors.white : Color(0xfff2f2f2),
        child: Wrap(
          children: [
            ListTile(
              leading: DisplayPicture(
                url: notification.user?.avatar,
                name: notification.user?.fullName,
                userId: notification.id,
                radius: 30,
              ),
              title: notification.event?.topic != null
                  ? Text(notification.event?.topic ?? "")
                  : Text(notification.notification ?? "", style: TextStyle(color: Colors.white70)),
              subtitle: notification.event?.topic != null
                  ? Text(notification.notification ?? "", style: TextStyle(color: Colors.white70))
                  : Container(),
              trailing: Text(
                DateFormat.yMEd().format(notification.createdAt ?? DateTime.now()),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            notification.event!.participants!.length > 0
                ? Container(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: notification.event!.participants!.length,
                      itemBuilder: (context, index) {
                        final _participant = notification.event!.participants![index];
                        return DisplayPicture(
                          url: _participant.user?.avatar,
                          name: _participant.user?.fullName,
                          userId: _participant.id,
                          radius: 20,
                        );
                      },
                    ),
                  )
                : Container(),
            _isParticipant(participants: notification.event!.participants)?.user!.id == _loggedUser!.id
                ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomElevatedButton(
                          verticalPadding: 5,
                          horizontalPadding: 20,
                          onPressed: () {
                            final _part = _isParticipant(participants: notification.event!.participants);
                            _acceptOrIgnore(pid: _part?.id, isAccept: false);
                          },
                          child: Text("Ignore", style: TextStyle(color: Colors.black)),
                        ),
                        CustomElevatedButton(
                            onPressed: () {
                              final _part = _isParticipant(participants: notification.event!.participants);
                              _acceptOrIgnore(pid: _part?.id, isAccept: true);
                            },
                            child: Text("Accepts", style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
