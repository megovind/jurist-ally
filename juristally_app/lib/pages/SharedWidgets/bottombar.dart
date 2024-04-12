import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/pages/LegalLibrary/legal_library_menu_page.dart';
import 'package:juristally/pages/Notification/notificationpage.dart';
import 'package:juristally/pages/SmallTalk/small-talk.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(80),
          topStart: Radius.circular(80),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomIconButton(onClick: () {}, icon: Icons.home, label: "Home"),
          _bottomIconButton(
              onClick: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SmallTalk(),
                    ),
                  ),
              icon: Icons.multitrack_audio,
              label: 'Small Talk'),
          _bottomIconButton(
              onClick: () {
                Navigator.pushNamed(context, NotificationPage.routename);
              },
              icon: Icons.notifications_outlined,
              label: 'Notification'),
          _bottomIconButton(
              onClick: () {
                Navigator.pushNamed(context, LegalLibraryPage.routename);
              },
              icon: Icons.menu,
              label: "Menu"),
        ],
      ),
    );
  }

  _bottomIconButton({required Function onClick, required IconData icon, required String label, Color? color}) {
    return Container(
      height: 70,
      child: TextButton(
          onPressed: () => onClick(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color ?? Colors.black,
                size: 24,
              ),
              SizedBox(height: 5),
              Text(label, style: TextStyle(fontSize: 8, color: Colors.black))
            ],
          ),
          style: TextButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(10),
            primary: Colors.white,
          )),
    );
  }
}
