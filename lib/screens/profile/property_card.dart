import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:we_invited/models/post.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/ui_helper.dart';

class PropertyCard extends StatefulWidget {
  final Post posts;

  PropertyCard({Key key, this.posts});

  @override
  _PropertyCardState createState() => _PropertyCardState(posts);
}

class _PropertyCardState extends State<PropertyCard> {
  final Post posts;
  ThemeData themeData;

  _PropertyCardState(this.posts);

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 16),
      child: InkWell(
        splashColor: Colors.transparent,
        // onTap: () async {
        //   UserDataProfileNotifier profileNotifier =
        //       Provider.of<UserDataProfileNotifier>(context, listen: false);

        //   JoinNotifier joinNotifier =
        //       Provider.of<JoinNotifier>(context, listen: false);

        //   // getEvenReqPosts(joinNotifier);
        //   var navigationResult = await Navigator.of(context).push(
        //     CupertinoPageRoute(
        //       builder: (BuildContext context) => ChangeNotifierProvider(
        //         create: (context) => JoinNotifier(),
        //         builder: (context, child) =>
        //             PostDetailsV1(posts, user, joinEvent),
        //       ),
        //     ),
        //   );
        //   if (navigationResult == true) {
        //     setState(() {
        //       getProfile(profileNotifier);
        //       getEvenReqPosts(joinNotifier);
        //     });
        //   }
        // },
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
                                          // onTap: () async {
                                          //   Navigator.of(context).push(
                                          //     CupertinoPageRoute(
                                          //       builder:
                                          //           (BuildContext context) =>
                                          //               ChangeNotifierProvider(
                                          //         create: (context) =>
                                          //             PostNotifier(),
                                          //         builder: (context, child) =>
                                          //             Otherprofile(
                                          //           postDetails: posts,
                                          //           user: user,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   );
                                          // },
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
                                        Text(
                                          posts.name ?? "",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 2),
                                        //   child: Text(
                                        //     '${format2.format(posts.startdateTime.toDate())} -${format3.format(posts.entdateTime.toDate())} ',
                                        //     style: AppTheme.getTextStyle(
                                        //         themeData.textTheme.caption,
                                        //         fontSize: 14,
                                        //         color: Colors.black,
                                        //         fontWeight: 500,
                                        //         xMuted: true),
                                        //   ),
                                        // ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                      ],
                                    ),

                                    UIHelper.horizontalSpace(2),
                                    Icon(Icons.location_on,
                                        size: 16,
                                        color: Theme.of(context).primaryColor),
                                    Text(
                                      posts.place.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
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
                                          // Text(
                                          //   ' $totalreq/${posts.Numpeople} จำนวนผู้เข้าร่วม',
                                          //   style: TextStyle(
                                          //       fontSize: 14,
                                          //       color: Colors.black
                                          //           .withOpacity(0.8)),
                                          // ),
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
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       color:
                                      //           DesignCourseAppTheme.nearlyBlue,
                                      //       borderRadius:
                                      //           const BorderRadius.all(
                                      //               Radius.circular(24.0)),
                                      //       border: Border.all(
                                      //           color: DesignCourseAppTheme
                                      //               .nearlyBlue)),
                                      //   child: Material(
                                      //     color: Colors.transparent,
                                      //     child: InkWell(
                                      //       splashColor: Colors.white24,
                                      //       borderRadius:
                                      //           const BorderRadius.all(
                                      //               Radius.circular(24.0)),
                                      //       // onTap: () async {
                                      //       //   UserDataProfileNotifier
                                      //       //       profileNotifier = Provider.of<
                                      //       //               UserDataProfileNotifier>(
                                      //       //           context,
                                      //       //           listen: false);

                                      //       //   JoinNotifier joinNotifier =
                                      //       //       Provider.of<JoinNotifier>(
                                      //       //           context,
                                      //       //           listen: false);

                                      //       //   // getEvenReqPosts(joinNotifier);
                                      //       //   var navigationResult =
                                      //       //       await Navigator.of(context)
                                      //       //           .push(
                                      //       //     CupertinoPageRoute(
                                      //       //       builder: (BuildContext
                                      //       //               context) =>
                                      //       //           ChangeNotifierProvider<
                                      //       //               JoinNotifier>(
                                      //       //         create: (context) =>
                                      //       //             JoinNotifier(),
                                      //       //         builder: (context, child) =>
                                      //       //             PostDetailsV1(posts,
                                      //       //                 user, joinEvent),
                                      //       //       ),
                                      //       //     ),
                                      //       //   );
                                      //       //   if (navigationResult == true) {
                                      //       //     setState(() {
                                      //       //       // getOtherProfile(
                                      //       //       //     otherprofileNotifier);
                                      //       //       getEvenReqPosts(joinNotifier);
                                      //       //     });
                                      //       //   }
                                      //       //   //   Navigator.of(context).push(
                                      //       //   //       CupertinoPageRoute(builder: (BuildContext context){
                                      //       //   //         return PostDetailsProv(posts);
                                      //       //   //       }));
                                      //       //   //
                                      //       // },
                                      //       child: Padding(
                                      //         padding: const EdgeInsets.only(
                                      //             top: 10,
                                      //             bottom: 12,
                                      //             left: 18,
                                      //             right: 18),
                                      //         child: Center(
                                      //           child: Text(
                                      //             "ดูเพิ่มเติม",
                                      //             textAlign: TextAlign.left,
                                      //             style: TextStyle(
                                      //               fontWeight: FontWeight.w600,
                                      //               fontSize: 12,
                                      //               letterSpacing: 0.27,
                                      //               color: DesignCourseAppTheme
                                      //                   .nearlyWhite,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
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
                          color: HotelAppTheme.buildLightTheme().primaryColor,
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
  }
}
