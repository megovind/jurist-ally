import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';

List<NotificationModel> listNotifications(List<dynamic> list) =>
    list.map((e) => NotificationModel.fromJson(e)).toList();

class NotificationModel {
  final String? id;
  final UserModel? user;
  final String? notification;
  final EventModel? event;
  final String? redirectTo;
  final bool opened;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.user,
    this.notification,
    this.event,
    this.opened = false,
    this.createdAt,
    this.redirectTo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['_id'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        notification: json['notification'],
        event: json['event'] != null ? EventModel.fromJson(json['event']) : null,
        opened: json['event'],
        redirectTo: json['redirect_to'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
