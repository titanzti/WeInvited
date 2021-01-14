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
import 'package:we_invited/screens/home/design_course_app_theme.dart';
import 'package:we_invited/screens/home/hotel_app_theme.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/SizeConfig.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';


class PostDetailsProv extends StatelessWidget {
  final Post postDetails;
  final UserDataProfile userData;
  PostDetailsProv(this.postDetails, this.userData);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostNotifier>(
      create: (BuildContext context) => PostNotifier(),
      child: PostDetails(postDetails,userData),
    );
  }
}

class PostDetails extends StatefulWidget {

  final Post postDetails ;
  final UserDataProfile userData;

  PostDetails(this.postDetails, this.userData);


  @override
  _PostDetailsState createState() =>
      _PostDetailsState(postDetails);

}

class _PostDetailsState extends State<PostDetails> with TickerProviderStateMixin {
  ThemeData themeData;

  _PostDetailsState(this.postDetails);
  final double infoHeight = 364.0;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;


  Post postDetails = Post();
  JoinEvent _joinEvent = JoinEvent();


  bool acceptedrequest = false;
  bool sentrequest = false;
  var checktype=null;
  var checkpostidEvent;
  var  checksenderUid;
  var mypostid;
  var mypostuid;
  var myuid;
  var uidpost;
  String testtital;
  String toggleJoin;
  bool visibilitybutt = false;



  @override
  void initState()  {
    print("initState");
    checkInternetConnectivity().then((value)   => {
      value == true
          ? () {
        checkData();

        visibilitybutt = false;
        setState(() {
          getData();

          getType();
          checkpostidEvent;

        });

        mypostuid = postDetails.uid;
        mypostid= postDetails.postid;
        print(mypostuid);
        print(checkpostidEvent);
         uidpost = postDetails.uid;

        JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
            listen: false);
        getEvenReqPosts(joinNotifier);



        // mypostuid==myuid?print('เจ้าของโพส'):print('ไม่ใช่เจ้าของโพส');


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



      }()
          : showNoInternetSnack(_scaffoldKey)
    });

    super.initState();

  }
  getEvenReqPosts(JoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot= await  FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(myuid)
        .collection('JoinEventList')
        .where('receiverUidjoin',isEqualTo: myuid)
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


    print("build Detail");

    JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context);

    var joins = joinNotifier.joineventList;


    getType();


    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid.toString();
    myuid=  uid;
    print(checktype);
    print(testtital);

    var postuid =postDetails.postid;

    if (myuid != postDetails.uid) {
      print("joinได้");
    }else{
      print("close");
    }


    // UserDataProfileNotifier profileNotifier =   Provider.of<UserDataProfileNotifier>(context);
    // var checkUser = profileNotifier.userDataProfileList;
    // var user;
    //
    // checkUser.isEmpty || checkUser == null
    //     ? user = null
    //     : user = checkUser.first;
    //
    // print(user.name);

    themeData = Theme.of(context);


    // var post = postDetails;

    return Scaffold(
      // appBar: primaryAppBar(
      //   IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.grey.withOpacity(0.5),
      //     ),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      //   Text(
      //     "Profile",
      //     style: boldFont(MColors.primaryPurple, 16.0),
      //   ),
      //   MColors.primaryWhiteSmoke,
      //   null,
      //   true,
      //   <Widget>[
      //
      //   ],
      // ),

      body: _buildPostDetails(postDetails),
      // ignore: unrelated_type_equality_checks
      bottomSheet: visibilitybutt == false ?  getBottom():getBottom1(),
    );
  }

  Widget checkbottom() {

    if (myuid != postDetails.uid) {
      print("join");
    }else{
      return getBottom();

    }
  }



  Widget getBottom(){
    var size = MediaQuery.of(context).size;
    return   Container(
      height: 50,
      width: size.width,
      child:  FlatButton(
        color: Colors.amber,
        onPressed: () async{
          var uidpost = postDetails.uid;
          // chrecktype= _joinEvent.type=='sent';

          print('$mypostid โพสของฉัน');
          print('$checkpostidEvent โพสidอีเว้น');
          print('$checksenderUid uidคนส่ง');

          if (uidpost== myuid) {
            Navigator.pop(context);
          }
          else if (uidpost != myuid){
            test1();
          }
          // else if  (uidpost != myuid && mypostid==checkpostidEvent) {
          //  retractrequest();
          // }else{
          //   Navigator.pop(context);
          // }
          // retractrequest();

          //   if (uidpost != myuid && mypostid==checkpostidEvent) {
          // }
          // your add cart here
        }, child: Text('Join', style: TextStyle(fontSize: 18, color: Colors.white
      ),),
      ),
    );
  }

  Widget getBottom1(){
    var size = MediaQuery.of(context).size;
    return   Container(
      height: 50,
      width: size.width,
      child: FlatButton(
        color: Colors.amber,
        onPressed: () async{
          print('Cancel');
          if (checkpostidEvent==mypostid) {
            retractrequest();
          }
          // test();
          // your add cart here
        }, child: Text('Cancel', style: TextStyle(fontSize: 18, color: Colors.white
      ),),
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
          child: Text('${myuid.toString() != mypostuid.toString()?'Join':'Cancel'}', style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: ()  {
            print('$mypostid โพสของฉัน');
            print('$checkpostidEvent โพสidอีเว้น');
            print('$checksenderUid uidคนส่ง');


            if(mypostid==checkpostidEvent&& myuid == checksenderUid){
              retractrequest();
            }else if (mypostid!=checkpostidEvent) {
              eventreq(_joinEvent);
            }else if (checkpostidEvent==mypostid) {
              retractrequest();
            }
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
        }
        setState(() {
          visibilitybutt = false;
          print(visibilitybutt.toString());
        });
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
  }

  sendrequest() async {
    final db = FirebaseFirestore.instance;
    final uEmail = await AuthService().getCurrentEmail();

    var uidpost = postDetails.uid;
    var postid = postDetails.postid;


    print('request');
    if (this.mounted) {
      setState(() {
        sentrequest = true;
      });
      // print(sentrequest);
    }




    await   db.collection("JoinEvent")
        .doc(postDetails.uid)
        .collection('JoinEventList')
        .doc(myuid)
        .set({
      'type': 'request',
      'ownerID': postDetails.uid,
      'ownerName': postDetails.postbyname,
      'title': postDetails.name,
      'createdAt': DateTime.now(),
      'senderAvatar': widget.userData.profilePhoto,
      'senderName': widget.userData.name,
      'senderUid' : myuid,
      'receiverUidjoin': postDetails.uid,
      'requestpostid': postDetails.postid,
      'senderEmail': widget.userData.email,
      'status': 'sent'
    }).then((value) async {

      var type = await db.collection("JoinEvent")
          .doc(uEmail)
          .collection("JoinEventList").get();
      type.docs.forEach((document) {
        var idtype = document["type"];
        // if (idtype=='request') {
        //   print(idtype);
        // }
      });
    });


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
    final db = FirebaseFirestore.instance;
    final uEmail = await AuthService().getCurrentEmail();

    await  db.collection("JoinEvent")
        .doc(uEmail)
        .collection('JoinEventList')
        .doc()
        .get()
        .then((value) => {
      print(value),
      if (value.exists){
        sentrequest = value.exists,
        db.collection("JoinEvent")
            .doc(uEmail)
            .collection('JoinEventList')
            .doc()
            .get()
            .then((val) {

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

  checkData() async {

    // if (mypostid == checkpostid) {
    //   print("ใช่postid");
    // }else{
    //   print('ไม่ใช่postid');
    // }
  }
  //
  // Future<dynamic> getData() async {
  //     final uEmail = await AuthService().getCurrentEmail();
  //
  //   final DocumentReference data =   FirebaseFirestore.instance.collection('JoinEvent').doc(uEmail).collection('JoinEventList')
  //       .where('requestpostid',isEqualTo: mypostid) as DocumentReference;
  //        //get the data
  //     await data.get().then<dynamic>(( DocumentSnapshot snapshot) async{
  //       setState(() {
  //         checkpostidEvent = snapshot.data;
  //
  //       });
  //     });
  // }

  getData() async {
    final uEmail = await AuthService().getCurrentEmail();

    FirebaseFirestore.instance
        .collection('JoinEvent').doc(postDetails.uid).collection('JoinEventList')
        // .where('senderUid',isEqualTo: myuid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {




        if (doc.exists) {
          setState(() {
            checksenderUid=doc['senderUid'];
            checkpostidEvent=doc['requestpostid'];
            testtital=doc['title'];

          });
        }


        // checktype = doc["type"];
        // checkpostidEvent=doc;


        // checkpostid=='wo19JbnLdGqwlB5P54jt'?print('ใช่postid'):print('ไม่ใช่postid');
        //  checktype!='accepted'?print('ไม่ใช่accepted'):print('ใช่accepted');
        // checktype=='request'? print('ใช่'):print('ไม่ใช่');

        // print(checkpostidEvent);
        // print(checksenderUid);

      })
    });




  }

  getType () async{
    print("getType");
    print('checkpostidEvent========>$checkpostidEvent');
    print('mypostid================>$mypostid');
    if ( uidpost != myuid&&  checkpostidEvent==mypostid ) {
      print('checkpostidEvent$checkpostidEvent');
      print('mypostid$mypostid');
      print("postid!=postidที่มี");
      FirebaseFirestore.instance
          .collection('JoinEvent').doc(postDetails.uid).collection('JoinEventList')
          .where('requestpostid',isEqualTo: checkpostidEvent)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {


          if (doc.exists) {
            setState(() {
              checktype=doc['type'];
            });
          }

          // checktype = doc["type"];
          // checkpostidEvent=doc;


          // checkpostid=='wo19JbnLdGqwlB5P54jt'?print('ใช่postid'):print('ไม่ใช่postid');
          //  checktype!='accepted'?print('ไม่ใช่accepted'):print('ใช่accepted');
          // checktype=='request'? print('ใช่'):print('ไม่ใช่');



        })
      });
    }
    // else{
    //   setState(() {
    //     checktype=null;
    //
    //   });
    // }
  }



  // saveReceivercloudforrequest(UserDataProfile userDataProfile) async {
  //   final uid = await AuthService().getCurrentUID();
  //
  //   final cloudReference = FirebaseFirestore.instance.collection('cloud');
  //   cloudReference.doc().set({
  //     'type': 'request',
  //     'ownerID': postDetails.uid,
  //     'ownerName': postDetails.postbyname,
  //     'timestamp': DateTime.now(),
  //     'userprofile': widget.userData.profilePhoto,
  //     'userID': uid,
  //     'username': widget.userData.name,
  //   });
  //
  // }
  // sendrequest(UserDataProfile userDataProfile) async {
  //   final uid = await AuthService().getCurrentUID();
  //
  //   print('request');
  //   if (this.mounted) {
  //     setState(() {
  //       sentrequest = true;
  //     });
  //   }
  //
  //   saveReceivercloudforrequest(userDataProfile);
  //
  //   final eventReference = FirebaseFirestore.instance.collection('JoinEvent');
  //   eventReference.doc().set({
  //     'type': 'request',
  //     'ownerID': postDetails.uid,
  //     'ownerName': postDetails.postbyname,
  //     'timestamp': DateTime.now(),
  //     'userprofile': widget.userData.profilePhoto,
  //     'userID': uid,
  //     'status': 'sent',
  //     'username': widget.userData.name,
  //     'senderEmail': widget.userData.email
  //
  //   });
  //
  //   getRequestStatus(String ownerID, String ownerName, String userDp,
  //       String userID, String senderEmail) async {
  //     final eventReference = FirebaseFirestore.instance.collection('JoinEvent');
  //     final senderEmail = await AuthService().getCurrentEmail();
  //
  //     return eventReference
  //         .doc(postDetails.uid)
  //         .collection('feed')
  //     //.document(senderEmail)
  //         .where('senderEmail', isEqualTo: senderEmail)
  //     // .get();
  //         .where('type', isEqualTo: 'request')
  //         .snapshots();
  //   }
  //   Stream<QuerySnapshot> query = await getRequestStatus(
  //       postDetails.uid,
  //       postDetails.postbyname,
  //       widget.userData.profilePhoto,
  //       widget.userData.name,
  //     widget.userData.email,);
  //
  //   query.forEach((event) {
  //     if (event.docs[0].data['status'] == 'accepted') {
  //       controlFollowUser(userData);
  //       saveReceivercloudforfollow(userData);
  //       print('followed');
  //
  //       if (this.mounted) {
  //         setState(() {
  //           following = true;
  //           sentrequest = true;
  //           acceptedrequest = true;
  //           toggleFollow = "Unfollow";
  //
  //           getAllFollowers();
  //           getAllFollowings();
  //           checkIfAlreadyFollowing();
  //         });
  //       }
  //     }
  //   });
  // }
  // controlFollowUser(UserData userData) {
  //   print('hi');
  //   databaseserver.followersReference
  //       .document(widget.wiggle.email)
  //       .collection('userFollowers')
  //       .document(userData.email)
  //       .setData({
  //     'name': userData.name,
  //     'dp': userData.dp,
  //     'email': userData.email
  //   });
  //
  //   databaseserver.followingReference
  //       .document(userData.email)
  //       .collection('userFollowing')
  //       .document(widget.wiggle.email)
  //       .setData({
  //     'name': widget.wiggle.name,
  //     'dp': widget.wiggle.dp,
  //     'email': widget.wiggle.email
  //   });
  //   databaseserver.feedReference
  //       .document(widget.wiggle.email)
  //       .collection('feed')
  //       .document(userData.email)
  //       .setData({
  //     'type': 'request',
  //     'ownerID': widget.wiggle.email,
  //     'ownerName': widget.wiggle.name,
  //     'timestamp': DateTime.now(),
  //     'userDp': userData.dp,
  //     'userID': userData.name,
  //     'status': 'followed',
  //     'senderEmail': userData.email
  //   });
  //   databaseserver.feedReference
  //       .document(widget.wiggle.email)
  //       .collection('feed')
  //       .document()
  //       .setData({
  //     'type': 'follow',
  //     'ownerID': widget.wiggle.email,
  //     'ownerName': widget.wiggle.name,
  //     'timestamp': DateTime.now(),
  //     'userDp': userData.dp,
  //     'userID': userData.name,
  //     'status': 'followed',
  //     'senderEmail': userData.email
  //   });
  // }


  Widget _buildPostDetails(postDetails) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    var size = MediaQuery.of(context).size;
    final f = new DateFormat('dd-MM-yyyy h:mm a');
    final format = DateFormat("dd-MMM-yyyy h:mm a");


    return  SingleChildScrollView(
      child: Stack(

        children:  <Widget>[
          Container(
            width: double.infinity,
            height: size.height * 0.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(postDetails.image),
                  fit: BoxFit.cover),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset("assets/images/back_icon.svg")),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset("assets/images/heart_icon.svg"),
                        SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset("assets/images/share_icon.svg"),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: size.height * 0.45),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    child: Container(
                      width: 150,
                      height: 7,
                      decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    postDetails.name,
                    style: TextStyle(fontSize: 20, height: 1.5),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        // decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     image: DecorationImage(
                        //         image: NetworkImage(postDetails.postbyimage),
                        //         fit: BoxFit.cover),
                        child: FadeInImage.assetNetwork(
                          image: postDetails.postbyimage,
                          fit: BoxFit.fill,
                          height: 120.0,
                          width: 120.0,
                          placeholder:
                          "assets/profile1.png",
                        ),
                      ),

                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Host",
                            style: AppTheme.getTextStyle(themeData.textTheme.caption,
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: 500,
                                xMuted: true),
                          ),
                          Text(
                            postDetails.postbyname,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          // Text(
                          //   "Interior Design",
                          //   style: TextStyle(fontSize: 13),
                          // )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.only(
                        top: 16,
                        left: 1.0,
                        right: 24,
                        bottom: 0
                    ),
                    child: Text(
                      "รายละเอียดกิจกรรม",
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle1,
                          fontWeight: 700,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 16,
                        left: 1.0,
                        right: 24,
                        bottom: 0
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:  EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: themeData.colorScheme.primary
                                      .withAlpha(24),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8))),
                              child: Icon(
                                MdiIcons.calendar,
                                size: 18,
                                color: themeData.colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ('${format.format(postDetails.startdateTime.toDate())}'),
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          fontWeight: 600,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      ('${format.format(postDetails.entdateTime.toDate())}'),
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          fontWeight: 600,
                                          color: Colors.black),
                                    ),
                                    // Container(
                                    //   margin: EdgeInsets.only(
                                    //       top: 2,
                                    //
                                    //   ),
                                    //   child: Text(
                                    //     ('${f.format(postDetails.startdateTime.toDate())}-${f.format(postDetails.entdateTime.toDate())}'),
                                    //     style: AppTheme.getTextStyle(
                                    //         themeData.textTheme.caption,fontSize: 12,
                                    //         fontWeight: 500,
                                    //         color: Colors.black,
                                    //         xMuted: true),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Container(
                                padding:  EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: themeData.colorScheme.primary
                                        .withAlpha(24),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8))),
                                child: Icon(
                                  MdiIcons.genderMaleFemale,
                                  size: 18,
                                  color: themeData.colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postDetails.gender,
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.caption,
                                            fontWeight: 600,
                                            color: Colors.black),
                                      ),
                                      // Container(
                                      //   margin: EdgeInsets.only(top: 2),
                                      //   child: Text(
                                      //     "SEAS, Ahmedabad University",
                                      //     style: AppTheme.getTextStyle(
                                      //         themeData.textTheme.caption,fontSize: 12,
                                      //         fontWeight: 500,
                                      //         color: Colors.black,
                                      //         xMuted: true),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Container(
                                padding:  EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: themeData.colorScheme.primary
                                        .withAlpha(24),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8))),
                                child: Icon(
                                  MdiIcons.humanChild,
                                  size: 18,
                                  color: themeData.colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Text(
                                    postDetails.agerange.toString(),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      fontWeight: 600,letterSpacing: 0.3,
                                      color: Colors.black,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(
                  //       top: 16,
                  //       left: 1.0,
                  //       right: 24,
                  //       bottom: 0
                  //   ),
                  //   child: Text(
                  //     "รายละเอียด",
                  //     style: AppTheme.getTextStyle(
                  //         themeData.textTheme.subtitle1,
                  //         fontWeight: 700,
                  //         color: Colors.black),
                  //   ),
                  // ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 24,
                        top: 12,
                        right: 24,
                        bottom: 0
                    ),
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: postDetails.description,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle2,
                                color: Colors.black,
                                muted: true,
                                fontWeight: 500)),
                        TextSpan(
                            text: " Read More",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                color: Colors.black,
                                fontWeight: 600))
                      ]),
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Text('รายละเอียด\n${postDetails.description}',style: TextStyle(
                  //     height: 1.6
                  // ),),
                  SizedBox(height: 20,),
                  Text("Gallery",style: TextStyle(
                      fontSize: 18
                  ),),
                  SizedBox(height: 20,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: AssetImage("assets/images/image_2.png"),fit: BoxFit.cover)
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: AssetImage("assets/images/image_3.png"),fit: BoxFit.cover)
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: AssetImage("assets/images/image_4.png"),fit: BoxFit.cover)
                            ),
                          ),
                        )


                      ],
                    ),
                  )

                ],
              ),
            ),
          )

        ],



      ),
    );
    //   SafeArea(
    //   child: Padding(
    //     padding: const EdgeInsets.only(bottom: 60),
    //     child: ListView(
    //       children: <Widget>[
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,top: 20),
    //           child: InkWell(
    //             onTap: (){
    //               Navigator.pop(context);
    //             },
    //             child: Align(
    //                 alignment: Alignment.centerLeft,
    //                 child: Icon(Icons.arrow_back_ios)),
    //           ),
    //         ),
    //         SizedBox(height: 10,),
    //         Card(
    //           elevation: 2,
    //           child: Hero(
    //             tag: postDetails.postid.toString(),
    //             child: Container(
    //               height: 300,
    //               width: 200,
    //               decoration: BoxDecoration(
    //                   image: DecorationImage(image: NetworkImage(postDetails.image),fit: BoxFit.fill)
    //               ),
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text("หัวข้อ",style: TextStyle(
    //                   fontSize: 16,
    //                   height: 1.5
    //               ),),
    //               SizedBox(width: 20,),
    //               Flexible(
    //                 child: Text(postDetails.name,style: TextStyle(
    //                     fontSize: 16,
    //                     height: 1.5
    //                 ),),
    //               ),
    //             ],
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Icon(FrinoIcons.f_male),
    //
    //               SizedBox(width: 20,),
    //               Flexible(
    //                 child: Text(postDetails.gender,style: TextStyle(
    //                     fontSize: 16,
    //                     height: 1.5
    //                 ),),
    //               ),
    //             ],
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text("เริ่มเวลา :",style: TextStyle(
    //                   fontSize: 16,
    //                   height: 1.5
    //               ),),
    //               SizedBox(width: 20,),
    //               Flexible(
    //                   child: Row(children: <Widget>[
    //                     Text(postDetails.startdateTime.toDate().toString(),style: TextStyle(
    //                         fontSize: 16,height: 1.5
    //                     ),),
    //                     SizedBox(width: 20,),
    //                     // Text(widget.price+" USD",style: TextStyle(
    //                     //     fontSize: 20,height: 1.5,
    //                     //     color: primary,
    //                     //     fontWeight: FontWeight.w400,
    //                     //     decoration: TextDecoration.lineThrough
    //                     // ),)
    //                   ],)
    //               ),
    //             ],
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text("Size :",style: TextStyle(
    //                   fontSize: 16,
    //                   height: 1.5
    //               ),),
    //               SizedBox(width: 20,),
    //               Flexible(
    //               //     child: Wrap(
    //               //     //     // children: List.generate(widget.size.length, (index){
    //               //     //     //   return Padding(
    //               //     //     //     padding: const EdgeInsets.only(right: 20),
    //               //     //     //     child: InkWell(
    //               //     //     //       onTap: (){
    //               //     //     //         setState(() {
    //               //     //     //           activeSize = widget.size[index]['id'];
    //               //     //     //         });
    //               //     //     //       },
    //               //     //     //       child: Container(
    //               //     //     //         decoration: BoxDecoration(
    //               //     //     //             border: Border.all(
    //               //     //     //               width: 2,
    //               //     //     //               color: activeSize == widget.size[index]['id'] ? primary : Colors.transparent,
    //               //     //     //
    //               //     //     //             ),
    //               //     //     //             borderRadius: BorderRadius.circular(5)
    //               //     //     //         ),
    //               //     //     //         child: Padding(
    //               //     //     //           padding: const EdgeInsets.only(top: 12,bottom: 12,right: 15,left: 15),
    //               //     //     //           child: Text(widget.size[index]['value'],style: TextStyle(
    //               //     //     //               fontSize: 16,
    //               //     //     //               height: 1.5
    //               //     //     //           ),),
    //               //     //     //         ),
    //               //     //     //       ),
    //               //     //     //     ),
    //               //     //     //   );
    //               //     //     // })
    //               //     // )
    //               // ),
    //                 child: Row(children: <Widget>[
    //                   Text(postDetails.postbyname,style: TextStyle(
    //                       fontSize: 16,height: 1.5
    //                   ),),
    //                   SizedBox(width: 20,),
    //                   // Text(widget.price+" USD",style: TextStyle(
    //                   //     fontSize: 20,height: 1.5,
    //                   //     color: primary,
    //                   //     fontWeight: FontWeight.w400,
    //                   //     decoration: TextDecoration.lineThrough
    //                   // ),)
    //                 ],)
    //               )],
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text("Color :",style: TextStyle(
    //                   fontSize: 16,
    //                   height: 1.5
    //               ),),
    //               SizedBox(width: 20,),
    //               Flexible(
    //                   child: Wrap(
    //                       // children: List.generate(widget.color.length, (index){
    //                       //   return Padding(
    //                       //     padding: const EdgeInsets.only(right: 20),
    //                       //     child: InkWell(
    //                       //       onTap: (){
    //                       //         setState(() {
    //                       //           activeColor = widget.color[index]['id'];
    //                       //           activeImg = widget.color[index]['value'];
    //                       //         });
    //                       //       },
    //                       //       child: Container(
    //                       //         width: 50,
    //                       //         height: 50,
    //                       //         decoration: BoxDecoration(
    //                       //             image: DecorationImage(image: NetworkImage(widget.color[index]['value']),fit: BoxFit.cover),
    //                       //             border: Border.all(
    //                       //               width: 2,
    //                       //               color: activeColor == widget.color[index]['id'] ? primary : Colors.transparent,
    //                       //
    //                       //             ),
    //                       //             borderRadius: BorderRadius.circular(5)
    //                       //         ),
    //                       //
    //                       //       ),
    //                       //     ),
    //                       //   );
    //                       // })
    //                   )
    //               ),
    //             ],
    //           ),
    //         ),
    //         SizedBox(height: 20,),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20,right: 20),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Text("Qty :",style: TextStyle(
    //                   fontSize: 16,
    //                   height: 1.5
    //               ),),
    //               SizedBox(width: 20,),
    //               Flexible(
    //                   child: Row(
    //                     children: <Widget>[
    //                       InkWell(
    //                         onTap: (){
    //                           // if(qty > 1){
    //                           //   setState(() {
    //                           //     qty = --qty;
    //                           //   });
    //                           // }
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                               border: Border.all(
    //                                   color: black.withOpacity(0.5)
    //                               )
    //                           ),
    //                           width: 35,
    //                           height: 35,
    //                           child: Icon(LineIcons.minus,color: black.withOpacity(0.5),),
    //                         ),
    //                       ),
    //                       SizedBox(width: 25,),
    //                       // Text(qty.toString(),style: TextStyle(
    //                       //     fontSize: 16
    //                       // ),),
    //                       SizedBox(width: 25,),
    //                       InkWell(
    //                         onTap: (){
    //                           setState(() {
    //                             // qty = ++qty;
    //                           });
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                               border: Border.all(
    //                                   color: black.withOpacity(0.5)
    //                               )
    //                           ),
    //                           width: 35,
    //                           height: 35,
    //                           child: Icon(LineIcons.plus,color: black.withOpacity(0.5),),
    //                         ),
    //                       )
    //                     ],
    //                   )
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

  }

  Widget getTimeBoxUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: DesignCourseAppTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: DesignCourseAppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: DesignCourseAppTheme.nearlyBlue,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: DesignCourseAppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}