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
import 'package:we_invited/screens/Notification/EventUserScreen.dart';
import 'package:we_invited/screens/Notification/myjoinScreenList.dart';

import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/notifier/myjoin_notifier.dart';
import 'dart:async';

class NotificationPage extends StatefulWidget {
  final Post postDetails;
  final UserDataProfile userData;
  NotificationPage({Key key, this.postDetails, this.userData})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Post postDetails = Post();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController _postsController;

  var myuid,status,senderUid;

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqPosts(joinNotifier);

                    MyJoinNotifier mysendjoinNotifier =
                      Provider.of<MyJoinNotifier>(context, listen: false);
                  getMyreqEvent(mysendjoinNotifier);

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
              _postsController = new StreamController();

    super.initState();
  }

  getMyPosts(PostNotifier postNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Posts")
        .where("uid", isGreaterThanOrEqualTo: uid.toString())
        .where("createdAt")
        .get();
    // .collection("Posts")
    // .doc(uid)
    // .collection("PostsList")
    // .get();

    List<Post> _postsList = [];

    snapshot.docs.forEach((document) {
      Post posts = Post.fromMap(document.data());
      _postsList.add(posts);
    });

    postNotifier.postList = _postsList;
  }

  
  getEvenReqPosts(JoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

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
     _postsController.add(joinevent);

    });

    joinNotifier.joineventList = _joinsList;
  }
  getMyreqEvent(MyJoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MyJoinEvent')
        .doc(myuid)
        .collection('JoinEventList')
        .where('senderUid', isEqualTo: myuid)
        .get();

    List<JoinEvent> _joinsList = [];

    snapshot.docs.forEach((document) {
      JoinEvent joinevent = JoinEvent.fromMap(document.data());
      _joinsList.add(joinevent);
           _postsController.add(joinevent);

    });

    joinNotifier.joineventList = _joinsList;
  }

  @override
  void dispose() {
    PostNotifier postsNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    getMyPosts(postsNotifier);

    super.dispose();
  }
   Future likepost(int totallike, String postId) async {
    final uEmail = await AuthService().getCurrentEmail();
        final uid = await AuthService().getCurrentUID();

    await FirebaseFirestore.instance
        .collection("JoinEvent")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .set({'likes': 1});


    return FirebaseFirestore.instance
        .collection("Posts")
        .doc("ALL")
        .collection("PostsList")
        .doc(postId)
        .collection('likes')
        .doc(uEmail)
        .set({'likes': 1});
  }

  @override
  Widget build(BuildContext context) {
    // final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    // var posts = postsNotifier.postList;

    JoinNotifier joinNotifier =
        Provider.of<JoinNotifier>(context, listen: false);

    var joins = joinNotifier.joineventList;

    
   MyJoinNotifier sendmyjoinNotifier =
        Provider.of<MyJoinNotifier>(context, listen: false);

    var sendmyjoins = sendmyjoinNotifier.joineventList;


    print('build Manager');

    return Scaffold(
      appBar: primaryAppBar(
        null,
        Text(
          "Manager",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.27,
            color: MColors.primaryPurple,
          ),
          // style: boldFont(MColors.primaryPurple, 16.0),
        ),
        Colors.white,
        null,
        true,
        <Widget>[],
      ),
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => () async {
           await getMyreqEvent(sendmyjoinNotifier);
          await getEvenReqPosts(joinNotifier);
          // await getProfile(profileNotifier);
        }(),
        child: SingleChildScrollView(
              // controller: scrollController,
              physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              
              Text("คำขอเข้าร่วม"),
              Container(
            width: double.infinity,
            height: 300,
            child: StreamBuilder(
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return progressIndicator(MColors.primaryPurple);
                break;
              case ConnectionState.done:
                return joins.isNotEmpty
                    ? Center(child: Text("No Data"),)
                    : notificationsScreen(joins);
                break;
              case ConnectionState.waiting:
                return progressIndicator(MColors.primaryPurple);
                break;
              default:
                return joins.isEmpty
                    ? Center(child: Text("No Data"),)
                    : notificationsScreen(joins);
                break;
            }
        }),
          ),
                        Text("ที่ฉันส่งคำขอ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
            Container(
            width: double.infinity,
            height: 300,
            child: StreamBuilder(

              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return progressIndicator(MColors.primaryPurple);
                break;
              case ConnectionState.done:
                return sendmyjoins.isNotEmpty
                    ? Center(child: Text("No Data"),)
                    : mynotificationsScreen(sendmyjoins);
                break;
              case ConnectionState.waiting:
                return progressIndicator(MColors.primaryPurple);
                break;
              default:
                return sendmyjoins.isEmpty
                    ? Center(child: Text("No Data"),)
                    : mynotificationsScreen(sendmyjoins);
                break;
            }
        }),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget notificationsScreen(joins) {
    return Container(
      child: ListView.builder(
        itemCount: joins.length,
        padding: const EdgeInsets.only(top: 8),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
                     status=joins[index].status;
                     senderUid=joins[index].senderUid;

          return EventUserList(
            joinEvent: joins[index],
            myjoinId: joins[index].joinid,
          );
        },
      ),
    );
  }
  Widget mynotificationsScreen(myjoins) {
    return Container(
      child: ListView.builder(
        itemCount: myjoins.length,
        padding: const EdgeInsets.only(top: 8),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return MyEventUserList(
            status: status,
            senderUid: senderUid,
            joinEvent: myjoins[index],
          
            
            
          );
        },
      ),
    );
  }

  Widget noNotifications() {
    return emptyScreen("assets/inbox.svg", "No Events Request", ',');
  }
}
