import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:juristally/Localization/localization.dart';
import 'package:juristally/pages/SharedWidgets/pdf_view/pdfview.dart';
import 'package:path_provider/path_provider.dart';

class ViewPDF extends StatefulWidget {
  final File? pdfFile;
  final String? url, title, reference, referenceLink;
  ViewPDF({this.pdfFile, this.url, this.title, this.reference, this.referenceLink, Key? key}) : super(key: key);

  @override
  _ViewPDFState createState() => _ViewPDFState();
}

class _ViewPDFState extends State<ViewPDF> {
  bool _isLoading = false;
  String _urlPDFPath = "";

  @override
  void initState() {
    super.initState();
    if (widget.pdfFile != null) {
      fromAsset(widget.pdfFile ?? File("path")).then((f) => mounted ? setState(() => _urlPDFPath = f.path) : "");
    } else {
      getFileFromUrl(widget.url ?? "").then((f) {
        if (mounted) setState(() => _urlPDFPath = f.path);
      });
    }
  }

  Future<File> getFileFromUrl(String url) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");
      File urlFile = await file.writeAsBytes(bytes);
      if (!mounted) return File("path");
      if (mounted) setState(() => _isLoading = false);
      return urlFile;
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      throw Exception(translatedString(context, 'err_opening'));
    }
  }

  Future<File> fromAsset(File file) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      // var dir = await getApplicationDocumentsDirectory();
      // File file = File("${dir.path}/$filename");
      // var data = await rootBundle.load(asset);
      // var bytes = data.buffer.asUint8List();
      // await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception(translatedString(context, 'err_opening'));
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    bool _validURL = Uri.parse(widget.url ?? "").isAbsolute;
    final _simplePdf = _urlPDFPath != ""
        ? PdfViewPage(path: _urlPDFPath, reference: widget.reference, referenceLink: widget.referenceLink)
        : Container();
    var _widget;
    if (!_validURL) {
      _widget = Center(
        child: Container(
          child: Text('${translatedString(context, 'not_valid_url')}  ${widget.url}'),
        ),
      );
    } else {
      _widget = _simplePdf;
    }
    Widget _body;
    if (widget.title != null) {
      _body = Scaffold(
        appBar: AppBar(title: Text(widget.title ?? "", style: TextStyle(fontSize: 14))),
        body: _isLoading ? _loader() : _widget,
      );
    } else {
      _body = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: _isLoading ? _loader() : _widget,
      );
    }
    return _body;
  }

  _loader() {
    return Container(
      height: 30,
      width: 30,
      child: CircularProgressIndicator(),
    );
  }
}
