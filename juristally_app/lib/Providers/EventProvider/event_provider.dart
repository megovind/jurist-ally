import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:juristally/Providers/uploadfile.dart';
import 'package:juristally/data/network/api_urls.dart';
import 'package:juristally/data/network/apiservicecall.dart';
import 'package:juristally/models/events_model.dart';

class EventProvider with ChangeNotifier {
  EventModel _event = EventModel();
  List<EventModel> _events = [];

  Future<EventModel> createEvent({String? id, Map<String, dynamic>? data}) async {
    try {
      if (data!['banner'] != null) {
        final file = await UploadFile().uploadFile(data['banner'], resize: data['resize']);
        data['banner_image'] = file['file_url'];
        data['banner'] = null;
      }
      if (data['props'] != null) {
        final propsResponse = await UploadFile().uploadFile(data['props']);
        data['proposition'] = propsResponse['file_url'];
        data['props'] = null;
      }
      if (data['recorded_file'] != null) {
        final recordedResponse = await UploadFile().uploadFile(data['recored_file']);
        data['final_recording'] = recordedResponse['file_url'];
        data['recorded_file'] = null;
      }
      final url = id != null ? "${ApiUrls.UPDATE_EVENT}/$id" : ApiUrls.CREATE_EVENT;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      final newEvent = EventModel.fromJson(response['response']);
      _event = newEvent;
      if (id != null) {
        final index = _events.indexWhere((el) => el.id == id);
        _events.removeAt(index);
        _events.insert(index, newEvent);
      } else {
        _events.insert(0, newEvent); //= listEvents(response['response']);
      }
      notifyListeners();
      return _event;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<EventModel>> fetchEvents({String? id, int? page, String? status, String? uid}) async {
    try {
      var url;
      if (status != null) {
        url = "${ApiUrls.FETCH_EVENTS}?status=$status";
      } else {
        if (uid != null) {
          url = "${ApiUrls.FETCH_EVENTS}?uid=$uid";
        } else {
          url = ApiUrls.FETCH_EVENTS;
        }
      }
      final response = await ApiServiceCall().getReques(url: url);
      _events = response.length > 0 ? listEvents(response['response']) : [];
      notifyListeners();
      return _events;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> uploadDocuemts({String? event, Map<String, dynamic>? data, File? file}) async {
    try {
      if (file != null) {
        final _file = await UploadFile().uploadFile(file);
        data!['doc'] = _file['file_url'];
      }
      final url = "${ApiUrls.UPLOAD_DOCUMENTS}/$event";
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      final _newEvent = EventModel.fromJson(response['response']);
      _event = _newEvent;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<Participant> addParticipant({String? id, Map<String, dynamic>? data}) async {
    try {
      final url = "${ApiUrls.ADD_PARTICIPANT}?event=$id";
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      final participant = Participant.fromJson(response['response']);
      _event.participants!.add(participant);
      notifyListeners();
      return participant;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> acceptInvitation({String? event, String? pid, Map<String, dynamic>? data}) async {
    try {
      final url = "${ApiUrls.ACCEPT_INVITATION}?event=$event&pid=$pid";
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      // _event;
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeParticipant({String? id, String? event}) async {
    try {
      final url = "${ApiUrls.REMOVE_PARTICIPANT}/$id?event=$event";
      await ApiServiceCall().postRequest(url: url);
      _event.participants!.removeWhere((el) => el.id == id);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<AudioComments> commentOnEvent({String? event, String? commentId, Map<String, dynamic>? data}) async {
    try {
      final url = "${ApiUrls.AUDIO_COMMENT_EVENT}/$event";
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      AudioComments comment = AudioComments.fromJson(response['response']);
      return comment;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> likeUnlikeEvent({String? event}) async {
    try {
      final url = "${ApiUrls.LIKE_UNLIKE_EVENT}/$event";
      final response = await ApiServiceCall().postRequest(url: url);
      bool liked = response['liked'];
      return liked;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Marking> markingByJudges({String? id, Map<String, dynamic>? data}) async {
    try {
      final url = "${ApiUrls.ADD_UPDATE_MARKING}?mid=$id";
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      Marking marking = Marking.fromJson(response['response']);
      return marking;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
