import 'package:flutter/material.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/data/network/api_urls.dart';
import 'package:juristally/data/network/apiservicecall.dart';

class LegalLibraryProvider with ChangeNotifier {
  Future<List<BareActModel>> fetchBareActs({String? searchQuery, int page = 1}) async {
    try {
      final url = searchQuery != null
          ? '${ApiUrls.FETCH_BARE_ACTS}?page_size=20&page=$page&search=$searchQuery'
          : '${ApiUrls.FETCH_BARE_ACTS}?page_size=20&page=$page';
      final response = await ApiServiceCall().postRequest(url: url);
      List<BareActModel> _bareActModel = listBareActs(response['response']);
      return _bareActModel;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<LegalUpdateModel>> fetchLegalUpdate({String? searchQuery, int page = 1}) async {
    try {
      final url = searchQuery != null
          ? '${ApiUrls.FETCH_LEGAL_UPDATES}?page_size=20&page=$page&search=$searchQuery'
          : '${ApiUrls.FETCH_LEGAL_UPDATES}?page_size=20&page=$page';
      final response = await ApiServiceCall().postRequest(url: url);
      List<LegalUpdateModel> _legalUpdates = listLegalUpdate(response['response']);
      return _legalUpdates;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<JudgementModel>> fetchJudgements({String? searchQuery, int page = 1}) async {
    try {
      final url = searchQuery != null
          ? '${ApiUrls.FETCH_JUDGEMENTS}?page_size=20&page=$page&search=$searchQuery'
          : '${ApiUrls.FETCH_JUDGEMENTS}?page_size=20&page=$page';
      final response = await ApiServiceCall().postRequest(url: url);
      List<JudgementModel> _judgements = listJudgements(response['response']);
      return _judgements;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<Article>> fetchArticles({String? searchQuery, int page = 1}) async {
    try {
      final url = searchQuery != null
          ? '${ApiUrls.FETCH_ARTICLES}?page_size=20&page=$page&search=$searchQuery'
          : '${ApiUrls.FETCH_ARTICLES}?page_size=20&page=$page';
      final response = await ApiServiceCall().postRequest(url: url);
      List<Article> _articles = listArticle(response['response']);
      return _articles;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
