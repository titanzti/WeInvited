import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:we_invited/screens/home/EventDetail.dart';
import 'package:we_invited/screens/profile/editProfileScreen.dart';
import 'package:we_invited/screens/profile/profile_menu.dart';
import 'package:we_invited/screens/profile/property_card.dart';
import 'package:we_invited/services/Event_service.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/constant.dart';
import 'package:we_invited/utils/SizeConfig.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class Otherprofile extends StatefulWidget {
  final Post postDetails;

  final UserDataProfile user;

  Otherprofile({Key key, this.user, this.postDetails}) : super(key: key);

  @override
  _OtherprofileState createState() => _OtherprofileState();
}

class _OtherprofileState extends State<Otherprofile> {
  // UserDataProfile user;
  // _OtherprofileState(this.user);
  Future profileFuture;
  Post postDetails = Post();
  var otheremail = "Lable", othername = "Lable", otherpic = "";

  var myuid;
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  getCloudFirestoreUsers(widget.postDetails);

                  // final FirebaseAuth auth = FirebaseAuth.instance;
                  // final User user = auth.currentUser;
                  // final uid = user.uid.toString();
                  myuid = widget.postDetails.uid;
                  print('myuid=>>>>>>>>>>>>$myuid');

                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getOtherPosts(postsNotifier, myuid);
                  print('เชื่อมต่อ');
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  // JoinNotifier joinNotifier =
                  //     Provider.of<JoinNotifier>(context, listen: false);
                  // getEvenReqPosts(joinNotifier, myuid);

                  // checkpostidEvent= _joinEvent.requestpostid;
                  // print(checkpostidEvent);
                  // mypostuid==myuid?print('เจ้าของโพส'):print('ไม่ใช่เจ้าของโพส');
                  // chrecktype=widget.joinEvent.type;

                  // getProfile(profileNotifier);
                  // ProductsNotifier productsNotifier =
                  // Provider.of<ProductsNotifier>(context, listen: false);
                  // getProdProducts(productsNotifier);
                  //
                  // CartNotifier cartNotifier =
                  // Provider.of<CartNotifier>(context, listen: false);
                  // getCart(cartNotifier);
                  //
                  // BannerAdNotifier bannerAdNotifier =
                  // Provider.of<BannerAdNotifier>(context, listen: false);
                  // getBannerAds(bannerAdNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    super.initState();
  }

  Future getCloudFirestoreUsers(postDetails) async {
    print("getCloudFirestoreOtherUser");
    ///////////////////////////
    FirebaseFirestore.instance
        .collection("userData")
        .doc(postDetails.emailuser)
        .collection("profile")
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      // otheremail = querySnapshot.docs.length.toString();
      // print('otheremail$otheremail');
      // print("requestpostid: results: length: " +querySnapshot.docs.length.toString());
      querySnapshot.docs.forEach((value) {
        // print("requestpostid: results: value");
        // print(value.get('email'));
        otheremail = value.get('email');
        othername = value.get('name');
        otherpic = value.get('profilePhoto');
        // print();
        otheremail != null ? print(otheremail) : print("otheremail");
        if ((value.exists)) {
          // print(value.get('email'));

          if (this.mounted) {
            setState(() {
              // print(value.get('email'));

              // checkissendrequest = true;
              // acceptedrequest = true;
              // print('sentrequest$sentrequest');
            });
          }
        }
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  Future getOtherPost(myuid) async {
    print("getCloudFirestoreOtherUser");
    ///////////////////////////
    FirebaseFirestore.instance
        .collection("Posts")
        .where('uid', isEqualTo: myuid)
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      // otheremail = querySnapshot.docs.length.toString();
      // print('otheremail$otheremail');
      // print("requestpostid: results: length: " +querySnapshot.docs.length.toString());
      querySnapshot.docs.forEach((value) {
        // print("requestpostid: results: value");
        // print(value.get('email'));
        otheremail = value.get('email');
        othername = value.get('name');
        otherpic = value.get('profilePhoto');
        // print();
        otheremail != null ? print(otheremail) : print("otheremail");
        if ((value.exists)) {
          // print(value.get('email'));

          if (this.mounted) {
            setState(() {
              // print(value.get('email'));

              // checkissendrequest = true;
              // acceptedrequest = true;
              // print('sentrequest$sentrequest');
            });
          }
        }
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    var posts = postsNotifier.postList;
    // print("post${postDetails.emailuser}");
    // UserDataProfileNotifier profileNotifier =
    // Provider.of<UserDataProfileNotifier>(context);
    // var checkUser = profileNotifier.userDataProfileList;
    // var user;
    //
    // checkUser.isEmpty || checkUser == null
    //     ? user = null
    //     : user = checkUser.first;

    return FutureBuilder(
      future: Future.wait([
        profileFuture,
      ]),
      builder: (c, s) {
        switch (s.connectionState) {
          case ConnectionState.active:
            return progressIndicator(MColors.primaryPurple);
            break;
          case ConnectionState.done:
            return LayoutBuilder(
              builder: (context, constraints) {
                return OrientationBuilder(
                  builder: (context, orientation) {
                    SizeConfig().init(constraints, orientation);
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home:
                          ProfileFirst(widget.user, widget.postDetails, posts),
                    );
                  },
                );
              },
            );

            break;
          case ConnectionState.waiting:
            return progressIndicator(MColors.primaryPurple);
            break;
          default:
            return progressIndicator(MColors.primaryPurple);
        }
      },
    );
  }

  Widget showSettings(user, postDetails) {
    // print(user.name);
    // print(user.gender);

    final listTileIcons = [
      "assets/images/password.svg",
      "assets/images/icons/Wallet.svg",
      "assets/images/icons/Location.svg",
      "assets/images/gift.svg",
      "assets/images/help.svg",
      "assets/images/question.svg",
      "assets/images/logout.svg",
    ];

    final listTileNames = [
      "Security",
      "Cards",
      "Address",
      "Invite a friend",
      "Help",
      "FAQs",
      "Sign out",
    ];
    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
      appBar: primaryAppBar(
        null,
        Text(
          '$otheremail',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.27,
            color: MColors.primaryPurple,
          ),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        null,
      ),
      // body: RefreshIndicator(
      //   onRefresh: () => () async {
      //     await profileFuture;
      //   }(),
      // ),
    );
  }

  Widget ProfileFirst(user, postDetails, posts) {
    // UserDataProfileNotifier profileNotifier =
    //     Provider.of<UserDataProfileNotifier>(context);
    // var checkUser = profileNotifier.userDataProfileList;
    // var user;

    // checkUser.isEmpty || checkUser == null
    //     ? user = null
    //     : user = checkUser.first;

    return Scaffold(
      // appBar: new AppBar(
      //   title: Text('Hello world'),
      //   backgroundColor: Colors.blue[600],
      // ),
      // appBar: primaryAppBar(
      //   null,
      //   null,
      //   Colors.blue[600],
      //   null,
      //   true,
      //   null,
      // ),
      backgroundColor: Color(0xffF8F8FA),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            color: Colors.blue[600],
            height: 40 * SizeConfig.heightMultiplier,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 10 * SizeConfig.heightMultiplier),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 11 * SizeConfig.heightMultiplier,
                        width: 22 * SizeConfig.widthMultiplier,
                        //   child: CachedNetworkImage(
                        //   imageUrl: otherpic,

                        //   placeholder: (context, url) =>
                        //       progressIndicator(MColors.primaryPurple),
                        //   errorWidget: (context, url, error) => Icon(Icons.error),
                        //   fit: BoxFit.cover,

                        // ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: otherpic != null
                              ? DecorationImage(
                                  image: NetworkImage(otherpic),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: NetworkImage("assets/profile1.png"),
                                  fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(
                        width: 5 * SizeConfig.widthMultiplier,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$othername',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 1 * SizeConfig.heightMultiplier,
                          ),
                          Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  // Image.asset(
                                  //   "assets/fb.png",
                                  //   height: 3 * SizeConfig.heightMultiplier,
                                  //   width: 3 * SizeConfig.widthMultiplier,
                                  // ),
                                  SizedBox(
                                    width: 2 * SizeConfig.widthMultiplier,
                                  ),
                                  // Text(
                                  //   "Protorix",
                                  //   style: TextStyle(
                                  //     color: Colors.white60,
                                  //     fontSize: 1.5 * SizeConfig.textMultiplier,
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(
                                width: 7 * SizeConfig.widthMultiplier,
                              ),
                              Row(
                                children: <Widget>[
                                  // Image.asset(
                                  //   "assets/insta.png",
                                  //   height: 3 * SizeConfig.heightMultiplier,
                                  //   width: 3 * SizeConfig.widthMultiplier,
                                  // ),
                                  SizedBox(
                                    width: 2 * SizeConfig.widthMultiplier,
                                  ),
                                  // Text(
                                  //   "Protorix",
                                  //   style: TextStyle(
                                  //     color: Colors.white60,
                                  //     fontSize: 1.5 * SizeConfig.textMultiplier,
                                  //   ),
                                  // ),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 3 * SizeConfig.heightMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          // Text(
                          //   "10.2K",
                          //   style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 3 * SizeConfig.textMultiplier,
                          //       fontWeight: FontWeight.bold),
                          // ),
                          // Text(
                          //   "Protorix",
                          //   style: TextStyle(
                          //     color: Colors.white70,
                          //     fontSize: 1.9 * SizeConfig.textMultiplier,
                          //   ),
                          // ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          // Text(
                          //   "543",
                          //   style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 3 * SizeConfig.textMultiplier,
                          //       fontWeight: FontWeight.bold),
                          // ),
                          // Text(
                          //   "Following",
                          //   style: TextStyle(
                          //     color: Colors.white70,
                          //     fontSize: 1.9 * SizeConfig.textMultiplier,
                          //   ),
                          // ),
                        ],
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.white60),
                      //     borderRadius: BorderRadius.circular(5.0),
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text(
                      //       "EDIT PROFILE",
                      //       style: TextStyle(
                      //           color: Colors.white60,
                      //           fontSize: 1.8 * SizeConfig.textMultiplier),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30 * SizeConfig.heightMultiplier),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 3 * SizeConfig.heightMultiplier),
                      child: Text(
                        "My Events",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 2.2 * SizeConfig.textMultiplier),
                      ),
                    ),
                    Builder(
                      builder: (BuildContext context) {
                        return ListView.builder(
                          physics: ClampingScrollPhysics(),
                          itemCount: posts.length,
                          padding: const EdgeInsets.only(top: 8),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return PropertyCard(
                              posts: posts[index],
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Container(
                      height: 37 * SizeConfig.heightMultiplier,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          // _myAlbumCard(
                          //     "assets/travelfive.png",
                          //     "assets/traveltwo.png",
                          //     "assets/travelsix.png",
                          //     "assets/travelthree.png",
                          //     "+178",
                          //     "Best Trip"),
                          // _myAlbumCard(
                          //     "assets/travelsix.png",
                          //     "assets/travelthree.png",
                          //     "assets/travelfour.png",
                          //     "assets/travelfive.png",
                          //     "+18",
                          //     "Hill Lake Tourism"),
                          // _myAlbumCard(
                          //     "assets/travelfive.png",
                          //     "assets/travelsix.png",
                          //     "assets/traveltwo.png",
                          //     "assets/travelone.png",
                          //     "+1288",
                          //     "The Grand Canyon"),
                          SizedBox(
                            width: 10 * SizeConfig.widthMultiplier,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    //   child: Row(
                    //     children: <Widget>[
                    //       Text(
                    //         "Favourite places",
                    //         style: TextStyle(
                    //             color: Colors.black,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 2.2 * SizeConfig.textMultiplier),
                    //       ),
                    //       Spacer(),
                    //       Text(
                    //         "View All",
                    //         style: TextStyle(
                    //             color: Colors.grey,
                    //             fontSize: 1.7 * SizeConfig.textMultiplier),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Container(
                      height: 20 * SizeConfig.heightMultiplier,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          // _favoriteCard("assets/travelfive.png"),
                          // _favoriteCard("assets/travelthree.png"),
                          // _favoriteCard("assets/travelfive.png"),
                          SizedBox(
                            width: 10 * SizeConfig.widthMultiplier,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
