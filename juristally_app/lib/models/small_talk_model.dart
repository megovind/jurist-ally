import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/events_model.dart';

List<SmallTalkModel> smalltalkList(List<dynamic> list) => list.map((e) => SmallTalkModel.fromJson(e)).toList();

class SmallTalkModel {
  final String? id;
  final UserModel? user;
  final String? audioClip;
  final String? lyrics;
  final String? title;
  final String? cover;
  final List<UserModel>? likes;
  final List<UserModel>? heardBy;
  final List<AudioComments>? audioComments;
  final List<String>? tags;
  final String? availableTo;
  final String? savedAs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SmallTalkModel({
    this.id,
    this.user,
    this.audioClip,
    this.lyrics,
    this.title,
    this.likes,
    this.cover,
    this.audioComments,
    this.heardBy,
    this.tags,
    this.availableTo,
    this.savedAs,
    this.createdAt,
    this.updatedAt,
  });

  factory SmallTalkModel.fromJson(Map<String, dynamic> json) {
    // print(json['heard_by']);
    return SmallTalkModel(
      id: json['_id'],
      user: UserModel.fromJson(json['user']),
      audioClip: json['audio_clip'] ?? null,
      lyrics: json['lyrics'],
      title: json['title'] ?? null,
      cover: json['cover'],
      likes: json['likes'].length > 0 ? usersList(json['likes']) : [],
      heardBy: json['heard_by'] != null && json['heard_by'].length > 0 ? usersList(json['heard_by']) : [],
      audioComments: json['audio_comments'].length > 0 ? listAudioComments(json['audio_comments']) : [],
      tags: json['tags'] != null ? taglistString(json['tags']) : [],
      availableTo: json['available_to'] ?? null,
      savedAs: json['saved_as'] ?? null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

List<String> taglistString(List<dynamic> list) => list.map((e) => e.toString()).toList();
