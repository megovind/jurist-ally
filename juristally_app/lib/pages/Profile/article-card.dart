import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:juristally/models/legal_library_model.dart';
import 'package:juristally/pages/LegalLibrary/article_details.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetals(
            article: article,
          ),
        ),
      ),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                alignment: Alignment.topRight,
                child: Text(
                  "#Article",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "${article.content!.length > 200 ? article.content!.substring(0, 200) + "..." : article.content}",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                  "${article.quote}",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                  "Published by ${article.user?.fullName ?? "Juristally"}, ${article.user?.designation ?? ""}",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                  "Date: ${DateFormat.yMEd().format(article.createdAt ?? DateTime.now())}",
                  style: TextStyle(fontSize: 10),
                ),
              )
            ],
          ),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: article.coverImage != null
                ? DecorationImage(
                    colorFilter: ColorFilter.mode(Colors.white38, BlendMode.hardLight),
                    image: CachedNetworkImageProvider(article.coverImage ?? 'assets/images/white-logo.png'),
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    colorFilter: ColorFilter.mode(Colors.white38, BlendMode.hardLight),
                    image: ExactAssetImage('assets/images/white-logo.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}
