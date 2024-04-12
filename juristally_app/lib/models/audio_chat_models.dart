import 'package:juristally/models/auth_model.dart';

List<Rooms> listRooms(List<dynamic> list) => list.map((e) => Rooms.fromJson(e)).toList();

class Rooms {
  final String? id;
  final String? roomId;
  final String? name;
  final List<ChatMembers>? members;
  final UserModel? creator;
  final ChatMessage? lastMessage;
  final bool isGroup;
  final String? roomToken;
  final DateTime? createdAt;
  final int unReadCount;

  Rooms({
    this.id,
    this.roomId,
    this.name,
    this.members,
    this.creator,
    this.lastMessage,
    this.isGroup = false,
    this.roomToken,
    this.createdAt,
    this.unReadCount = 0,
  });

  factory Rooms.fromJson(Map<String, dynamic> json) => Rooms(
      id: json['_id'],
      roomId: json['room_id'],
      name: json['name'],
      members: json['members'].length > 0 ? chatMembers(json['members']) : [],
      creator: UserModel.fromJson(json["creator"]),
      lastMessage: json['last_message'] != null ? ChatMessage.fromJson(json['last_message']) : null,
      isGroup: json['is_group'],
      roomToken: json['room_token'],
      createdAt: DateTime.parse(json['created_at']),
      unReadCount: json['unread_count'] != null ? json['unread_cound'] : 0);
}

List<ChatMembers> chatMembers(List<dynamic> list) => list.map((e) => ChatMembers.fromJson(e)).toList();

class ChatMembers {
  final UserModel? user;
  final String? role;

  ChatMembers({this.user, this.role});

  factory ChatMembers.fromJson(Map<String, dynamic> json) => ChatMembers(
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        role: json['role'],
      );
}

List<ChatMessage> listMessages(List<dynamic> list) => list.map((e) => ChatMessage.fromJson(e)).toList();

class ChatMessage {
  final String? id;
  final String? groupId;
  final String? roomId;
  final UserModel? user;
  final String? audioMsg;
  final String? txtMsg;
  final List<Media>? media;
  final bool status;

  ChatMessage({
    this.id,
    this.groupId,
    this.roomId,
    this.user,
    this.audioMsg,
    this.txtMsg,
    this.media,
    this.status = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['_id'],
        groupId: json['group_id'],
        roomId: json['room_id'],
        user: UserModel.fromJson(json['user']),
        audioMsg: json['audio_msg'],
        txtMsg: json['txt_msg'],
        media: json['media'].length > 0 ? listMedia(json['media']) : [],
        status: json['status'],
      );
}

List<Media> listMedia(List<dynamic> list) => list.map((e) => Media.fromJson(e)).toList();

class Media {
  final String? type;
  final String? mediaUrl;

  Media({this.type, this.mediaUrl});
  factory Media.fromJson(Map<String, dynamic> json) => Media(
        type: json['type'],
        mediaUrl: json['media_url'],
      );
}
