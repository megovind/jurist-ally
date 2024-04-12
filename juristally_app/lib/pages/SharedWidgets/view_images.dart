import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/audio_chat_models.dart';
import 'package:juristally/pages/SharedWidgets/pdf_view/pdf.dart';

class ViewImagesPopup extends StatelessWidget {
  final List<Media> images;
  const ViewImagesPopup({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView.builder(
        itemCount: images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var _content = Container(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(),
          );
          final doc = images[index];
          print(doc.type);
          print(doc.mediaUrl);
          if (doc.type == 'jpg' || doc.type == 'png' || doc.type == 'jpeg' || doc.type == 'svg' || doc.type == 'gif') {
            _content = Container(
              margin: EdgeInsets.all(10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: images[index].mediaUrl ?? "",
              ),
            );
          } else if (doc.type == 'pdf') {
            _content = Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ViewPDF(url: doc.mediaUrl),
            );
          }
          return _content;
        },
      ),
    );
  }
}
