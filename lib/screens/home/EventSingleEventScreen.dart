import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/screens//AppThemeNotifier.dart';
import 'package:we_invited/services/Event_service.dart';
import 'package:we_invited/utils/Generator.dart';
import 'package:we_invited/utils/SizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import '../../AppTheme.dart';

class EventSingleEventScreen extends StatefulWidget {
  final Post postDetails ;
  final UserDataProfile userData;
  final JoinEvent joinEvent;

   EventSingleEventScreen({Key key, this.postDetails, this.userData, this.joinEvent}) : super(key: key);

  @override
  _EventSingleEventScreenState createState() => _EventSingleEventScreenState(postDetails,userData,joinEvent);
}

class _EventSingleEventScreenState extends State<EventSingleEventScreen> {
  final Post postDetails ;
  final UserDataProfile userData;
  final JoinEvent joinEvent;

  var myuid;

  _EventSingleEventScreenState(this.postDetails, this.userData, this.joinEvent);
  @override
  void initState() {


    checkInternetConnectivity().then((value)   => {
      value == true
          ? () {
        // getData();
        // checkData();

        // visibilitybutt = false;

        // JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
        //     listen: false);
        // getEvenReqPosts(joinNotifier,myuid);


        // mypostuid = postDetails.uid;
        // mypostid= postDetails.postid;

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
        // mypostid= postDetails.postid;



      }()
          : showNoInternetSnack(_scaffoldKey)
    });
    super.initState();
  }
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  Widget build(BuildContext context) {

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid.toString();
    myuid=  uid;

    themeData = Theme.of(context);

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                body: Container(
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      children: [
                        Image(
                          image: AssetImage(
                              './assets/design/pattern-1.png'),
                          fit: BoxFit.cover,
                          width: 240,
                          height: 240,
                        ),
                        Positioned(
                          child: Container(
                            margin: EdgeInsets.only(
                                top: 48,
                                left: 24,
                                right: 24,
                                bottom: 0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding:  EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue,
                                          width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8)),
                                    ),
                                    child: Icon(MdiIcons.chevronLeft,
                                        color: Colors.blue,
                                        size: 20),
                                  ),
                                ),
                                Container(
                                  padding:  EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8)),
                                  ),
                                  child: Icon(MdiIcons.shareOutline,
                                      color: Colors.blue,

                                      size: 20),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: ListView(
                  //     padding:EdgeInsets.symmetric( vertical: 20),
                  //     children: [
                  //       Container(
                  //         margin: EdgeInsets.only(
                  //             top: 0,
                  //             left: 24,
                  //             right: 24,
                  //             bottom: 0
                  //         ),
                  //         child: Row(
                  //           children: [
                  //             Expanded(
                  //               child: Text(
                  //                 'Widgets of the Week - Flutter',
                  //                 style: AppTheme.getTextStyle(
                  //                     themeData.textTheme.headline5,
                  //                     fontSize: 22,
                  //                     color: themeData.colorScheme.onBackground,
                  //                     fontWeight: 600),
                  //               ),
                  //             ),
                  //             Container(
                  //               margin: EdgeInsets.only(left: 16),
                  //
                  //               padding:  EdgeInsets.all(8),
                  //               decoration: BoxDecoration(
                  //                   color: themeData.colorScheme.primary.withAlpha(24)
                  //                       .withAlpha(20),
                  //                   borderRadius: BorderRadius.all(
                  //                       Radius.circular(8))),
                  //               child: Icon(
                  //                 MdiIcons.heartOutline,
                  //                 size: 18,
                  //                 color: themeData.colorScheme.primary
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: EdgeInsets.only(
                  //             top: 16,
                  //             left: 24,
                  //             right: 24,
                  //             bottom: 0
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 Container(
                  //                   padding: Spacing.all(8),
                  //                   decoration: BoxDecoration(
                  //                       color: themeData.colorScheme.primary
                  //                           .withAlpha(24),
                  //                       borderRadius: BorderRadius.all(
                  //                           Radius.circular(8))),
                  //                   child: Icon(
                  //                     MdiIcons.calendar,
                  //                     size: 18,
                  //                     color: themeData.colorScheme.primary,
                  //                   ),
                  //                 ),
                  //                 Expanded(
                  //                   child: Container(
                  //                     margin: EdgeInsets.only(left: 16),
                  //                     child: Column(
                  //                       crossAxisAlignment:
                  //                           CrossAxisAlignment.start,
                  //                       children: [
                  //                         Text(
                  //                           "Thursday, May 29, 2020",
                  //                           style: AppTheme.getTextStyle(
                  //                               themeData.textTheme.caption,
                  //                               fontWeight: 600,
                  //                               color: themeData
                  //                                   .colorScheme.onBackground),
                  //                         ),
                  //                         Container(
                  //                           margin: EdgeInsets.only(top: 2),
                  //                           child: Text(
                  //                             "8:30 AM - 11:30 AM",
                  //                             style: AppTheme.getTextStyle(
                  //                                 themeData.textTheme.caption,fontSize: 12,
                  //                                 fontWeight: 500,
                  //                                 color: themeData
                  //                                     .colorScheme.onBackground,
                  //                                 xMuted: true),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 )
                  //               ],
                  //             ),
                  //             Container(
                  //               margin: EdgeInsets.only(top: 16),
                  //
                  //               child: Row(
                  //                 children: [
                  //                   Container(
                  //                     padding: EdgeInsets.all(8),
                  //                     decoration: BoxDecoration(
                  //                         color: themeData.colorScheme.primary
                  //                             .withAlpha(24),
                  //                         borderRadius: BorderRadius.all(
                  //                             Radius.circular(8))),
                  //                     child: Icon(
                  //                       MdiIcons.mapMarkerOutline,
                  //                       size: 18,
                  //                       color: themeData.colorScheme.primary,
                  //                     ),
                  //                   ),
                  //                   Expanded(
                  //                     child: Container(
                  //                       margin: EdgeInsets.only(left: 16),
                  //                       child: Column(
                  //                         crossAxisAlignment:
                  //                             CrossAxisAlignment.start,
                  //                         children: [
                  //                           Text(
                  //                             "Auditorium",
                  //                             style: AppTheme.getTextStyle(
                  //                                 themeData.textTheme.caption,
                  //                                 fontWeight: 600,
                  //                                 color: themeData
                  //                                     .colorScheme.onBackground),
                  //                           ),
                  //                           Container(
                  //                             margin: EdgeInsets.only(top: 2),
                  //                             child: Text(
                  //                               "SEAS, Ahmedabad University",
                  //                               style: AppTheme.getTextStyle(
                  //                                   themeData.textTheme.caption,fontSize: 12,
                  //                                   fontWeight: 500,
                  //                                   color: themeData
                  //                                       .colorScheme.onBackground,
                  //                                   xMuted: true),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             Container(
                  //               margin: EdgeInsets.only(top: 16),
                  //
                  //               child: Row(
                  //                 children: [
                  //                   Container(
                  //                     padding: EdgeInsets.all(8),
                  //                     decoration: BoxDecoration(
                  //                         color: themeData.colorScheme.primary
                  //                             .withAlpha(24),
                  //                         borderRadius: BorderRadius.all(
                  //                             Radius.circular(8))),
                  //                     child: Icon(
                  //                       MdiIcons.tagOutline,
                  //                       size: 18,
                  //                       color: themeData.colorScheme.primary,
                  //                     ),
                  //                   ),
                  //                   Expanded(
                  //                     child: Container(
                  //                       margin: EdgeInsets.only(left: 16),
                  //                       child: Text(
                  //                         "\$99",
                  //                         style: AppTheme.getTextStyle(
                  //                             themeData.textTheme.bodyText2,
                  //                             fontWeight: 600,letterSpacing: 0.3,
                  //                             color: themeData
                  //                                 .colorScheme.onBackground,),
                  //                       ),
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //
                  //
                  //       Container(
                  //         margin: Spacing.fromLTRB(24, 24, 24, 0),
                  //         child: Text(
                  //           "About This Event",
                  //           style: AppTheme.getTextStyle(
                  //               themeData.textTheme.subtitle1,
                  //               fontWeight: 700,
                  //               color: themeData.colorScheme.onBackground),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: Spacing.fromLTRB(24, 12, 24, 0),
                  //         child: RichText(
                  //           text: TextSpan(children: <TextSpan>[
                  //             TextSpan(
                  //                 text: Generator.getDummyText(20),
                  //                 style: AppTheme.getTextStyle(
                  //                     themeData.textTheme.subtitle2,
                  //                     color: themeData.colorScheme.onBackground,
                  //                     muted: true,
                  //                     fontWeight: 500)),
                  //             TextSpan(
                  //                 text: " Read More",
                  //                 style: AppTheme.getTextStyle(
                  //                     themeData.textTheme.caption,
                  //                     color: themeData.colorScheme.primary,
                  //                     fontWeight: 600))
                  //           ]),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: Spacing.fromLTRB(24, 24, 24, 0),
                  //         child: Text(
                  //           "Location",
                  //           style: AppTheme.getTextStyle(
                  //               themeData.textTheme.subtitle1,
                  //               fontWeight: 700,
                  //               color: themeData.colorScheme.onBackground),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: Spacing.fromLTRB(24, 16, 24, 0),
                  //         child: ClipRRect(
                  //           borderRadius:
                  //               BorderRadius.all(Radius.circular(MySize.size8)),
                  //           child: Image(
                  //             image:
                  //                 AssetImage('./assets/other/map-md-snap.png'),
                  //             height: MySize.getScaledSizeHeight(200),
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: Spacing.fromLTRB(24, 16, 24,0),
                  //         child: FlatButton(
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(8)),
                  //           color: themeData.colorScheme.primary,
                  //           splashColor:
                  //               themeData.colorScheme.onPrimary.withAlpha(100),
                  //           highlightColor: themeData.colorScheme.primary,
                  //           onPressed: () {},
                  //           child: Text(
                  //             "Buy Tickets - \$39",
                  //             style: AppTheme.getTextStyle(
                  //                 themeData.textTheme.bodyText2,
                  //                 fontWeight: 600,
                  //                 color: themeData.colorScheme.onPrimary),
                  //           ),
                  //           padding: Spacing.vertical(14),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
            ),
        );
      }


  }

