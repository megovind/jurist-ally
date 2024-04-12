import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:juristally/models/legal_library_model.dart';

class ArticleDetals extends StatelessWidget {
  final Article article;
  const ArticleDetals({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Wrap(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Text(
                "${article.quote}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "${article.user?.fullName ?? "Juristally"}",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.yMEd().format(article.createdAt ?? DateTime.now()),
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_add_outlined))
                    ],
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10),
              height: 200,
              // width: MediaQuery.of(context).size,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(article.coverImage ?? ""),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 0),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: article.bulletPoint!.length,
                itemBuilder: (context, index) {
                  final point = article.bulletPoint![index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        child: Icon(
                          Icons.circle_sharp,
                          color: Colors.black12,
                          size: 10,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          point,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                article.content ?? "",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
