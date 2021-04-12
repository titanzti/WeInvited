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

class EventUserList extends StatefulWidget {
  final JoinEvent joinEvent;
  EventUserList({Key key, this.joinEvent}) : super(key: key);

  @override
  _EventUserListState createState() => _EventUserListState(joinEvent);
}

class _EventUserListState extends State<EventUserList> {
  final JoinEvent joinEvent;
  var myuid, joinid;

  bool visibilitybutt = false;
  ThemeData themeData;

  var chreckstatus;
  var chrecktype;

  _EventUserListState(this.joinEvent);

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  visibilitybutt = false;

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;

                  chreckstatus = joinEvent.status;
                  chrecktype = joinEvent.type;
                  joinid = joinEvent.joinid;
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
    print(chrecktype);
    print('=>>>>>>>>>>>>>>>>>>>>>>$myuid');
    print('=>>>>>>>>>>>>>>>>>>${joinEvent.receiverUidjoin}');

    chrecktype == 'sent' ? print("มีค่าsent") : print("ไม่เจอ");

    print("Eventbuild");
    themeData = Theme.of(context);
    joinEvent.receiverUidjoin != null ? print('มีค่า') : print('ไม่มีค่า');
    final format = DateFormat("dd-MM-yyyy h:mm a");

    return Container(
      margin: EdgeInsets.all(24),
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
                  imageUrl: joinEvent.senderAvatar,
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
                        Text(
                          joinEvent.senderName,
                          style: TextStyle(color: Colors.black),
                        ),
                        visibilitybutt == false && chreckstatus == 'request'
                            ? new InkWell(
                                onTap: () async {
                                  updateStateaccept(joinEvent);
                                  // visibilitybutt ? null : _changed(false, joinEvent);
                                  print("กด");
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (BuildContext context) =>
                                  //         EventTicketDialog());
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    'accept',
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        fontSize: 13,
                                        color: themeData.colorScheme.primary,
                                        fontWeight: 600),
                                  ),
                                ))
                            : InkWell(
                                onTap: () {
                                  retractrequest();
                                  // updateStatedecline(joinEvent);
                                  print("กด");
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (BuildContext context) =>
                                  //         EventTicketDialog());
                                },
                                child: Container(
                                    padding: EdgeInsets.all(6),
                                    child: Text("decline")),
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
                                'หัวข้อ:${joinEvent.title}',
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 12,
                                  color: Colors.black,
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
    );
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
