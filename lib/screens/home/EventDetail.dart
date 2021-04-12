import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_invited/main.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/profile/otherprofile.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/text_style.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/datetime_utils.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/ui_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PostDetailsV1 extends StatefulWidget {
  final Post postDetails;
  final UserDataProfile userData;
  final JoinEvent joinEvent1;

  PostDetailsV1(this.postDetails, this.userData, this.joinEvent1);

  @override
  _PostDetailsV1State createState() =>
      _PostDetailsV1State(postDetails, joinEvent1);
}

class _PostDetailsV1State extends State<PostDetailsV1>
    with TickerProviderStateMixin {
  ThemeData themeData;
  final JoinEvent joinEvent1;

  _PostDetailsV1State(this.postDetails, this.joinEvent1);
  final double infoHeight = 364.0;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  var str;

  bool liked = false;
  int mylikes;
  var startIndex;
  var endIndex;
  var start = "(";
  var end = ".";
  Post postDetails = Post();
  JoinEvent joinEvent = JoinEvent();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  bool acceptedrequest = false;
  bool sentrequest = false;
  var checkpostidEvent = [];
  var checksenderUid;
  var checktype;
  var mypostid;
  var joinid;
  var mypostuid;
  var myuid;
  var uidpost;
  var otheremail;
  int totallike;
  bool checkissendrequest = false;
  String toggleJoin;
  bool visibilitybutt = false;

  AnimationController controller;
  AnimationController bodyScrollAnimationController;
  ScrollController scrollController;
  Animation<double> scale;
  Animation<double> appBarSlide;
  double headerImageSize = 0;
  bool isFavorite = false;
  final format1 = DateFormat('d/M/yyyy');
  final now = DateTime.now();

  bool isExpired;
  String _token = "token";
  DateTime dateexp = DateTime.now();

/*ฟังชั่นกดไลท์ */
  Future likepost(int mylike, String postId) async {
    final uEmail = await AuthService().getCurrentEmail();
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .set({'likes': 1});

    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(postId)
        .update({'likes': totallike + 1});

    return FirebaseFirestore.instance
        .collection("Posts")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .update({'likes': 1});
  }

/*ฟังชั่นกดอันไลท์ */
  Future unlikepost(int mylike, String postId) async {
    final uEmail = await AuthService().getCurrentEmail();

    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .delete();

    return await FirebaseFirestore.instance
        .collection("Posts")
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
        .where('postid', isEqualTo: postid)
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      int totallike;
      totallike = querySnapshot.docs.length;
      print('totallike$totallike');

      querySnapshot.docs.forEach((value) {
        print('testlike=>>>>>>${value.get('likes')}');
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    bodyScrollAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.offset >= headerImageSize / 2) {
          if (!bodyScrollAnimationController.isCompleted)
            bodyScrollAnimationController.forward();
        } else {
          if (bodyScrollAnimationController.isCompleted)
            bodyScrollAnimationController.reverse();
        }
      });

    appBarSlide = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: bodyScrollAnimationController,
    ));

    scale = Tween(begin: 1.0, end: 0.5).animate(CurvedAnimation(
      curve: Curves.linear,
      parent: controller,
    ));

    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  getDataFromJoinEvent();
                  // checkData();

                  visibilitybutt = false;

                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqPosts(joinNotifier);

                  mypostuid = postDetails.uid;
                  // mypostid = postDetails.postid;

                  getCloudFirestoreJoinEvent();

                  _fcm.getToken().then((String token) {
                    setState(() {
                      _token = '$token';
                    });
                    assert(token != null);
                    print("Token : $token");
                  });
                  var agerage = postDetails.agerange;

                  str = agerage;

                  startIndex = str.indexOf(start);
                  endIndex = str.indexOf(end, startIndex + start.length);

                  print(str.substring(startIndex + start.length, endIndex));

                  if (isExpired == false) {
                    return expireeven();
                  }
                  otheremail = postDetails.emailuser;

                  // checkpostidEvent= _joinEvent.requestpostid;
                  // print(checkpostidEvent);
                  // mypostuid==myuid?print('เจ้าของโพส'):print('ไม่ใช่เจ้าของโพส');
                  // chrecktype=widget.joinEvent.type;

                  // UserDataProfileNotifier profileNotifier = Provider.of<UserDataProfileNotifier>(context, listen: false);
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
                  mypostid = postDetails.postid;

                  // checkIfSentRequest();
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    bodyScrollAnimationController.dispose();

    super.dispose();
  }

  getEvenReqPosts(JoinNotifier joinNotifier) async {
    print("PostDetailsV1");
    final uid = await AuthService().getCurrentUID();
    // print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(myuid)
        .collection('JoinEventList')
        .where('receiverUidjoin')
        .orderBy("requestpostid")
        .get();

    List<JoinEvent> _joinsList = [];

    snapshot.docs.forEach((document) {
      JoinEvent joinevent = JoinEvent.fromMap(document.data());
      _joinsList.add(joinevent);
    });

    joinNotifier.joineventList = _joinsList;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // print(new DateFormat.yMMMd().format(dateexp));
    // print(DateFormat.yMMMd().format(postDetails.entdateTime.toDate()));
    // print(widget.userData.email);
    // print('=joinid>>>>>>>>>>>>>>>>$joinid');

    isExpired = dateexp.isBefore(postDetails.entdateTime.toDate());
    // print('isExpired$isExpired');
    getlikes(mypostid);
    // mylikes = postDetails.likes;

    // getData();
    JoinNotifier joinNotifier =
        Provider.of<JoinNotifier>(context, listen: false);
    getEvenReqPosts(joinNotifier);
    // checkpostidEvent.forEach((vale) => print(vale.toString())); // => banana pineapple watermelon

    // print('checkpostidEvent========>$checkpostidEvent');
    // print('mypostid================>$mypostid');
    // print(checkpostidEvent);
    // print(checktype);
    // print(joinEvent.requestpostid);
    print('_token=>>>>>>>>>>>>>>>>>>>$_token');

    headerImageSize = MediaQuery.of(context).size.height / 2.5;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid.toString();
    myuid = uid;
    totallike = postDetails.likes;
    // print('totallike=>>>>>$totallike');

    var postuid = postDetails.postid;
    // checktype=joinEvent.type;
    // print(checktype);

    themeData = Theme.of(context);
    // print('otheremail$otheremail');

    headerImageSize = MediaQuery.of(context).size.height / 2.5;
    return ScaleTransition(
      scale: scale,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildHeaderImage(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildEventTitle(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),

                          UIHelper.verticalSpace(16),
                          buildEventDate(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(24),
                          buildAboutEvent(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(24),
                          buildOrganizeInfo(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(24),
                          buildGender(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(24),
                          buildAge(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(24),
                          buildEventLocation(),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          UIHelper.verticalSpace(124),
                          //...List.generate(10, (index) => ListTile(title: Text("Dummy content"))).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              visibilitybutt == false && checkissendrequest != true
                  ? Align(
                      child: isExpired == false
                          ? buildEXPNull()
                          : buildJoinScreen(),
                      alignment: Alignment.bottomCenter,
                    )
                  : Align(
                      child: isExpired == false
                          ? buildEXPNull()
                          : buildCancelScreen(),
                      alignment: Alignment.bottomCenter,
                    ),
              AnimatedBuilder(
                animation: appBarSlide,
                builder: (context, snapshot) {
                  return Transform.translate(
                    offset: Offset(0.0, -1000 * (1 - appBarSlide.value)),
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).primaryColor,
                      child: buildHeaderButton(hasTitle: true),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  expireeven() {
    Dialogs.materialDialog(
        color: Colors.white,
        // msg: 'Congratulations, you won 500 points',
        title: 'Expire',
        // animation: 'assets/cong_example.json',
        context: context,
        actions: [
          IconsButton(
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => MyApp()),
                  (Route<dynamic> route) => false);
            },
            text: 'Close',
            // iconData: Icons.done,
            color: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }

  AlertJoinScreen() {
    // Dialogs.materialDialog(
    //     color: Colors.white,
    //     // msg: 'Congratulations, you won 500 points',
    //     title: 'ส่งคำขอ',
    //     animation: 'assets/cong_example.json',
    //     context: context,
    //     actions: [
    //       IconsButton(
    //         onPressed: () async {
    //           print('$mypostid โพสของฉัน');
    //           print('$checkpostidEvent โพสidอีเว้น');
    //           print('$checksenderUid uidคนส่ง');

    //           //  if (mypostid!=checkpostidEvent) {
    //           //
    //           // }
    //           eventreq(joinEvent);
    //           Navigator.pop(context);
    //         },
    //         text: 'Join',
    //         iconData: Icons.done,
    //         color: Colors.blue,
    //         textStyle: TextStyle(color: Colors.white),
    //         iconColor: Colors.white,
    //       ),
    //     ]);

    Alert(
      context: context,
      // type: AlertType.info,
      title: "ส่งคำขอ",
      content: Column(
        children: <Widget>[
          // Text("ส่งคำขอ",
          //   style: TextStyle(
          //       fontSize: 20,
          //       color: Colors.black
          //   ),
          // ),
          Text(
            "let the Hoster get to know you more!.",
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 15,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(widget.userData.profilePhoto),
                      fit: BoxFit.cover),
                ),
              ),
              // Container(
              //   padding:  EdgeInsets.all(6),
              //   decoration: BoxDecoration(
              //     color: themeData.colorScheme.primary
              //         .withAlpha(24),
              //     borderRadius: BorderRadius.all(
              //         Radius.circular(8)),
              //   ),
              // ),
              SizedBox(
                width: 50,
              ),
              Icon(
                MdiIcons.accountArrowRight,
                size: 23,
                color: themeData.colorScheme.primary,
              ),
              SizedBox(
                width: 25,
              ),
              SizedBox(
                width: 20,
              ),

              Container(
                width: 50,
                height: 50,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   image: DecorationImage(
                //       image: NetworkImage(postDetails.postbyimage),
                //       fit: BoxFit.cover),
                // ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: postDetails.postbyimage != null
                      ? DecorationImage(
                          image: NetworkImage(postDetails.postbyimage),
                          fit: BoxFit.cover)
                      : DecorationImage(
                          image: NetworkImage("assets/profile1.png"),
                          fit: BoxFit.cover),
                ),
                // child: FadeInImage.assetNetwork(
                //   image: postDetails.postbyimage,
                //   fit: BoxFit.fill,
                //   height: 120.0,
                //   width: 120.0,
                //   placeholder:
                //   "assets/profile1.png",
                // ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Join',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            print('$mypostid โพสของฉัน');
            print('$checkpostidEvent โพสidอีเว้น');
            print('$checksenderUid uidคนส่ง');

            //  if (mypostid!=checkpostidEvent) {
            //
            // }
            eventreq(joinEvent);
            Navigator.pop(context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  AlertCancelScreen() {
    Alert(
      context: context,
      // type: AlertType.info,
      title: "ยกเลิกคำขอ",
      content: Column(
        children: <Widget>[
          // Text("ส่งคำขอ",
          //   style: TextStyle(
          //       fontSize: 20,
          //       color: Colors.black
          //   ),
          // ),
          Text(
            "let the Hoster get to know you more!.",
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 15,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(widget.userData.profilePhoto),
                      fit: BoxFit.cover),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary.withAlpha(24),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Icon(
                MdiIcons.accountArrowRight,
                size: 23,
                color: themeData.colorScheme.primary,
              ),
              SizedBox(
                width: 30,
              ),
              SizedBox(
                width: 25,
              ),
              Container(
                width: 50,
                height: 50,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   image: DecorationImage(
                //       image: NetworkImage(postDetails.postbyimage),
                //       fit: BoxFit.cover),
                // ),
                child: FadeInImage.assetNetwork(
                  image: postDetails.postbyimage,
                  fit: BoxFit.fill,
                  height: 120.0,
                  width: 120.0,
                  placeholder: "assets/profile1.png",
                ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            print('$mypostid โพสของฉัน');
            print('$checkpostidEvent โพสidอีเว้น');
            print('$checksenderUid uidคนส่ง');

            // if(mypostid==checkpostidEvent&& myuid == checksenderUid){
            //   retractrequest();
            // }else if (checkpostidEvent==mypostid) {
            //   retractrequest();
            // }
            retractrequest();

            Navigator.pop(context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  test3() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "RFLUTTER ALERT",
      desc: "Flutter is more awesome with RFlutter Alert.",
      buttons: [
        DialogButton(
          child: Text(
            "Report",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {},
          width: 120,
        )
      ],
    ).show();
  }

  getRequestStatus() async {
    final joineventref = FirebaseFirestore.instance.collection('JoinEvent');
    return joineventref
        .doc(postDetails.uid)
        .collection('JoinEventList')
        //.document(senderEmail)
        .where('sendjoinbyuid', isEqualTo: myuid)
        // .get();
        .where('type', isEqualTo: 'request')
        .snapshots();
  }

/*ลบrequest */
  retractrequest() async {
    final db = FirebaseFirestore.instance;
    final uEmail = await AuthService().getCurrentEmail();

    print('retracted');
    // if (this.mounted) {
    //   setState(() {
    //     // following = false;
    //     sentrequest = false;
    //     acceptedrequest = false;
    //     // toggleFollow = "Follow";
    //   });
    // }
    await FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(postDetails.uid)
        .collection('JoinEventList')
        // .where('requestpostid', isEqualTo: mypostid)
        .where('joinid', isEqualTo: joinid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                  setState(() {
                    visibilitybutt = false;
                    print(visibilitybutt.toString());
                  });
                }
              })
            });

    //   await  db.collection("JoinEvent")
    //       .doc(uEmail)
    //       .collection('JoinEventList')
    //       .doc()
    //     .get()
    //     .then((doc) {
    //   if (doc.exists) {
    //     doc.reference.delete();
    //   }
    // });
    print('retracted successfully');
  }

/*ส่งrequest */
  eventreq(JoinEvent joinevent) async {
    final uid = await AuthService().getCurrentUID();
    final uEmail = await AuthService().getCurrentEmail();
    // final joineventref = FirebaseFirestore.instance.collection('JoinEvent');

    var postid = postDetails.postid;
    var postbyuid = postDetails.uid;

    // db.collection("JoinEvent")
    //     .doc(postDetails.uid)
    //     .collection('JoinEventList')
    //     .doc(myuid)

    CollectionReference joineventref = FirebaseFirestore.instance
        .collection("JoinEvent")
        .doc(postDetails.uid)
        .collection('JoinEventList');

    joinevent.type = "sent";
    joinevent.ownerID = postDetails.uid;
    joinevent.ownerName = postDetails.postbyname;
    joinevent.title = postDetails.name;
    joinevent.postid = postid;
    joinevent.createdAt = Timestamp.now();
    joinevent.senderAvatar = widget.userData.profilePhoto;
    joinevent.senderName = widget.userData.name;
    joinevent.senderUid = myuid;
    joinevent.receiverUidjoin = postDetails.uid;
    joinevent.requestpostid = postDetails.postid;
    joinevent.senderEmail = widget.userData.email;
    joinevent.status = 'request';
    joinEvent.receiveremail = postDetails.emailuser;

    DocumentReference documentRef = await joineventref.add(joinevent.toMap());
    joinevent.joinid = documentRef.id;

    await documentRef.set(joinevent.toMap()).then((result) {
      setState(() {
        // _changed(false,joinEvent);
        visibilitybutt = true;
      });

      print("eventreq successfully");
      print(visibilitybutt.toString());
    }).catchError((onError) {
      print("onError");
    });

    setState(() {
      // _changed(false,joinEvent);

      visibilitybutt = true;
    });

    print('JoinEvent  successfully: ${joinevent.toString()}');
  }

  // checkIfSentRequest() async {
  //   final chatReference = FirebaseFirestore.instance.collection('JoinEvent');
  //   await chatReference
  //       .doc(myuid)
  //       .collection('JoinEventList')
  //       .doc('bQoJCNb4kL2gj2RrfhE9')
  //       .get()
  //       .then((value) => {
  //             print(value.exists),
  //             if (value.exists)
  //               {
  //                 sentrequest = value.exists,
  //                 chatReference
  //                     .doc(myuid)
  //                     .collection('JoinEventList')
  //                     .doc('bQoJCNb4kL2gj2RrfhE9')
  //                     .get()
  //                     .then((val) {
  //                   if (!(val.exists) &&
  //                       value.data()['requestpostid'] == mypostid) {
  //                     setState(() {
  //                       // following = true;
  //                       sentrequest = true;
  //                       acceptedrequest = true;
  //                       print('acceptedrequest$acceptedrequest');

  //                       checkIfAlreadyFollowing();
  //                     });
  //                   }
  //                 })
  //               }
  //           });
  // }

  // checkIfAlreadyFollowing() async {
  //   final uEmail = await AuthService().getCurrentEmail();
  //   CollectionReference joineventref =
  //       FirebaseFirestore.instance.collection("JoinEvent");
  //   CollectionReference users =
  //       FirebaseFirestore.instance.collection('JoinEvent');

  //   // final joineventref = FirebaseFirestore.instance.collection('JoinEvent');

  //   // await   users.doc(uEmail).collection('JoinEventList')
  //   //        .get()
  //   //        .then((QuerySnapshot value) => {
  //   //      print(value.exists),
  //   //      if (this.mounted){
  //   //          setState(() {
  //   //            if (value.exists) {
  //   //              sentrequest = value.exists;
  //   //
  //   //              if (!(value.exists) && value.data()['type'] != 'request') {
  //   //                if (this.mounted) {
  //   //                  setState(() {
  //   //                    sentrequest = true;
  //   //                    acceptedrequest = true;
  //   //
  //   //                    print(value);
  //   //                  });
  //   //                }
  //   //                eventreq(_joinEvent);
  //   //                print("ไม่มีค่า");
  //   //              }
  //   //              print("มีค่า");
  //   //
  //   //            }
  //   //          })
  //   //        }
  //   //    });
  // }

  Future getCloudFirestoreJoinEvent() async {
    print("getCloudFirestoreJoinEvent");

    //assumes you have a collection called "users"
    FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(postDetails.uid)
        .collection('JoinEventList')
        .where('senderUid', isEqualTo: myuid)
        .orderBy('requestpostid')
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      var totalreq;
      totalreq = querySnapshot.docs.length.toString();
      print(totalreq);
      print("requestpostid: results: length: " +
          querySnapshot.docs.length.toString());
      querySnapshot.docs.forEach((value) {
        print("requestpostid: results: value");
        print(value.get('requestpostid'));

        if ((value.exists) && value.get('requestpostid') == mypostid) {
          print(value.get('requestpostid'));
          joinid = value.get('joinid');
          print(joinid = value.get('joinid'));

          if (this.mounted) {
            setState(() {
              checkissendrequest = true;
              acceptedrequest = true;
              print('sentrequest$sentrequest');
            });
          }
        }
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  void launchMap(String address) async {
    String query = Uri.encodeComponent(address);
    String googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  }

  _launchMaps(String address) async {
    String query = Uri.encodeComponent(address);

    String googleUrl = 'comgooglemaps://?center=$query';
    String appleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch("comgooglemaps://")) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

  getDataFromJoinEvent() async {
    final uEmail = await AuthService().getCurrentEmail();
    FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(postDetails.uid)
        .collection('JoinEventList')
        .where('senderUid', isEqualTo: myuid)
        .orderBy('requestpostid')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc.exists) {
                  setState(() {
                    checksenderUid = doc['senderUid'];
                    // checkpostidEvent=doc['requestpostid'];
                    checktype = doc['type'];
                    // joinid = doc['joinid'];
                  });
                }

                print(checkpostidEvent);
                // print(checksenderUid);
              })
            });
  }

  // _buildPostDetailsv1(postDetails) {
  //   headerImageSize = MediaQuery.of(context).size.height / 2.5;
  //   return ScaleTransition(
  //     scale: scale,
  //     child: BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
  //       child: Scaffold(
  //         body: Stack(
  //           children: <Widget>[
  //             SingleChildScrollView(
  //               controller: scrollController,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   buildHeaderImage(),
  //                   Container(
  //                     padding: const EdgeInsets.all(16),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: <Widget>[
  //                         buildEventTitle(),
  //                         UIHelper.verticalSpace(16),
  //                         buildEventDate(),
  //                         UIHelper.verticalSpace(24),
  //                         buildAboutEvent(),
  //                         UIHelper.verticalSpace(24),
  //                         buildOrganizeInfo(),
  //                         UIHelper.verticalSpace(24),
  //                         // buildEventLocation(),
  //                         UIHelper.verticalSpace(124),
  //                         //...List.generate(10, (index) => ListTile(title: Text("Dummy content"))).toList(),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Align(
  //               child: buildCancelScreen(),
  //               alignment: Alignment.bottomCenter,
  //             ),
  //             AnimatedBuilder(
  //               animation: appBarSlide,
  //               builder: (context, snapshot) {
  //                 return Transform.translate(
  //                   offset: Offset(0.0, -1000 * (1 - appBarSlide.value)),
  //                   child: Material(
  //                     elevation: 2,
  //                     color: Theme.of(context).primaryColor,
  //                     child: buildHeaderButton(hasTitle: true),
  //                   ),
  //                 );
  //               },
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildHeaderImage() {
    double maxHeight = MediaQuery.of(context).size.height;
    double minimumScale = 0.8;
    return GestureDetector(
      onVerticalDragUpdate: (detail) {
        controller.value += detail.primaryDelta / maxHeight * 2;
      },
      onVerticalDragEnd: (detail) {
        if (scale.value > minimumScale) {
          controller.reverse();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: headerImageSize,
            child: Hero(
              tag: postDetails.image,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
                child: Image.network(
                  postDetails.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          buildHeaderButton(),
        ],
      ),
    );
  }

  Widget buildHeaderButton({bool hasTitle = false}) {
    const titleStyle = TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              child: InkWell(
                onTap: () {
                  if (bodyScrollAnimationController.isCompleted)
                    bodyScrollAnimationController.reverse();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: hasTitle ? Colors.white : Colors.black,
                  ),
                ),
              ),
              color: hasTitle ? Theme.of(context).primaryColor : Colors.white,
            ),
            if (hasTitle)
              Text(postDetails.name,
                  style: titleStyle.copyWith(color: Colors.white)),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: hasTitle ? Colors.white : Colors.black,
                ),
                // color: hasTitle ? Colors.white : Colors.black,
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'Report'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
              color: hasTitle ? Theme.of(context).primaryColor : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Report':
        test3();
        break;
    }
  }

  Widget buildEventTitle() {
    const headerStyle = TextStyle(
        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold);
    return Container(
      child: Row(
        children: [
          Text(
            postDetails.name,
            style: headerStyle.copyWith(fontSize: 32),
          ),
          Card(
            color: DesignCourseAppTheme.nearlyBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0)),
            elevation: 20.0,
            child: Container(
              width: 40,
              height: 40,
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.only(left: 2),
                  onPressed: liked
                      ? () {
                          setState(() {
                            liked = false;
                            unlikepost(mylikes, postDetails.postid);
                          });
                        }
                      : () {
                          setState(() {
                            liked = true;
                            likepost(mylikes, postDetails.postid);
                          });
                        },
                  icon: liked
                      ? Icon(Icons.favorite_rounded)
                      : Icon(Icons.favorite_border),
                  iconSize: 25,
                  color: liked ? Colors.redAccent : Colors.white,
                ),

                // Icon(
                //   Icons.favorite,
                //   color: DesignCourseAppTheme.nearlyWhite,
                //   size: 20,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEventDate() {
    const titleStyle = TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);

    return Container(
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${DateTimeUtils.getMonth(postDetails.startdateTime.toDate())}",
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.primary, fontWeight: 600),
                ),
                Text(
                    "${DateTimeUtils.getDayOfMonth(postDetails.startdateTime.toDate())}",
                    style: titleStyle),
              ],
            ),
          ),
          UIHelper.horizontalSpace(12),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  DateTimeUtils.getDayOfWeek(
                      postDetails.startdateTime.toDate()),
                  style: titleStyle),
              UIHelper.verticalSpace(4),
              Text("10:00 - 12:00 PM", style: subtitleStyle),
            ],
          ),
          Spacer(),
          UIHelper.horizontalSpace(16),
// SizedBox(width: 100,),
          Spacer(),

          // Container(
          //   padding: const EdgeInsets.all(2),
          //   child: Row(
          //     children: <Widget>[
          //       Container(
          //         child: FloatingActionButton(
          //           mini: true,
          //           onPressed: () => setState(() => isFavorite = !isFavorite),
          //           child: Icon(
          //               isFavorite ? Icons.favorite : Icons.favorite_border,
          //               color: Colors.white),
          //         ),
          //       ),
          //       // UIHelper.horizontalSpace(8),
          //     ],
          //   ),
          // ),
          // Card(
          //   shape: CircleBorder(),
          //   elevation: 0,
          //   child: InkWell(
          //     customBorder: CircleBorder(),
          //     onTap: () => setState(() => isFavorite = !isFavorite),
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Icon(
          //           isFavorite ? Icons.favorite : Icons.favorite_border,
          //           color: Colors.white),
          //     ),
          //   ),
          //   color: Theme.of(context).primaryColor,
          // ),
          // Card(
          //   color: DesignCourseAppTheme.nearlyBlue,
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(50.0)),
          //   elevation: 10.0,
          //   child: Container(
          //     width: 60,
          //     height: 60,
          //     child: Center(
          //       child: Icon(
          //         Icons.favorite,
          //         color: DesignCourseAppTheme.nearlyWhite,
          //         size: 30,
          //       ),
          //     ),
          //   ),
          // ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Icon(FrinoIcons.f_male),
          //                   SizedBox(width: 20,),
          //                   Flexible(
          //                     child: Text(postDetails.gender,style: TextStyle(
          //                         fontSize: 16,
          //                         height: 1.5
          //                     ),
          //                         ),
          //
          //    )],
          // ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildAboutEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("About", style: headerStyle),
        UIHelper.verticalSpace(),
        InkWell(
          child: ExpandableText(
            postDetails.description,
            style: subtitleStyle,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: 2,
            linkColor: Colors.blue,
            onExpandedChanged: (value) => print(value),
          ),
          onTap: () {},
        ),
        UIHelper.verticalSpace(8),
      ],
    );
  }

  Widget buildOrganizeInfo() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () async {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (BuildContext context) => ChangeNotifierProvider(
                  create: (context) => PostNotifier(),
                  builder: (context, child) => Otherprofile(
                    postDetails: postDetails,
                    user: widget.userData,
                  ),
                ),
              ),
            );
          },
          child: CircleAvatar(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: FadeInImage.assetNetwork(
                image: postDetails.postbyimage,
                fit: BoxFit.fill,
                height: 120.0,
                width: 120.0,
                placeholder: "assets/profile1.png",
              ),
            ),
          ),
        ),

        UIHelper.horizontalSpace(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () async {
                UserDataProfileNotifier profileNotifier =
                    Provider.of<UserDataProfileNotifier>(context,
                        listen: false);
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => Otherprofile(user: widget.userData),
                  ),
                );
                if (navigationResult == true) {
                  setState(() {
                    getProfile(profileNotifier);
                  });
                }
              },
              child: Text(postDetails.postbyname, style: titleStyle),
            ),
            UIHelper.verticalSpace(4),
            Text("Host", style: subtitleStyle),
          ],
        ),
        Spacer(),
        // FlatButton(
        //   child: Text("Follow",
        //       style: TextStyle(color: Theme.of(context).primaryColor)),
        //   onPressed: () {},
        //   shape: StadiumBorder(),
        //   color: primaryLight,
        // )
      ],
    );
  }

  Widget buildGender() {
    return Row(
      children: <Widget>[
        Icon(FrinoIcons.f_male),
        SizedBox(
          width: 20,
        ),
        Flexible(
          child: Text(
            postDetails.gender,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        UIHelper.horizontalSpace(16),
        Spacer(),
      ],
    );
  }

  Widget buildAge() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: themeData.colorScheme.primary.withAlpha(24),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Icon(
            MdiIcons.humanChild,
            size: 18,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 15),
            child: Text(
              '${str.substring(startIndex + start.length)}',
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyText2,
                fontWeight: 600,
                letterSpacing: 0.3,
                color: Colors.black,
              ),
            ),
          ),
        ),
        UIHelper.horizontalSpace(16),
        Spacer(),
      ],
    );
  }

  Widget buildEventLocation() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: themeData.colorScheme.primary.withAlpha(24),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Icon(
            Icons.location_on,
            size: 18,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 15),
            child: InkWell(
              onTap: () async => _launchMaps(postDetails.place.toString()),
              child: Text(
                postDetails.place.toString(),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyText2,
                  fontWeight: 600,
                  letterSpacing: 0.3,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        UIHelper.horizontalSpace(16),
        Spacer(),
      ],
    );
  }

  Widget buildCancelScreen() {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Text("Price", style: subtitleStyle),
              UIHelper.verticalSpace(8),
              RichText(
                text: TextSpan(
                  children: [
                    // TextSpan(
                    //     text: "\$${event.price}",
                    //     style: titleStyle.copyWith(
                    //         color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          RaisedButton(
            onPressed: () {
              var uidpost = postDetails.uid;

              print('$mypostid โพสของฉัน');
              print('$checkpostidEvent โพสidอีเว้น');
              print('$checksenderUid uidคนส่ง');

              if (uidpost == myuid) {
                Navigator.pop(context);
              } else if (uidpost != myuid) {
                AlertCancelScreen();
              }
            },
            shape: StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Theme.of(context).primaryColor,
            child: Text(
              "Cancel",
              style: titleStyle.copyWith(
                  color: Colors.white, fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }

  Widget buildJoinScreen() {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[],
          ),
          Spacer(),
          RaisedButton(
            onPressed: () {
              uidpost = postDetails.uid;

              print('$mypostid โพสของฉัน');
              print('$checkpostidEvent โพสidอีเว้น');
              print('$checksenderUid uidคนส่ง');

              if (uidpost == myuid) {
                Navigator.pop(context);
              } else if (uidpost != myuid) {
                AlertJoinScreen();
              }
            },
            shape: StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Theme.of(context).primaryColor,
            child: Text(
              "Join",
              style: titleStyle.copyWith(
                  color: Colors.white, fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }

  Widget buildEXPNull() {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[],
          ),
          Spacer(),
          // RaisedButton(
          //   onPressed: () {
          //     uidpost = postDetails.uid;

          //     print('$mypostid โพสของฉัน');
          //     print('$checkpostidEvent โพสidอีเว้น');
          //     print('$checksenderUid uidคนส่ง');

          //     if (uidpost == myuid) {
          //       Navigator.pop(context);
          //     } else if (uidpost != myuid) {
          //       test1();
          //     }
          //   },
          //   shape: StadiumBorder(),
          //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //   color: Theme.of(context).primaryColor,
          //   child: Text(
          //     "Join",
          //     style: titleStyle.copyWith(
          //         color: Colors.white, fontWeight: FontWeight.normal),
          //   ),
          // )
        ],
      ),
    );
  }
}
