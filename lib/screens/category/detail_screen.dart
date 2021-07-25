import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/home/EventDetail.dart';
import 'package:we_invited/services/Event_service.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

import 'package:we_invited/utils/AppTheme.dart';

class DetailScreen extends StatefulWidget {
  final _imageUrl;
  final _title;
  final JoinEvent joinEvent;
  final UserDataProfile user;

  DetailScreen(this._imageUrl, this._title, this.joinEvent, this.user);

  @override
  _DetailScreenState createState() =>
      _DetailScreenState(_imageUrl, _title, joinEvent);
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  final _imageUrl;
  final _title;
  ThemeData themeData;
  CustomAppTheme customAppTheme;
  var myuid;
  int numreq = 0;
  final JoinEvent joinEvent;

  _DetailScreenState(this._imageUrl, this._title, this.joinEvent);
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPostswithcategory(postsNotifier, _title);
                  print('เชื่อมต่อ');

                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqPosts(joinNotifier, myuid);

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;
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
  @override
  Widget build(BuildContext context) {
    print("DetailScreen");

    final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    var posts = postsNotifier.postList;
    themeData = Theme.of(context);

    // widget.user.profilePhoto!=null?print("มีรูปDetailScreen"):print("ไม่มีรูปDetailScreen");
    final format2 = new DateFormat(' h:mm');
    final format3 = new DateFormat(' h:mm ');
    return Scaffold(
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          widget._title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.27,
            color: MColors.primaryPurple,
          ),
          // style: boldFont(MColors.primaryPurple, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        <Widget>[],
      ),
      body: RefreshIndicator(
        onRefresh: () => () async {
          await getPostswithcategory(postsNotifier, _title);
          // await getProfile(profileNotifier);
          // await getEvenReqPosts(joinNotifier,myuid);
        }(),
        child: SingleChildScrollView(
          // controller: scrollController,
          physics: BouncingScrollPhysics(),
          child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: posts.length,
                padding: const EdgeInsets.only(top: 8),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 8, bottom: 16),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                ChangeNotifierProvider<JoinNotifier>(
                              create: (context) => JoinNotifier(),
                              builder: (context, child) => PostDetailsV1(
                                  posts[index], widget.user, joinEvent),
                            ),
                          ),
                        );
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 2,
                                    child: CachedNetworkImage(
                                      imageUrl: posts[index].image,
                                      placeholder: (context, url) =>
                                          progressIndicator(
                                              MColors.primaryPurple),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    color: HotelAppTheme.buildLightTheme()
                                        .backgroundColor,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, top: 8, bottom: 8),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    16)),
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          image: posts[index]
                                                              .postbyimage,
                                                          fit: BoxFit.fill,
                                                          height: 39,
                                                          width: 39,
                                                          placeholder:
                                                              "assets/profile1.png",
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            "Host",
                                                            style: AppTheme
                                                                .getTextStyle(
                                                                    themeData
                                                                        .textTheme
                                                                        .caption,
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        500,
                                                                    xMuted:
                                                                        true),
                                                          ),
                                                          Text(
                                                            posts[index]
                                                                .postbyname,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  // Text(
                                                  //   posts.postbyname,
                                                  //   textAlign: TextAlign.left,
                                                  //   style: TextStyle(
                                                  //     fontWeight: FontWeight.w600,
                                                  //     fontSize: 15,
                                                  //   ),
                                                  // ),
                                                  Text(
                                                    posts[index].name ?? "",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2),
                                                        child: Text(
                                                          '${format2.format(posts[index].startdateTime.toDate())} -${format3.format(posts[index].entdateTime.toDate())} ',
                                                          style: AppTheme
                                                              .getTextStyle(
                                                                  themeData
                                                                      .textTheme
                                                                      .caption,
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      500,
                                                                  xMuted: true),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 4,
                                                      ),
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .mapMarkerAlt,
                                                        size: 12,
                                                        color: HotelAppTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
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
                                                          ' $numreq/${posts[index].Numpeople} จำนวนผู้เข้าร่วม',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.8)),
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
                                          padding: const EdgeInsets.only(
                                              right: 16, top: 8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(height: 30),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              DesignCourseAppTheme
                                                                  .nearlyBlue,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          24.0)),
                                                          border: Border.all(
                                                              color: DesignCourseAppTheme
                                                                  .nearlyBlue)),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          splashColor:
                                                              Colors.white24,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          24.0)),
                                                          onTap: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              CupertinoPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    ChangeNotifierProvider<
                                                                        JoinNotifier>(
                                                                  create: (context) =>
                                                                      JoinNotifier(),
                                                                  builder: (context,
                                                                          child) =>
                                                                      PostDetailsV1(
                                                                          posts[
                                                                              index],
                                                                          widget
                                                                              .user,
                                                                          joinEvent),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10,
                                                                    bottom: 12,
                                                                    left: 18,
                                                                    right: 18),
                                                            child: Center(
                                                              child: Text(
                                                                "ดูเพิ่มเติม",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.27,
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
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(32.0),
                                    ),
                                    onTap: () {
                                      print('กด');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: HotelAppTheme.buildLightTheme()
                                            .primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
