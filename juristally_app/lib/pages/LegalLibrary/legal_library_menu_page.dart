import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/pages/LegalLibrary/articles.dart';
import 'package:juristally/pages/LegalLibrary/bareact.dart';
import 'package:juristally/pages/LegalLibrary/judgement.dart';
import 'package:juristally/pages/LegalLibrary/legal_update.dart';
import 'package:provider/provider.dart';

class LegalLibraryPage extends StatefulWidget {
  static const routename = "/LegalLibraryMenuPage";
  LegalLibraryPage({Key? key}) : super(key: key);

  @override
  _LegalLibraryPageState createState() => _LegalLibraryPageState();
}

class _LegalLibraryPageState extends State<LegalLibraryPage> {
  @override
  void initState() {
    super.initState();
  }

  List<LibraryItems> _items = [
    LibraryItems(
        imagePath: 'assets/images/bare_acts.png',
        title: "Bare Acts",
        onClick: (context) => Navigator.pushNamed(context, BareActPage.routeName)),
    LibraryItems(
        imagePath: 'assets/images/judgement.png',
        title: "Judgements",
        onClick: (context) => Navigator.pushNamed(context, Judgements.routename)), //"Judgements",
    LibraryItems(
        imagePath: 'assets/images/legal_updates.png',
        title: "Legal Updates",
        onClick: (context) => Navigator.pushNamed(context, LegalUpdates.routename)), //"Legal Updates",
    LibraryItems(
        imagePath: 'assets/images/articles.png',
        title: "Articles",
        onClick: (context) => Navigator.pushNamed(context, Articles.routename)) //"Articles"
  ];
  @override
  Widget build(BuildContext context) {
    final _loggedUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
    return Scaffold(
      body: GridView.builder(
        itemCount: _items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _items[index].onClick(context),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
            color: Color(0xfff2f2f2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  height: 60,
                  decoration: BoxDecoration(image: DecorationImage(image: ExactAssetImage(_items[index].imagePath))),
                ), //Icon(_items[index].icon, size: 80),
                SizedBox(height: 20),
                Text("${_items[index].title}")
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryItems {
  final String title;
  final String imagePath;
  final Function onClick;

  LibraryItems({required this.imagePath, required this.title, required this.onClick});
}
