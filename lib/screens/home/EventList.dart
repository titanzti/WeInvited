import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/OtherUserData_notifier.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/home/EventDetail.dart';
import 'package:we_invited/screens/profile/otherprofile.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/ui_helper.dart';
import '../../notifier/join_notifier.dart';

class PostListView extends StatefulWidget {
  final Post posts;
  final PostNotifier postNotifier;
  final JoinEvent joinEvent;

  PostListView({
    Key key,
    this.posts,
    this.postNotifier,
    this.joinEvent,
  }) : super(key: key);

  @override
  _PostListViewState createState() =>
      _PostListViewState(posts, postNotifier, joinEvent);
}

class _PostListViewState extends State<PostListView> {
  final Post posts;
  final PostNotifier postNotifier;
  final JoinEvent joinEvent;
  ThemeData themeData;
  CustomAppTheme customAppTheme;
  var myuid;
  int numreq = 0;
  var totalreq;
  var otheremail;
  var arr = [];
  bool liked = false;
  static int totallike;
  int mylikes;
  var mypostid;

  ScrollController scrollController;
  AnimationController controller;
  AnimationController opacityController;
  Animation<double> opacity;

/*ฟังชั่นกดไลท์ */
  Future likepost(int totallike, String postId) async {
    final uEmail = await AuthService().getCurrentEmail();
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .set({'likes': 1});

    await FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .update({'likes': totallike + 1});

    return FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .set({'likes': 1});
  }

/*ฟังชั่นกดอันไลท์ */
  Future unlikepost(int totallike, String postId) async {
    final uEmail = await AuthService().getCurrentEmail();

    await FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .delete();

    return await FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .update({'likes': totallike - 1});
  }

/*ดึงค่าไลท์จากไฟเบส */
  Future getlikes(postid) async {
    print("getlikes");
    final uEmail = await AuthService().getCurrentEmail();

    //assumes you have a collection called "users"
    /*ดึงค่าไลท์จากcollection/Posts/collection/likes */
    FirebaseFirestore.instance
        .collection("Posts")
        .doc('ALL')
        .collection('PostsList')
        .doc(postid)
        .collection('likes')
        .doc(uEmail)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;
        });
      }
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
    /*ดึงค่าไลท์จากcollection/Posts/likes */
    FirebaseFirestore.instance
        .collection("Posts")
        .doc('ALL')
        .collection("PostsList")
        .where('postid', isEqualTo: postid)
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      // int totallike;
      totallike = querySnapshot.docs.length;
      // print('totallike$totallike');

      querySnapshot.docs.forEach((value) {
        // print('testlike=>>>>>>${value.get('likes')}');
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  _PostListViewState(
    this.posts,
    this.postNotifier,
    this.joinEvent,
  );
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  // OtherUserDataProfileNotifier otherprofileNotifier =
                  //     Provider.of<OtherUserDataProfileNotifier>(context,
                  //         listen: false);
                  // getOtherProfile(otherprofileNotifier);

                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqPosts(joinNotifier);
                  // ProductsNotifier productsNotifier =
                  // Provider.of<ProductsNotifier>(context, listen: false);
                  // getProdProducts(productsNotifier);
                  //
                  // getCloudFirestoreUsers();

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;
                  // numreq=0;
                  getCloudFirestore();
                  otheremail = posts.emailuser;
                  mypostid = posts.postid;
                  getlikes(mypostid);

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  getEvenReqPosts(JoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    // print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(myuid)
        .collection('JoinEventList')
        .where('receiverUidjoin', isEqualTo: myuid)
        .get();

    List<JoinEvent> _joinsList = [];

    snapshot.docs.forEach((document) {
      JoinEvent joinevent = JoinEvent.fromMap(document.data());
      _joinsList.add(joinevent);
    });

    joinNotifier.joineventList = _joinsList;
  }

  Future getCloudFirestore() async {
    print("getCloudFirestore");
    var postid;
    postid = posts.postid;

    //assumes you have a collection called "users"
    FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(posts.uid)
        .collection('JoinEventList')
        .where('postid', isEqualTo: postid)
        // .orderBy('requestpostid')
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      totalreq = querySnapshot.docs.length.toString();
      print(totalreq);
      print("requestpostid: results: length: " +
          querySnapshot.docs.length.toString());
      querySnapshot.docs.forEach((value) {
        print("requestpostid: results: value");
        print(value.get('requestpostid'));

        if ((value.exists) && value.get('requestpostid') == posts.postid) {
          print(value.get('requestpostid'));

          if (this.mounted) {
            setState(() {
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

  // Future getCloudFirestoreUsers() async {
  //   print("getCloudFirestore");

  //   //assumes you have a collection called "users"
  //   FirebaseFirestore.instance
  //       .collection('JoinEvent')
  //       .doc(posts.uid)
  //       .collection('JoinEventList')
  //       .where('postid', isEqualTo: posts.postid)
  //       .orderBy('senderUid')
  //       .get()
  //       .then((querySnapshot) {
  //     //print(querySnapshot);
  //     print("requestpostid: results: length: " +
  //         querySnapshot.docs.length.toString());
  //     querySnapshot.docs.forEach((value) {
  //       print("requestpostid: results: value");
  //       print(value.get('requestpostid'));

  //       if ((value.exists) && value.get('requestpostid') == posts.postid) {
  //         print(value.get('requestpostid'));

  //         if (this.mounted) {
  //           setState(() {
  //             numreq = querySnapshot.docs.length;
  //             print('length =>>>>>>>>>>$numreq');

  //             // checkissendrequest = true;
  //             // acceptedrequest = true;
  //             // print('sentrequest$sentrequest');
  //           });
  //         }
  //       }
  //     });
  //   }).catchError((onError) {
  //     print("getCloudFirestoreUsers: ERROR");
  //     print(onError);
  //   });
  // }

  // getOtherProfile(OtherUserDataProfileNotifier otherprofileNotifier) async {
  //   print('getOtherProfile');
  //   final uEmail = await AuthService().getCurrentEmail();

  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection("userData")
  //       .doc(posts.emailuser.toString())
  //       .collection("profile")
  //       .get();

  //   List<UserDataProfile> _userDataProfileList = [];

  //   snapshot.docs.forEach((doc) {
  //     UserDataProfile userDataProfile = UserDataProfile.fromMap(doc.data());
  //     _userDataProfileList.add(userDataProfile);
  //   });

  //   otherprofileNotifier.userDataProfileList = _userDataProfileList;
  // }

  @override
  Widget build(BuildContext context) {
    UserDataProfileNotifier profileNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.last;

    OtherUserDataProfileNotifier otherprofileNotifier =
        Provider.of<OtherUserDataProfileNotifier>(context, listen: false);
    var checkotherUser = otherprofileNotifier.userDataProfileList;
    var otheruser;

    checkotherUser.isEmpty || checkotherUser == null
        ? otheruser = null
        : otheruser = checkotherUser.first;

    themeData = Theme.of(context);

    final format2 = new DateFormat(' h:mm');
    final format3 = new DateFormat(' h:mm ');
    // print(otheremail);
    // print('posts.emailuser.toString()${posts.emailuser.toString()}');

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 16),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          UserDataProfileNotifier profileNotifier =
              Provider.of<UserDataProfileNotifier>(context, listen: false);

          JoinNotifier joinNotifier =
              Provider.of<JoinNotifier>(context, listen: false);

          // getEvenReqPosts(joinNotifier);
          var navigationResult = await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider(
                create: (context) => JoinNotifier(),
                builder: (context, child) =>
                    PostDetailsV1(posts, user, joinEvent),
              ),
            ),
          );
          if (navigationResult == true) {
            setState(() {
              getProfile(profileNotifier);
              getEvenReqPosts(joinNotifier);
            });
          }
        },
        child: Container(
          // decoration: BoxDecoration(
          //   borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          //   boxShadow: <BoxShadow>[
          //     BoxShadow(
          //       color: Colors.grey.withOpacity(0.6),
          //       offset: const Offset(4, 4),
          //       blurRadius: 16,
          //     ),
          //   ],
          // ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 2,
                      child: CachedNetworkImage(
                        imageUrl: posts.image,
                        placeholder: (context, url) =>
                            progressIndicator(MColors.primaryPurple),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      color: HotelAppTheme.buildLightTheme().backgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 8, bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Container(
                                    //   width: 40,
                                    //   height: 40,
                                    //   decoration: BoxDecoration(
                                    //       shape: BoxShape.circle,
                                    //       image: DecorationImage(
                                    //           image: NetworkImage(posts.postbyimage),
                                    //           fit: BoxFit.cover)),
                                    // ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () async {
                                            Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ChangeNotifierProvider(
                                                  create: (context) =>
                                                      PostNotifier(),
                                                  builder: (context, child) =>
                                                      Otherprofile(
                                                    postDetails: posts,
                                                    user: user,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            child: FadeInImage.assetNetwork(
                                              image: posts.postbyimage,
                                              fit: BoxFit.fill,
                                              height: 39,
                                              width: 39,
                                              placeholder:
                                                  "assets/profile1.png",
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Host",
                                              style: AppTheme.getTextStyle(
                                                  themeData.textTheme.caption,
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: 500,
                                                  xMuted: true),
                                            ),
                                            Text(
                                              posts.postbyname,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    UIHelper.horizontalSpace(2),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            posts.name,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 2),
                                          child: Text(
                                            '${format2.format(posts.startdateTime.toDate())} -${format3.format(posts.entdateTime.toDate())} ',
                                            style: AppTheme.getTextStyle(
                                                themeData.textTheme.caption,
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: 500,
                                                xMuted: true),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                      ],
                                    ),

                                    UIHelper.horizontalSpace(2),
                                    Icon(Icons.location_on,
                                        size: 16,
                                        color: Theme.of(context).primaryColor),
                                    Container(
                                      child: Text(
                                        posts.place,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: <Widget>[
                                          // SmoothStarRating(
                                          //   allowHalfRating: true,
                                          //   starCount: 5,
                                          //   rating: posts.emailuser,
                                          //   size: 20,
                                          //   color: HotelAppTheme
                                          //           .buildLightTheme()
                                          //       .primaryColor,
                                          //   borderColor: HotelAppTheme
                                          //           .buildLightTheme()
                                          //       .primaryColor,
                                          // ),
                                          Text(
                                            ' $totalreq/${posts.Numpeople} จำนวนผู้เข้าร่วม',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16, top: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                // Text(
                                //   '\$${hotelData.perNight}',
                                //   textAlign: TextAlign.left,
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //     fontSize: 22,
                                //   ),
                                // ),
                                // Text(
                                //   '/per night',
                                //   style: TextStyle(
                                //       fontSize: 14,
                                //       color:
                                //           Colors.grey.withOpacity(0.8)),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16, right: 5),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 30),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                DesignCourseAppTheme.nearlyBlue,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(24.0)),
                                            border: Border.all(
                                                color: DesignCourseAppTheme
                                                    .nearlyBlue)),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: Colors.white24,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(24.0)),
                                            onTap: () async {
                                              UserDataProfileNotifier
                                                  profileNotifier = Provider.of<
                                                          UserDataProfileNotifier>(
                                                      context,
                                                      listen: false);

                                              JoinNotifier joinNotifier =
                                                  Provider.of<JoinNotifier>(
                                                      context,
                                                      listen: false);

                                              // getEvenReqPosts(joinNotifier);
                                              var navigationResult =
                                                  await Navigator.of(context)
                                                      .push(
                                                CupertinoPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ChangeNotifierProvider<
                                                          JoinNotifier>(
                                                    create: (context) =>
                                                        JoinNotifier(),
                                                    builder: (context, child) =>
                                                        PostDetailsV1(posts,
                                                            user, joinEvent),
                                                  ),
                                                ),
                                              );
                                              if (navigationResult == true) {
                                                setState(() {
                                                  // getOtherProfile(
                                                  //     otherprofileNotifier);
                                                  getEvenReqPosts(joinNotifier);
                                                });
                                              }
                                              //   Navigator.of(context).push(
                                              //       CupertinoPageRoute(builder: (BuildContext context){
                                              //         return PostDetailsProv(posts);
                                              //       }));
                                              //
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 12,
                                                  left: 18,
                                                  right: 18),
                                              child: Center(
                                                child: Text(
                                                  "ดูเพิ่มเติม",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    letterSpacing: 0.27,
                                                    color: DesignCourseAppTheme
                                                        .nearlyWhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      padding: EdgeInsets.only(left: 10),
                      onPressed: liked
                          ? () {
                              setState(() {
                                liked = false;
                                unlikepost(totallike, posts.postid);
                              });
                            }
                          : () {
                              setState(() {
                                liked = true;
                                likepost(totallike, posts.postid);
                              });
                            },
                      icon: liked
                          ? Icon(Icons.favorite_rounded)
                          : Icon(Icons.favorite_border),
                      iconSize: 25,
                      color: liked ? Colors.redAccent : Colors.grey,
                    ),
                    // InkWell(
                    //   borderRadius: const BorderRadius.all(
                    //     Radius.circular(32.0),
                    //   ),
                    //   onTap: () {
                    //     print('กด');
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Icon(
                    //       Icons.favorite_border,
                    //       color: HotelAppTheme.buildLightTheme().primaryColor,
                    //     ),
                    //   ),
                    // ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
