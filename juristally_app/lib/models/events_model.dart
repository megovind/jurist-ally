import 'package:juristally/models/auth_model.dart';

List<EventModel> listEvents(List<dynamic> list) => list.map((e) => EventModel.fromJson(e)).toList();

class EventModel {
  final String? id;
  final UserModel? moderator;
  final UserModel? coModerator;
  final String? recordingUrl;
  final String? type;
  final bool isLive;
  final String? topic;
  final DateTime? commenceDate;
  final String? bannerImage;
  final String? proposition;
  final String? status;
  final String? guidelines;
  final bool isPublic;
  final List<Participant>? participants;
  final List<UserModel>? likes;
  final List<UserModel>? favourLikes;
  final List<UserModel>? opposeLikes;
  final List<AudioComments>? audioComments;
  final List<EventDocuments>? documents;
  final List<Participant>? requestsToTalk;
  final bool audiencesAllowed;
  final bool saved;
  final bool archived;
  final DateTime? createdAt;

  EventModel({
    this.id,
    this.topic,
    this.commenceDate,
    this.isPublic = false,
    this.audioComments,
    this.favourLikes,
    this.opposeLikes,
    this.likes,
    this.participants,
    this.status,
    this.recordingUrl,
    this.guidelines,
    this.bannerImage,
    this.proposition,
    this.coModerator,
    this.isLive = false,
    this.moderator,
    this.type,
    this.documents,
    this.audiencesAllowed = false,
    this.requestsToTalk,
    this.createdAt,
    this.saved = false,
    this.archived = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'],
      moderator: json['moderator'] != null ? UserModel.fromJson(json['moderator']) : null,
      coModerator: json['co_moderator'] != null ? UserModel.fromJson(json['co_moderator']) : null,
      commenceDate: DateTime.parse(json['commence_date']),
      recordingUrl: json['final_recording'],
      guidelines: json['guidelines'] ?? null,
      proposition: json['proposition'] ?? null,
      bannerImage: json['banner_image'] ?? null,
      saved: json['saved'] ?? false,
      archived: json['archived'] ?? false,
      type: json['type'] ?? null,
      isLive: json['is_live'] ?? false,
      topic: json['event_topic'] ?? null,
      isPublic: json['is_public'] ?? false,
      status: json['status'] ?? null,
      participants: json['participants'].length > 0 ? listParticipants(json['participants']) : [],
      requestsToTalk: json['requests_to_talk'].length > 0 ? listParticipants(json['requests_to_talk']) : [],
      favourLikes: json['favour_likes'].length > 0 ? usersList(json['favour_likes']) : [],
      opposeLikes: json['oppose_likes'].length > 0 ? usersList(json['oppose_likes']) : [],
      likes: json['likes'].length > 0 ? usersList(json['likes']) : [],
      documents: json['documents'].length > 0 ? listEventDocuments(json['documents']) : [],
      audioComments: json['audio_comments'].length > 0 ? listAudioComments(json['audio_comments']) : [],
      audiencesAllowed: json['audiences_allowed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

List<EventDocuments> listEventDocuments(List<dynamic> list) => list.map((e) => EventDocuments.fromJson(e)).toList();

class EventDocuments {
  final String? fileUrl;
  final String? itIsFor;
  final String? type;

  EventDocuments({this.fileUrl, this.itIsFor, this.type});

  factory EventDocuments.fromJson(Map<String, dynamic> json) => EventDocuments(
        fileUrl: json['doc'] ?? null,
        itIsFor: json['is_it_for'] ?? null,
        type: json['type'] ?? null,
      );
}

List<Participant> listParticipants(List<dynamic> list) => list.map((e) => Participant.fromJson(e)).toList();

class Participant {
  final String? id;
  final String? event;
  final String? status;
  final UserModel? user;
  final String? type;
  final DateTime? joinedAt;
  final Marking? marking;
  final bool handRaised;
  final bool invitationAccepted;
  bool isSpeaking;
  bool isMute;
  final List<UserModel>? audienceVotes;

  Participant({
    this.id,
    this.event,
    this.status,
    this.user,
    this.type,
    this.joinedAt,
    this.marking,
    this.handRaised = false,
    this.isSpeaking = false,
    this.isMute = true,
    this.invitationAccepted = false,
    this.audienceVotes,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'],
      event: json['event'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      type: json['type'] ?? null,
      isMute: json['is_mute'] != null ? json['is_mute'] : false,
      invitationAccepted: json['invitation_accepted'] != null ? json['invitation_accepted'] : false,
      // joinedAt: DateTime.parse(json['joined_at']),
      marking: json['judge_marking'] != null ? Marking.fromJson(json['judge_marking']) : null,
      handRaised: json['raised_hand'] ?? false,
      audienceVotes: json['audience_votes'].length > 0 ? usersList(json['audience_votes']) : [],
    );
  }
}

class Marking {
  final String? id;
  final String? participantId;
  final int factsPoints;
  final int lawsPoints;
  final int argumentPoints;
  final int memoCount;
  final int average;

  Marking({
    this.id,
    this.participantId,
    this.factsPoints = 0,
    this.lawsPoints = 0,
    this.argumentPoints = 0,
    this.memoCount = 0,
    this.average = 0,
  });

  factory Marking.fromJson(Map<String, dynamic> json) => Marking(
      id: json["_id"],
      participantId: json['participant'] ?? null,
      factsPoints: json['facts'] ?? 0,
      lawsPoints: json['laws'] ?? 0,
      argumentPoints: json['argument'] ?? 0,
      memoCount: json['memo'] ?? 0,
      average: json['average'] ?? 0);
}

List<AudioComments> listAudioComments(List<dynamic> list) => list.map((e) => AudioComments.fromJson(e)).toList();

class AudioComments {
  final String? id;
  final UserModel? user;
  final String? audio;
  final List<AudioComments>? replies;
  final DateTime? commentedAt;

  AudioComments({this.id, this.user, this.audio, this.replies, this.commentedAt});

  factory AudioComments.fromJson(Map<String, dynamic> json) => AudioComments(
        id: json['_id'],
        user: UserModel.fromJson(json['user']),
        audio: json['audio'] ?? null,
        replies: json['replies'].length > 0 ? listAudioComments(json['replies']) : [],
        commentedAt: DateTime.parse(json['created_at']),
      );
}
