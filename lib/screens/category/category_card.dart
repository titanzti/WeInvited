import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/category/category_list.dart';
import 'package:we_invited/screens/category/detail_screen.dart';
import 'package:we_invited/screens/home/Homepages.dart';
import 'package:we_invited/services/Event_service.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class CategoryCard extends StatefulWidget {
  final _title;
  final _courseAmount;
  final _imageUrl;
  final JoinEvent joinEvent;
  final UserDataProfile user;

  CategoryCard(this._title, this._courseAmount, this._imageUrl, this.joinEvent,
      this.user);

  @override
  _CategoryCardState createState() =>
      _CategoryCardState(_title, _imageUrl, joinEvent, user);
}

class _CategoryCardState extends State<CategoryCard> {
  var myuid;
  final _imageUrl;
  final _title;

  final JoinEvent joinEvent;
  final UserDataProfile user;

  _CategoryCardState(this._imageUrl, this._title, this.joinEvent, this.user);

  // Post postDetails = Post();

  @override
  void initState() {
    /*ใช้ฟังชั่น checkInternetConnectivity */
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPosts1(postsNotifier, _title);
                  print('เชื่อมต่อ');

                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqPosts(joinNotifier, myuid);

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeData themeData;

  @override
  void dispose() {
    print("disposeCategoryCard");
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    UserDataProfileNotifier profileNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;
    //
    // JoinNotifier joinNotifier =
    //     Provider.of<JoinNotifier>(context, listen: false);
    //
    // var joins = joinNotifier.joineventList;

    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return GestureDetector(
          key: _scaffoldKey,
          onTap: () async {
            // user.profilePhoto!=null?print("มีรูป"):print("ไม่มีรูป");

            UserDataProfileNotifier profileNotifier =
                Provider.of<UserDataProfileNotifier>(context, listen: false);

            JoinNotifier joinNotifier =
                Provider.of<JoinNotifier>(context, listen: false);

            PostNotifier postsNotifier =
                Provider.of<PostNotifier>(context, listen: false);

            // getEvenReqPosts(joinNotifier);
            var navigationResult = await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (BuildContext context) => ChangeNotifierProvider(
                  create: (context) => PostNotifier(),
                  builder: (context, child) =>
                      DetailScreen(_title, _imageUrl, joinEvent, user),
                ),
              ),
            );
            if (navigationResult == true) {
              setState(() {
                print("setstatebuildTripCard");
                getProfile(profileNotifier);
                getPosts1(postsNotifier, _title);
                getEvenReqPosts(joinNotifier, myuid);
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 30,
              height: MediaQuery.of(context).size.height / 4 - 40,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Hero(
                    tag: widget._imageUrl,
                    child: Image.asset(
                      widget._imageUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          widget._title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.end,
                        ),
                        // Text(
                        //   '${widget._courseAmount} Courses',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: Color(0xff8F95B2),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
