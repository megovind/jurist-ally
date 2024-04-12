List<UserModel> usersList(List<dynamic> list) => list.map((e) => UserModel.fromJson(e)).toList();

class UserModel {
  final int uid;
  final String? id;
  final String? fullName;
  final String? designation;
  final String? type;
  final String? courtPractice;
  final String? phoneNUmber;
  final String? email;
  final bool phoneVerified;
  final bool emailVerified;
  final String? avatar;
  final String? coverImage;
  final String? summary;
  final String? membeshipEnrollmentNumber;
  final Location? location;
  final List<EducationModel>? educations;
  final List<ExperienceModel>? expereinces;
  final List<AchievementModel>? achievements;
  final List<PracticeArea>? practiceArea;
  Connections? connections;
  final bool isActive;

  UserModel({
    this.uid = 0,
    this.id,
    this.email,
    this.phoneNUmber,
    this.designation,
    this.avatar,
    this.courtPractice,
    this.coverImage,
    this.fullName,
    this.emailVerified = false,
    this.location,
    this.membeshipEnrollmentNumber,
    this.phoneVerified = false,
    this.summary,
    this.type,
    this.educations,
    this.expereinces,
    this.achievements,
    this.isActive = false,
    this.connections,
    this.practiceArea,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'],
        uid: json['uid'] != null ? json['uid'] : 0,
        type: json['type'] ?? null,
        fullName: json['full_name'] ?? null,
        email: json['email'] ?? null,
        designation: json['designation'] ?? null,
        phoneNUmber: json['phone_number'] != null ? json['phone_number'].toString() : null,
        avatar: json['avatar'] ?? null,
        coverImage: json['cover_image'] ?? null,
        summary: json['summary'] ?? null,
        emailVerified: json['email_verified'] != null ? json['email_verified'] : false,
        phoneVerified: json['phone_number_verified'] != null ? json['phone_number_verified'] : false,
        isActive: json['is_active'] != null ? json['is_active'] : false,
        membeshipEnrollmentNumber: json['membership_enrollment_number'] ?? json['membership_enrollment_number'],
        location: json['location'] != null ? Location.fromJson(json['location']) : null,
        educations: json['education'] != null ? eduList(json['education']) : [],
        expereinces: json['experience'] != null ? expList(json['experience']) : [],
        achievements: json['achievements'] != null ? achievementList(json['achievements']) : [],
        practiceArea: json['practice_area'] != null ? listAreas(json['practice_area']) : [],
        connections: json['connections'] != null ? Connections.fromJson(json['connections']) : null,
      );
}

List<String> listStrings(List<dynamic> list) => list.map((e) => e.toString()).toList();

List<PracticeArea> listAreas(List<dynamic> list) => list.map((e) => PracticeArea.fromJson(e)).toList();

class PracticeArea {
  final String? id;
  final String? title;
  final String? lang;
  final List<String>? tags;
  PracticeArea({this.id, this.title, this.lang, this.tags});

  factory PracticeArea.fromJson(Map<String, dynamic> json) => PracticeArea(
        id: json['_id'],
        title: json['title'] ?? null,
        lang: json['lang'] ?? null,
        tags: listStrings(json['tags']),
      );
}

class Location {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? place;
  Location({this.address, this.latitude, this.longitude, this.place});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        address: json['address'] ?? null,
        latitude: json['latitude'] ?? null,
        longitude: json['longitude'] ?? null,
        place: json['place_name'] ?? null,
      );
}

List<EducationModel> eduList(List<dynamic> list) => list.map((e) => EducationModel.fromJson(e)).toList();

class EducationModel {
  final String? id;
  final String? instituteName;
  final String? degree;
  final DateTime? startDate;
  final bool isPursuing;
  final DateTime? endDate;
  final Location? location;

  EducationModel({
    this.id,
    this.instituteName,
    this.degree,
    this.startDate,
    this.isPursuing = false,
    this.endDate,
    this.location,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) => EducationModel(
        id: json['_id'],
        instituteName: json['institute_name'] ?? null,
        degree: json['stream'] ?? null,
        startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
        isPursuing: json['is_present'] ?? false,
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        location: json['location'] != null ? Location.fromJson(json['location']) : null,
      );
}

List<ExperienceModel> expList(List<dynamic> list) => list.map((e) => ExperienceModel.fromJson(e)).toList();

class ExperienceModel {
  final String? id;
  final String? position;
  final String? type;
  final String? company;
  final DateTime? startDate;
  final bool isCurrently;
  final DateTime? endDate;
  final Location? location;

  ExperienceModel({
    this.id,
    this.position,
    this.type,
    this.company,
    this.startDate,
    this.isCurrently = false,
    this.endDate,
    this.location,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['_id'],
      position: json['designation'] ?? null,
      type: json['type'] ?? null,
      company: json['company_name'] ?? null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isCurrently: json['is_present'] ?? false,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }
}

List<AchievementModel> achievementList(List<dynamic> list) => list.map((e) => AchievementModel.fromJson(e)).toList();

class AchievementModel {
  final String? id;
  final String? eventName;
  final DateTime? date;
  final String? description;
  final Location? location;

  AchievementModel({
    this.id,
    this.eventName,
    this.date,
    this.description,
    this.location,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
        id: json['_id'],
        eventName: json['event_name'] ?? null,
        date: DateTime.parse(json['date']),
        description: json['description'] ?? null,
        location: json['location'] != null ? Location.fromJson(json['location']) : null,
      );
}

class Connections {
  final String? id;
  final String? userId;
  final List<UserModel>? followers;
  final List<UserModel>? allies;
  final List<UserModel>? votes;

  Connections({this.id, this.userId, this.followers, this.allies, this.votes});

  factory Connections.fromJson(Map<String, dynamic> json) => Connections(
        id: json["_id"],
        userId: json['user'] ?? null,
        followers: json['followers'].length > 0 ? usersList(json['followers']) : [],
        allies: json['allies'].length > 0 ? usersList(json['allies']) : [],
        // votes: usersList(json['votes']),
      );
}
