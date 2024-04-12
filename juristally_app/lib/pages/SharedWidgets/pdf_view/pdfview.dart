import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewPage extends StatefulWidget {
  final String? path, reference, referenceLink;
  const PdfViewPage({Key? key, this.path, this.reference, this.referenceLink}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        PDFView(
          filePath: widget.path,
          autoSpacing: true,
          enableSwipe: true,
          pageSnap: true,
          swipeHorizontal: true,
          nightMode: false,
          onError: (e) {
            print(e);
          },
          onRender: (_pages) {
            if (mounted)
              setState(() {
                _totalPages = _pages ?? 0;
                pdfReady = true;
              });
          },
          onViewCreated: (PDFViewController vc) {
            _pdfViewController = vc;
          },
          onPageChanged: (int? page, int? total) {
            if (mounted)
              setState(() {
                _totalPages = total ?? 0;
                _currentPage = page ?? 0;
              });
          },
          onPageError: (page, e) {},
        ),
        // widget.referenceLink != null
        //     ? Align(
        //         alignment: Alignment.bottomRight,
        //         child: InkWell(
        //           onTap: () => Navigator.of(context)
        //               .push(MaterialPageRoute(builder: (context) => WebViewWidget(url: widget.referenceLink))),
        //           child: Container(
        //             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        //             child: Text(
        //               "${translatedString(context, 'referrance')}: " + reference,
        //               style: TextStyle(color: Colors.blueAccent, fontSize: 6),
        //             ),
        //           ),
        //         ),
        //       )
        //     : Offstage(),
        Align(
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _currentPage > 0
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      _currentPage -= 1;
                      _pdfViewController.setPage(_currentPage);
                    },
                  )
                : Offstage(),
            _currentPage + 1 < _totalPages
                ? IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      _currentPage += 1;
                      _pdfViewController.setPage(_currentPage);
                    },
                  )
                : Offstage(),
          ]),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            color: Colors.transparent,
            child: Container(padding: EdgeInsets.all(5), child: Text("$_currentPage/$_totalPages")),
          ),
        ),
        !pdfReady
            ? Center(
                child: Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                ),
              )
            : Offstage()
      ],
    ));
  }
}
