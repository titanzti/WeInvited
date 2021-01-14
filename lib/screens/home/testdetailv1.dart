import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/Notification/EventUserScreen.dart';
import 'package:we_invited/screens/Notification/Notifica.dart';
import 'package:we_invited/screens/home/design_course_app_theme.dart';
import 'package:we_invited/screens/home/hotel_app_theme.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/text_style.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/SizeConfig.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/datetime_utils.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/ui_helper.dart';
class PostDetailsV1 extends StatefulWidget {
  final Post postDetails ;
  final UserDataProfile userData;
  final JoinEvent joinEvent1;

  PostDetailsV1(this.postDetails, this.userData, this.joinEvent1);

  @override
  _PostDetailsV1State createState() => _PostDetailsV1State(postDetails,joinEvent1);
}

class _PostDetailsV1State extends State<PostDetailsV1> with TickerProviderStateMixin {
  ThemeData themeData;
  final JoinEvent joinEvent1;

  _PostDetailsV1State(this.postDetails,this.joinEvent1);
  final double infoHeight = 364.0;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;

  Post postDetails = Post();
  JoinEvent joinEvent = JoinEvent();

  bool acceptedrequest = false;
  bool sentrequest = false;
  var checkpostidEvent = [] ;
  var  checksenderUid;
  var checktype;
  var mypostid;
  var mypostuid;
  var myuid;
  var uidpost;
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

    checkInternetConnectivity().then((value)   => {
      value == true
          ? () {
         getData();
        // checkData();

        visibilitybutt = false;

        JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
            listen: false);
        getEvenReqPosts(joinNotifier);


        mypostuid = postDetails.uid;
        mypostid= postDetails.postid;


         getCloudFirestoreUsers();



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
        mypostid= postDetails.postid;


         checkIfSentRequest();

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

    QuerySnapshot snapshot= await  FirebaseFirestore.instance
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
     // getData();
    JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
        listen: false);
        getEvenReqPosts(joinNotifier);
    // checkpostidEvent.forEach((vale) => print(vale.toString())); // => banana pineapple watermelon


    // print('checkpostidEvent========>$checkpostidEvent');
    print('mypostid================>$mypostid');
    // print(checkpostidEvent);
    // print(checktype);
    // print(joinEvent.requestpostid);

    headerImageSize = MediaQuery.of(context).size.height / 2.5;


    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid.toString();
    myuid=  uid;

    var postuid =postDetails.postid;
    // checktype=joinEvent.type;
    // print(checktype);


    themeData = Theme.of(context);

    headerImageSize = MediaQuery.of(context).size.height / 2.5;
    return ScaleTransition(
      scale: scale,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Scaffold(
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
                          UIHelper.verticalSpace(16),
                          buildEventDate(),
                          UIHelper.verticalSpace(24),
                          buildAboutEvent(),
                          UIHelper.verticalSpace(24),
                          buildOrganizeInfo(),
                          UIHelper.verticalSpace(24),
                          // buildEventLocation(),
                          UIHelper.verticalSpace(124),
                          //...List.generate(10, (index) => ListTile(title: Text("Dummy content"))).toList(),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Align(
                child:    visibilitybutt==false && checkissendrequest!=true ?  buildPriceInfoNull():buildPriceInfo(),
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
  test1(){
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
          Text("let the Hoster get to know you more!.",
            style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey
            ),
          ),
          SizedBox(height: 25,),
          Row(
            children: <Widget>[
              SizedBox(width: 15,),
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
                padding:  EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary
                      .withAlpha(24),
                  borderRadius: BorderRadius.all(
                      Radius.circular(8)),
                ),
              ),
              SizedBox(width: 30,),
              Icon(
                MdiIcons.accountArrowRight,
                size: 23,
                color: themeData.colorScheme.primary,
              ),
              SizedBox(width: 30,),
              SizedBox(width: 25,),

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
                  placeholder:
                  "assets/profile1.png",
                ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text('Join', style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () async {
            print('$mypostid โพสของฉัน');
            print('$checkpostidEvent โพสidอีเว้น');
            print('$checksenderUid uidคนส่ง');


            //  if (mypostid!=checkpostidEvent) {
            //
            // }
            eventreq(joinEvent);
            Navigator.pop(context);


          } ,
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),

      ],
    ).show();
  }

  test2(){
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
          Text("let the Hoster get to know you more!.",
            style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey
            ),
          ),
          SizedBox(height: 25,),
          Row(
            children: <Widget>[
              SizedBox(width: 15,),
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
                padding:  EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary
                      .withAlpha(24),
                  borderRadius: BorderRadius.all(
                      Radius.circular(8)),
                ),
              ),
              SizedBox(width: 30,),
              Icon(
                MdiIcons.accountArrowRight,
                size: 23,
                color: themeData.colorScheme.primary,
              ),
              SizedBox(width: 30,),
              SizedBox(width: 25,),

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
                  placeholder:
                  "assets/profile1.png",
                ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 20),),
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


          } ,
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),

      ],
    ).show();
  }
  getRequestStatus() async {
    final   joineventref = FirebaseFirestore.instance.collection('JoinEvent');
    return    joineventref
        .doc(postDetails.uid)
        .collection('JoinEventList')
    //.document(senderEmail)
        .where('sendjoinbyuid', isEqualTo: myuid)
    // .get();
        .where('type', isEqualTo: 'request')
        .snapshots();
  }
  retractrequest( ) async {
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
        .collection('JoinEvent').doc(postDetails.uid).collection('JoinEventList')
        .where('requestpostid',isEqualTo: mypostid)
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

    CollectionReference joineventref =  FirebaseFirestore.instance
        .collection("JoinEvent")
        .doc(postDetails.uid)
        .collection('JoinEventList');

    joinevent.type = "sent";
    joinevent.ownerID = postDetails.uid;
    joinevent.ownerName = postDetails.postbyname;
    joinevent.title = postDetails.name;
    joinevent.postid =postid;
    joinevent.createdAt = Timestamp.now() ;
    joinevent.senderAvatar = widget.userData.profilePhoto;
    joinevent.senderName = widget.userData.name;
    joinevent.senderUid = myuid;
    joinevent.receiverUidjoin = postDetails.uid;
    joinevent.requestpostid = postDetails.postid;
    joinevent.senderEmail = widget.userData.email;
    joinevent.status = 'request';



    DocumentReference documentRef = await joineventref.add(joinevent.toMap());
    joinevent.joinid = documentRef.id;


    await documentRef.set(joinevent.toMap()).then((result){
      setState(() {
        // _changed(false,joinEvent);
        visibilitybutt = true;
      });

      print("eventreq successfully");
      print(visibilitybutt.toString());

    }).catchError((onError){
      print("onError");
    });

    setState(() {
      // _changed(false,joinEvent);

      visibilitybutt = true;
    });

    print('JoinEvent  successfully: ${joinevent.toString()}');

  }
  checkIfSentRequest() async {
    final chatReference = FirebaseFirestore.instance.collection('JoinEvent');
    await chatReference
        .doc(myuid)
        .collection('JoinEventList')
        .doc('bQoJCNb4kL2gj2RrfhE9')
        .get()
        .then((value) => {
      print(value.exists),
      if (value.exists)
        {
          sentrequest = value.exists,
          chatReference
              .doc(myuid)
              .collection('JoinEventList')
              .doc('bQoJCNb4kL2gj2RrfhE9')
              .get()
              .then((val) {
            if (!(val.exists) && value.data()['requestpostid'] == mypostid) {
              if (this.mounted) {
                setState(() {
                  // following = true;
                  sentrequest = true;
                  acceptedrequest = true;
                  print('acceptedrequest$acceptedrequest');

                  checkIfAlreadyFollowing();
                });
              }
            }
          })
        }
    });
  }
  checkIfAlreadyFollowing() async {
    final uEmail = await AuthService().getCurrentEmail();
    CollectionReference joineventref = FirebaseFirestore.instance .collection("JoinEvent");
    CollectionReference users = FirebaseFirestore.instance.collection('JoinEvent');

    // final joineventref = FirebaseFirestore.instance.collection('JoinEvent');

    // await   users.doc(uEmail).collection('JoinEventList')
    //        .get()
    //        .then((QuerySnapshot value) => {
    //      print(value.exists),
    //      if (this.mounted){
    //          setState(() {
    //            if (value.exists) {
    //              sentrequest = value.exists;
    //
    //              if (!(value.exists) && value.data()['type'] != 'request') {
    //                if (this.mounted) {
    //                  setState(() {
    //                    sentrequest = true;
    //                    acceptedrequest = true;
    //
    //                    print(value);
    //                  });
    //                }
    //                eventreq(_joinEvent);
    //                print("ไม่มีค่า");
    //              }
    //              print("มีค่า");
    //
    //            }
    //          })
    //        }
    //    });
  }

  Future getCloudFirestoreUsers() async {
    print("getCloudFirestore");

    //assumes you have a collection called "users"
    FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(postDetails.uid)
        .collection('JoinEventList')
        .where('senderUid',isEqualTo: myuid)
        .orderBy('requestpostid').get().then((querySnapshot) {
      //print(querySnapshot);
      print("requestpostid: results: length: " + querySnapshot.docs.length.toString());
      querySnapshot.docs.forEach((value) {

        print("requestpostid: results: value");
        print(value.get('requestpostid'));

        if ((value.exists) && value.get('requestpostid') == mypostid) {
          print(value.get('requestpostid'));

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


  getData() async {
    final uEmail = await AuthService().getCurrentEmail();
    FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(postDetails.uid)
        .collection('JoinEventList')
        .where('senderUid',isEqualTo: myuid)
        .orderBy('requestpostid')
        .get()
        .then((QuerySnapshot querySnapshot) => {



      querySnapshot.docs.forEach((doc) {

        if (doc.exists) {
          setState(() {

            checksenderUid=doc['senderUid'];
            // checkpostidEvent=doc['requestpostid'];
            checktype=doc['type'];


          });
        }

        // checktype = doc["type"];
        // checkpostidEvent=doc;


        // checkpostid=='wo19JbnLdGqwlB5P54jt'?print('ใช่postid'):print('ไม่ใช่postid');
        //  checktype!='accepted'?print('ไม่ใช่accepted'):print('ใช่accepted');
        // checktype=='request'? print('ใช่'):print('ไม่ใช่');

        print(checkpostidEvent);
        // print(checksenderUid);

      })
    });

    // final snapShot = await FirebaseFirestore.instance
    //     .collection('JoinEvent').doc(uEmail).collection('JoinEventList')
    //  .get()
    //
    // if (snapShot == null || !snapShot.exists) {
    //   // Document with id == docId doesn't exist.
    // }
  }
  _buildPostDetailsv1(postDetails) {
    headerImageSize = MediaQuery.of(context).size.height / 2.5;
    return ScaleTransition(
      scale: scale,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Scaffold(
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
                          UIHelper.verticalSpace(16),
                          buildEventDate(),
                          UIHelper.verticalSpace(24),
                          buildAboutEvent(),
                          UIHelper.verticalSpace(24),
                          buildOrganizeInfo(),
                          UIHelper.verticalSpace(24),
                          // buildEventLocation(),
                          UIHelper.verticalSpace(124),
                          //...List.generate(10, (index) => ListTile(title: Text("Dummy content"))).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                child: buildPriceInfo(),
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
    const titleStyle = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
              Text(postDetails.name, style: titleStyle.copyWith(color: Colors.white)),
            Card(
              shape: CircleBorder(),
              elevation: 0,
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: () => setState(() => isFavorite = !isFavorite),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white),
                ),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEventTitle() {
    const headerStyle = TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold);

    return Container(
      child: Text(
        postDetails.name,
        style: headerStyle.copyWith(fontSize: 32),
      ),
    );
  }

  Widget buildEventDate() {
    const titleStyle = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);

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
                Text("${DateTimeUtils.getMonth(postDetails.startdateTime.toDate())}",
                    style: monthStyle),
                Text("${DateTimeUtils.getDayOfMonth(postDetails.startdateTime.toDate())}",
                    style: titleStyle),
              ],
            ),
          ),
          UIHelper.horizontalSpace(12),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Text(DateTimeUtils.getDayOfWeek(postDetails.startdateTime.toDate()),
                  style: titleStyle),
              UIHelper.verticalSpace(4),
              Text("10:00 - 12:00 PM", style: subtitleStyle),
            ],
          ),
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
        Text(postDetails.description, style: subtitleStyle),
        UIHelper.verticalSpace(8),
        InkWell(
          child: Text(
            "Read more...",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget buildOrganizeInfo() {
    return Row(
      children: <Widget>[
        CircleAvatar(

          child: ClipRRect(
            child: FadeInImage.assetNetwork(
              image: postDetails.postbyimage,
              fit: BoxFit.fill,
              height: 120.0,
              width: 120.0,
              placeholder:
              "assets/profile1.png",
            ),
          ),
        ),
        UIHelper.horizontalSpace(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(postDetails.postbyname, style: titleStyle),
            UIHelper.verticalSpace(4),
            Text("Host", style: subtitleStyle),
          ],
        ),
        Spacer(),
        FlatButton(
          child: Text("Follow",
              style: TextStyle(color: Theme.of(context).primaryColor)),
          onPressed: () {},
          shape: StadiumBorder(),
          color: primaryLight,
        )
      ],
    );
  }

  Widget buildEventLocation() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/map.jpg',
        height: MediaQuery.of(context).size.height / 3,
        fit: BoxFit.cover,
      ),
    );
  }


  Widget buildPriceInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
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

              if (uidpost== myuid) {
                Navigator.pop(context);
              }
              else if (uidpost != myuid){
                test2();
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

  Widget buildPriceInfoNull() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

            ],
          ),
          Spacer(),
          RaisedButton(
            onPressed: () {
              uidpost = postDetails.uid;

              print('$mypostid โพสของฉัน');
              print('$checkpostidEvent โพสidอีเว้น');
              print('$checksenderUid uidคนส่ง');

              if (uidpost== myuid) {
                Navigator.pop(context);
              }
              else if (uidpost != myuid){
                test1();
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

}
