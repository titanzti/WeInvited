import 'package:flutter/material.dart';
import 'package:we_invited/screens/Notification/Notifica.dart';
import 'package:we_invited/screens/category/categoryPage.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:line_icons/line_icons.dart';
import 'package:we_invited/screens/home/profile/profile.dart';

import 'Homepages.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeFeed(),
    CategoryPage(),
    NotificationPage(),
    Myprofile(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // appBar: AppBar(title: Text('We invited'),
    // ),
//      body: _children[_currentIndex],
//      bottomNavigationBar: BottomNavigationBar(
//        onTap: onTabTapped,
//        currentIndex: _currentIndex,
//        items: [
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.home),
//            title: new Text("Home"),
//          ),
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.explore),
//            title: new Text("explore"),
//          ),
//        ],
//      ),

    final bottomNavBar = BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.blueGrey.withOpacity(0.6),
      elevation: 0.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.rss_feed),
          title: Text(
            'Feed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(LineIcons.dashboard),
          title: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(LineIcons.bell),
          title: Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        BottomNavigationBarItem(

          icon: Icon(LineIcons.user),
          title: Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

        )
      ],
    );

    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      body: _pages[_currentIndex],
    );
  }
}
