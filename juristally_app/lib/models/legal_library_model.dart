import 'package:juristally/models/auth_model.dart';

List<LegalUpdateModel> listLegalUpdate(List<dynamic> list) => list.map((e) => LegalUpdateModel.fromJson(e)).toList();

class LegalUpdateModel {
  final String? id;
  final String? file;
  final String? title;
  final String? description;
  final DateTime? passedOn;
  final String? reference;
  final String? referenceLink;
  final String? lang;
  final List<PracticeArea>? lawArea;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LegalUpdateModel({
    this.id,
    this.title,
    this.file,
    this.description,
    this.passedOn,
    this.referenceLink,
    this.reference,
    this.lang,
    this.createdAt,
    this.lawArea,
    this.updatedAt,
    this.tags,
  });

  factory LegalUpdateModel.fromJson(Map<String, dynamic> json) {
    return LegalUpdateModel(
      id: json['_id'],
      title: json['title'],
      file: json['file'],
      passedOn: DateTime.parse(json['passed_on']),
      description: json['description'] ?? null,
      reference: json['reference'] ?? null,
      referenceLink: json['reference_link'] ?? null,
      lang: json['lang'],
      tags: json['tags'].length > 0 ? listString(json['tags']) : [],
      updatedAt: DateTime.parse(json['updated_at']),
      lawArea: json['law_area'].length > 0 ? listAreas(json['law_area']) : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

List<String> listString(List<dynamic> list) => list.map((e) => e.toString()).toList();

List<BareActModel> listBareActs(List<dynamic> list) => list.map((e) => BareActModel.fromJson(e)).toList();

class BareActModel {
  final String? id;
  final String? title;
  final String? description;
  final String? territory;
  final String? fileUrl;
  final List<String>? tags;
  final String? lang;

  BareActModel({
    this.id,
    this.title,
    this.description,
    this.territory,
    this.fileUrl,
    this.tags,
    this.lang,
  });

  factory BareActModel.fromJson(Map<String, dynamic> json) => BareActModel(
        id: json['_id'],
        title: json['bare_act_title'],
        fileUrl: json['file'],
        description: json['description'],
        tags: json['tags'].length > 0 ? listString(json['tags']) : [],
      );
}

List<JudgementModel> listJudgements(List<dynamic> list) => list.map((e) => JudgementModel.fromJson(e)).toList();

class JudgementModel {
  final String? id;
  final String? courtName;
  final String? judgeName;
  final String? title;
  final DateTime? dateOfJudgement;
  final String? description;
  final String? content;
  final String? reasoning;
  final String? decision;
  final String? lang;
  final List<String>? argumentPetitioner;
  final List<String>? argumentRespondent;
  final List<String>? tags;
  final List<String>? citedIn;
  final List<String>? citations;
  final List<String>? sections;
  final List<String>? issues;
  final List<String>? facts;
  final List<PracticeArea>? lawArea;
  final List<BareActModel>? bareActs;
  final List<Advocate>? advocates;
  final List<Bench>? bench;

  JudgementModel({
    this.id,
    this.courtName,
    this.judgeName,
    this.title,
    this.lang,
    this.dateOfJudgement,
    this.description,
    this.decision,
    this.reasoning,
    this.issues,
    this.content,
    this.advocates,
    this.argumentPetitioner,
    this.argumentRespondent,
    this.bareActs,
    this.bench,
    this.citations,
    this.citedIn,
    this.facts,
    this.lawArea,
    this.sections,
    this.tags,
  });
  factory JudgementModel.fromJson(Map<String, dynamic> json) => JudgementModel(
        id: json['_id'],
        courtName: json['court_name'],
        judgeName: json['judge_name'],
        title: json['title'],
        dateOfJudgement: DateTime.parse(json['date_of_judgement']),
        reasoning: json['reasoning'],
        decision: json['decision'],
        description: json['description'],
        content: json['content'],
        lawArea: json['law_area'].length > 0 ? listAreas(json['law_area']) : [],
        bareActs: json['bare_acts'].length > 0 ? listBareActs(json['bare_acts']) : [],
        argumentPetitioner: json['argument_petitioner'].length > 0 ? listString(json['argument_petitioner']) : [],
        argumentRespondent: json['argument_respondent'].length > 0 ? listString(json['argument_respondent']) : [],
        citedIn: json['cited_in'].length > 0 ? listString(json['cited_in']) : [],
        citations: json['citations'].length > 0 ? listString(json['citations']) : [],
        advocates: json['advocates'].length > 0 ? listAdvocates(json['advocates']) : [],
        bench: json['bench'].length > 0 ? listBenches(json['bench']) : [],
        sections: json['sections'].length > 0 ? listString(json['sections']) : [],
        issues: json['issues'].length > 0 ? listString(json['issues']) : [],
        facts: json['facts'].length > 0 ? listString(json['facts']) : [],
        tags: json['tags'].length > 0 ? listString(json['tags']) : [],
        lang: json['lang'],
      );
}

List<Advocate> listAdvocates(List<dynamic> list) => list.map((e) => Advocate.fromJson(e)).toList();

class Advocate {
  final String? name;
  final String? designation;
  final String? practiceCourt;

  Advocate({this.name, this.designation, this.practiceCourt});
  factory Advocate.fromJson(Map<String, dynamic> json) => Advocate(
        name: json['name'],
        designation: json['desigation'],
        practiceCourt: json['practice_court'],
      );
}

List<Bench> listBenches(List<dynamic> list) => list.map((e) => Bench.fromJson(e)).toList();

class Bench {
  final String? name;
  final String? court;

  Bench({this.name, this.court});
  factory Bench.fromJson(Map<String, dynamic> json) => Bench(
        name: json['name'],
        court: json['court'],
      );
}

List<Article> listArticle(List<dynamic> list) => list.map((e) => Article.fromJson(e)).toList();

class Article {
  final String? id;
  final UserModel? user;
  final String? quote;
  final String? content;
  final List<String>? bulletPoint;
  final List<String>? tags;
  final String? coverImage;
  final String? lang;
  final List<UserModel>? bookMarkedBy;
  final DateTime? createdAt;

  Article({
    this.id,
    this.quote,
    this.user,
    this.content,
    this.bulletPoint,
    this.tags,
    this.coverImage,
    this.bookMarkedBy,
    this.lang,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
      id: json['_id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      quote: json['quote'],
      content: json['content'],
      bulletPoint: json['bullet_points'].length > 0 ? listString(json['bullet_points']) : [],
      tags: json['tags'].length > 0 ? listString(json['tags']) : [],
      coverImage: json['cover_image'],
      bookMarkedBy: json['bookmarked_by'].length > 0 ? usersList(json['bookmarked_by']) : [],
      lang: json['lang'],
      createdAt: DateTime.parse(json['created_at']));
}
