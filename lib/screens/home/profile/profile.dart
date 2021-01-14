import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:flutter/material.dart';
import 'package:we_invited/screens/home/profile/editProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/constant.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class Myprofile extends StatefulWidget {
  Myprofile({Key key}) : super(key: key);

  @override
  _MyprofileState createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future profileFuture;

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  profileFuture = getProfile(profileNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    super.initState();
  }

  // Column createColumns(String title, int count) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       Text(
  //         count.toString(),
  //         style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(top: 5.0),
  //         child: Text(
  //           title,
  //           style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w200),
  //         ),
  //       )
  //     ],
  //   );
  // }

  // createButton(UserData userData) {
  //   return Container(
  //     child: Row(
  //       children: <Widget>[
  //         createButtonTitleAndFunction(
  //             title: 'Edit Profile', performFunction: editUserProfile),
  //         createButtonTitleAndFunction(
  //             title: 'Change Password', performFunction: editUserPassword),
  //       ],
  //     ),
  //   );
  // }

  // Container createButtonTitleAndFunction(
  //     {String title, Function performFunction}) {
  //   return Container(
  //     padding: EdgeInsets.only(top: 0.5),
  //     child: FlatButton(
  //       highlightColor: Colors.transparent,
  //       splashColor: Colors.transparent,
  //       onPressed: performFunction,
  //       child: Container(
  //         width: MediaQuery
  //             .of(context)
  //             .size
  //             .width / 2.5,
  //         height: 26.0,
  //         child: Text(title,
  //             style: kCaptionTextStyle.copyWith(
  //                 fontWeight: FontWeight.w200, fontSize: 12)),
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           color: Color(0xFF373737),
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // editUserPassword() {
  //   Navigator.of(context).pushAndRemoveUntil(
  //       FadeRoute(page: EditAccount()), ModalRoute.withName('EditAccount'));
  // }

  // editUserProfile() {
  //   Navigator.of(context).pushAndRemoveUntil(
  //       FadeRoute(page: EditProfileScreen()),
  //       ModalRoute.withName('EditProfileScreen')
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    print("build profile");
    UserDataProfileNotifier profileNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;
    ScreenUtil.init(context, height: 869, width: 414, allowFontScaling: true);


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
            return checkUser.isEmpty || checkUser == null
                ? progressIndicator(MColors.primaryPurple)
                : showSettings(user);
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

  Widget showSettings(user) {
    print(user.name);
    print(user.gender);

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

    // final listTileActions = [
    //       () {
    //     Navigator.of(context).push(
    //       CupertinoPageRoute(
    //         builder: (_) => SecurityScreen(),
    //       ),
    //     );
    //   },
    //       () {
    //     Navigator.of(context).push(
    //       CupertinoPageRoute(
    //         builder: (_) => Cards1(),
    //       ),
    //     );
    //   },
    //       () async {
    //     var navigationResult = await Navigator.of(context).push(
    //       CupertinoPageRoute(
    //         builder: (_) => Address(_address, addressList),
    //       ),
    //     );
    //     if (navigationResult == true) {
    //       UserDataAddressNotifier addressNotifier =
    //       Provider.of<UserDataAddressNotifier>(context, listen: false);
    //
    //       setState(() {
    //         getAddress(addressNotifier);
    //       });
    //       showSimpleSnack(
    //         "Address has been updated",
    //         Icons.check_circle_outline,
    //         Colors.green,
    //         _scaffoldKey,
    //       );
    //     }
    //   },
    //       () {
    //     shareWidget();
    //   },
    //       () {},
    //       () {
    //     mockNotifications();
    //   },
    //       () {
    //     _showLogOutDialog();
    //   },
    // ];

    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
      appBar: primaryAppBar(
        null,
        Text(
          "Profile",
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
      body: RefreshIndicator(
        onRefresh: ()=> () async{
          await profileFuture;
        }(),
        child: primaryContainer(
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
                decoration: BoxDecoration(
                  //color: Color(0xFF505050),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Column(children: <Widget>[
                  Container(
                      child: Column(children: <Widget>[
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      // CircleAvatar(
                                      //   radius: 50,
                                      //   child: Image.network(
                                      //         user.profilePhoto,
                                      //         fit: BoxFit.fill,
                                      //       ) ??
                                      //           Image.asset(
                                      //               'assets/images/placeholderperson.png',
                                      //               fit: BoxFit.fill),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Hero(
                                          tag: "profileAvatar",
                                          child: user.profilePhoto != null
                                              ? ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
                                            child: FadeInImage.assetNetwork(
                                              image: user.profilePhoto,
                                              fit: BoxFit.fill,
                                              height: 120.0,
                                              width: 120.0,
                                              placeholder:
                                              "assets/profile1.png",
                                            ),
                                          )
                                              : ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
              child: Image.asset(
                "assets/profile1.png",
                height: 120.0,
                width: 120.0,
              ),
            ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text(user.name,
                                          style: kTitleTextStyle.copyWith(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                      Text(
                                        user.email,
                                        style: kTitleTextStyle.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                      SizedBox(height: 10),
                                      InkWell(
                                        onTap: () async {
                                          print('กด');
                                          UserDataProfileNotifier profileNotifier =
                                          Provider.of<UserDataProfileNotifier>(
                                              context,
                                              listen: false);
                                          var navigationResult =
                                          await Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(user),
                                            ),
                                          );
                                          if (navigationResult == true) {
                                            setState(() {
                                              getProfile(profileNotifier);
                                            });
                                            showSimpleSnack(
                                              "Profile has been updated",
                                              Icons.check_circle_outline,
                                              Colors.green,
                                              _scaffoldKey,
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: Colors.amber,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Edit Profile',
                                              style: kButtonTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),

                                      ListTile(
                                        title: Text(
                                          "Profile Settings",
                                        ),
                                        subtitle: Text(
                                          "Jane Doe",
                                        ),
                                        trailing: Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.grey.shade400,
                                        ),
                                        onTap: () {},
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Profile Settings",
                                        ),
                                        subtitle: Text(
                                          "Jane Doe",
                                        ),
                                        trailing: Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.grey.shade400,
                                        ),
                                        onTap: () {},
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Logout",
                                          // style: whiteBoldText,
                                        ),
                                        onTap: () async {
                                          await FirebaseAuth.instance.signOut();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ]))
                ])),
          ),
        ),
      ),
    );
  }
}
// StreamBuilder<UserData>(
//   stream: DatabaseService(uid: user.uid).userData,
//   builder: (context, snapshot) {
//     UserData userData = snapshot.data;
//     if (userData != null) {
//       personalEmail = userData.email;
//       return Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           actions: <Widget>[
//             IconButton(
//               highlightColor: Colors.transparent,
//               splashColor: Colors.transparent,
//               icon: Icon(
//                 LineAwesomeIcons.alternate_sign_out,
//               ),
//               onPressed: () async {
//                 await _auth.signOut();
//               },
//             ),
//           ],
//         ),
//         body: Stack(children: <Widget>[
//           SingleChildScrollView(
//                   child: Container(
//                       decoration: BoxDecoration(
//                         //color: Color(0xFF505050),
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                       constraints: BoxConstraints(
//                           minHeight: MediaQuery.of(context).size.height),
//                       child: Column(children: <Widget>[
//                         Container(
//                             child: Column(children: <Widget>[
//                           Column(
//                             children: <Widget>[
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Expanded(
//                                     child: Column(
//                                       children: <Widget>[
//                                         CircleAvatar(
//                                           radius: 50,
//                                           child: ClipOval(
//                                             child: new SizedBox(
//                                               width: 180,
//                                               height: 180,
//                                               child: Image.network(
//                                                 userData.dp,
//                                                 fit: BoxFit.fill,
//                                               ) ??
//                                                   Image.asset('assets/images/placeholderperson.png',
//                                                       fit: BoxFit.fill),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(height: 15),
//                                         Text(userData.name,
//                                             style: kTitleTextStyle.copyWith(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.black)),
//                                         Text(
//                                           userData.email,
//                                             style: kTitleTextStyle.copyWith(
//                                                 fontSize: 10,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.grey),
//                                         ),
//                                         SizedBox(height: 10),
//                                         InkWell(
//                                           onTap: () async {
//                                             print('กด');
//                                             Navigator.of(context).pushAndRemoveUntil(
//                                                 FadeRoute(page: EditProfileScreen()),
//                                                 ModalRoute.withName('EditProfileScreen')
//                                             );
//                                           },
//                                           child: Container(
//                                             height: 40,
//                                             width: 200,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(30),
//                                               color: Colors.amber,
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 'Edit Profile',
//                                                 style: kButtonTextStyle,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//
//                                         ListTile(
//                                           title: Text(
//                                             "Profile Settings",
//                                           ),
//                                           subtitle: Text(
//                                             "Jane Doe",
//
//                                           ),
//                                           trailing: Icon(
//                                             Icons.keyboard_arrow_right,
//                                             color: Colors.grey.shade400,
//                                           ),
//                                           onTap: () {},
//                                         ),
//                                         ListTile(
//                                           title: Text(
//                                             "Profile Settings",
//                                           ),
//                                           subtitle: Text(
//                                             "Jane Doe",
//
//                                           ),
//                                           trailing: Icon(
//                                             Icons.keyboard_arrow_right,
//                                             color: Colors.grey.shade400,
//                                           ),
//                                           onTap: () {},
//                                         ),
//                                         ListTile(
//
//                                           title: Text(
//                                             "Logout",
//                                             // style: whiteBoldText,
//                                           ),
//                                           onTap: () async {
//                                             await FirebaseAuth.instance.signOut();
//                                             },
//                                         ),
//                                       ],
//                                     ),
//
//                                   ),
//
//                                 ],
//                               ),
//                               SizedBox(height: 10),
//
//                             ],
//                           ),
//
//
//
//
//                         ]))
//                       ])))
//             ]),
//           );
//         } else {
//           return Loading();
//         }
//       });
// }
