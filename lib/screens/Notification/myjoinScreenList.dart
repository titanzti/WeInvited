import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class MyEventUserList extends StatefulWidget {
  final JoinEvent joinEvent;
  final String status;
    final String senderUid;

  MyEventUserList({Key key, this.joinEvent, this.status, this.senderUid}) : super(key: key);

  @override
  _MyEventUserListState createState() => _MyEventUserListState(joinEvent);
}

class _MyEventUserListState extends State<MyEventUserList> {
  final JoinEvent joinEvent;
  var myuid;

  bool visibilitybutt = false;
  ThemeData themeData;
var      statuscheck ;
  var chreckstatus,joinid;
  var chrecktype;
  var myjoinid;
bool ischeck ;
  _MyEventUserListState(this.joinEvent);
  getstatus(JoinEvent joinEvent)async {
    print("getstatus");
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print('getstatusuid${joinEvent.receiverUidjoin}');

     print("getinterest");
      FirebaseFirestore.instance
        .collection("JoinEvent")
        .doc(joinEvent.receiverUidjoin)
        .collection("JoinEventList")
       .where('joinid', isEqualTo: joinEvent.joinid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((value) {
         statuscheck = value.get('status');
                                      statuscheck == "request"?print("จริง"):print("ไม่จริง");
                                      setState(() {
                                        if(statuscheck == "request"){
                                          ischeck=false;

                                        }
                                        if(statuscheck == "accept"){
                                          ischeck=true;

                                        }
                                        print('ischeck$ischeck');
                                      });

       print('statuscheck$statuscheck');

      });
    }).catchError((onError) {
      print(onError);
    });
  }
  @override
  void initState() {
                    getstatus(joinEvent);

    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  visibilitybutt = false;
                  print('senderUid${widget.senderUid}');

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;

                  chreckstatus = joinEvent.status;
                  chrecktype = joinEvent.type;
                  joinid = joinEvent.joinid;
                  getjoinid(joinEvent);
                  print('widget.status${widget.status}');
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    super.initState();
  }

  void _changed(bool visibility, JoinEvent joinEvent) {
    setState(() {
      if (joinEvent.status == "accept") {
        visibilitybutt = visibility;
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    chreckstatus = joinEvent.status;
    chrecktype = joinEvent.type;

    print(chreckstatus);
    print('=>>>>>>>>>>>>>>>>>>>>>>$myuid');
    print('joinid=>>>>>>>>>>>>>>>>>>${joinEvent.joinid}');

    chrecktype == 'sent' ? print("มีค่าsent") : print("ไม่เจอ");

    print("Eventbuild");
    themeData = Theme.of(context);
    joinEvent.receiverUidjoin != null ? print('มีค่า') : print('ไม่มีค่า');
    final format = DateFormat("dd-MM-yyyy h:mm a");

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                print("กด");
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => EventTicketScreen()));
              },
              child: Row(
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: joinEvent.imageUrl,
                        placeholder: (context, url) =>
                            progressIndicator(MColors.primaryPurple),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 100,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                                                        Text("หัวข้อที่ส่งคำขอ"),

                                      SizedBox(width: 7,) ,                                                                         Text("สถานะ"),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                joinEvent.title,
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                              ),
                             ischeck == false
                                  ? new Container(
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      'wait...',
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          fontSize: 13,
                                          color: themeData.colorScheme.primary,
                                          fontWeight: 600),
                                    ),
                                  )
                                  :  new Container(
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      'Ac',
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyText2,
                                          fontSize: 13,
                                          color: themeData.colorScheme.primary,
                                          fontWeight: 600),
                                    ),
                                  ),
                                 
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'หัวข้อเรื่อง:${joinEvent.title}',
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontSize: 12,
                                        color: Colors.black,fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    // Container(
                                    //   margin: EdgeInsets.only(top: 2),
                                    //   child: Text(
                                    //     ('${format.format(joinEvent.createdAt.toDate().toString())}'),
                                    //     style: TextStyle(
                                    //         color: Colors.black),
                                    //   ),
                                    // )
                                  ],
                                ),
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Text(
                                //       "Time",
                                //       style: AppTheme.getTextStyle(
                                //           themeData.textTheme.caption,
                                //           fontWeight: 600,
                                //           letterSpacing: 0,
                                //           color: themeData.colorScheme.onBackground,
                                //           fontSize: 12,
                                //           xMuted: true),
                                //     ),
                                //     Container(
                                //       margin: Spacing.top(2),
                                //       child: Text(
                                //         time,
                                //         style: AppTheme.getTextStyle(
                                //             themeData.textTheme.bodyText2,
                                //             color:
                                //             themeData.colorScheme.onBackground),
                                //       ),
                                //     )
                                //   ],
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getjoinid(JoinEvent joinEvent) async {
    print("getjoinid");
    final uEmail = await AuthService().getCurrentEmail();
 
    /*ดึงค่าไลท์จากcollection/Posts/likes */
    FirebaseFirestore.instance
        .collection("MyJoinEvent")
        .doc(joinEvent.senderUid)
        .collection("JoinEventList")
        .where('joinid')
        .get()
        .then((querySnapshot) {
      //print(querySnapshot);
      // int totallike;
      // print('totallike$totallike');

      querySnapshot.docs.forEach((value) {
              joinid = value.get('likes');

        // print('testlike=>>>>>>${value.get('likes')}');
      });
    }).catchError((onError) {
      print("getCloudFirestoreUsers: ERROR");
      print(onError);
    });
  }

  updateStateaccept(JoinEvent joinEvent) async {
    print("updateState");
    print(myuid);
    final db = FirebaseFirestore.instance;
    final uEmail = await AuthService().getCurrentEmail();

    CollectionReference profileRef = await FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(myuid)
        .collection('JoinEventList');

    await profileRef.doc(myjoinid).update(
      {'status': 'accept'},
    ).then((result) {
      setState(() {
        // _changed(false,joinEvent);

        visibilitybutt = true;
      });

      print("Stateupdate successfully");
      print(visibilitybutt.toString());
    }).catchError((onError) {
      print("onError");
    });
  }
  updateMyStateaccept(JoinEvent joinEvent) async {
    print("updateState");
    print(myuid);
    final db = FirebaseFirestore.instance;
    final uEmail = await AuthService().getCurrentEmail();

    CollectionReference profileRef = await FirebaseFirestore.instance
        .collection('MyJoinEvent')
        .doc(myuid)
        .collection('JoinEventList');

    await profileRef.doc(joinEvent.joinid).update(
      {'status': 'accept'},
    ).then((result) {
      setState(() {
        // _changed(false,joinEvent);

        visibilitybutt = true;
      });

      print("Stateupdate successfully");
      print(visibilitybutt.toString());
    }).catchError((onError) {
      print("onError");
    });
  }

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
        .doc(myuid)
        .collection('JoinEventList')
        .where('receiverUidjoin', isEqualTo: myuid)
        .where('joinid', isEqualTo: joinid)
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
  }
}
