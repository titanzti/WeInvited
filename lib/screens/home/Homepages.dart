import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/home/acposts_list_view.dart';
import 'package:we_invited/screens/home/testdetail.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/constant.dart';
import 'dart:ui';
import 'package:we_invited/shared/icon_badge.dart';
import 'package:we_invited/Activity/Post_activity.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/SizeConfig.dart';
import 'package:we_invited/utils/app_utils.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/provider.dart';

import '../../main.dart';

class HomeFeed extends StatefulWidget {
  HomeFeed({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeFeed> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  ThemeData themeData;
  int selectedCategory = 0;
  CustomAppTheme customAppTheme;
  DateTime _date = DateTime.now();
var myuid;
  ScrollController scrollController;
  AnimationController controller;
  AnimationController opacityController;
  Animation<double> opacity;

  @override
  void initState() {
    scrollController = ScrollController();
    controller =
    AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..forward();
    opacityController =
        AnimationController(vsync: this, duration: Duration(microseconds: 1));
    opacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      curve: Curves.linear,
      parent: opacityController,
    ));
    scrollController.addListener(() {
      opacityController.value = offsetToOpacity(
          currentOffset: scrollController.offset,
          maxOffset: scrollController.position.maxScrollExtent / 2);
    });
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPosts(postsNotifier);
                  print('เชื่อมต่อ');

                  UserDataProfileNotifier profileNotifier =
                  Provider.of<UserDataProfileNotifier>(context,
                      listen: false);
                 getProfile(profileNotifier);

                  JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
                      listen: false);
                  getEvenReqPosts(joinNotifier);


                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;



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

  @override
  void dispose() {
    PostNotifier postsNotifier = Provider.of<PostNotifier>(context, listen: false);
    getPosts(postsNotifier);
    controller.dispose();
    scrollController.dispose();
    opacityController.dispose();
    super.dispose();
  }
  getEvenReqPosts(JoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot= await  FirebaseFirestore.instance
        .collection('JoinEvent')
        .doc(myuid)
        .collection('JoinEventList')
    .orderBy('requestpostid')
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
    final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    var posts = postsNotifier.postList;
    themeData = Theme.of(context);


    UserDataProfileNotifier profileNotifier =
    Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;

    JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
        listen: false);


    var joins = joinNotifier.joineventList;

    // print(user.name);
    //  print(user.profilePhoto);

    // user.profilePhoto!=null?print("มีรูป"):print("ไม่มีรูป");

    print('build HomeFeed');
    final format = DateFormat("dd");
    final format1 = DateFormat("MMM");
    final format2 = new DateFormat(' h:mm');
    final format3 = new DateFormat(' h:mm ');

    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

        return Scaffold(


          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              postsNotifier.currentPost = null;
              UserDataProfileNotifier profileNotifier =
              Provider.of<UserDataProfileNotifier>(
                  context,
                  listen: false);
              var navigationResult =
                  await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) =>
                      PostActivity(isUpdating: false,userData: user,),
                ),
              );
              if (navigationResult == true) {
                setState(() {
                  getProfile(profileNotifier);
                });
              }

              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (BuildContext context) {
              //     return PostActivity(
              //       isUpdating: false,
              //     );
              //   }),
              // );
            },
            child: Icon(Icons.add),
            foregroundColor: Colors.white,
          ),
          key: _scaffoldKey,
          backgroundColor: MColors.primaryWhiteSmoke,
          body:
          RefreshIndicator(
            onRefresh: () => () async {
              await getPosts(postsNotifier);
              await getProfile(profileNotifier);
              await getEvenReqPosts(joinNotifier);

            }(),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    margin: EdgeInsets.only(left: 24, top: 45, right: 24, bottom: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today ${format.format(_date)}",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 400,
                                    letterSpacing: 0,
                                    color: Colors.black),
                              ),
                              Container(
                                child: Text(
                                  "Discover Events",
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.headline5,
                                      fontSize: 24,
                                      fontWeight: 700,
                                      letterSpacing: -0.3,
                                      color:
                                      Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8)),
                              ),
                              child: Icon(
                                MdiIcons.bell,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(

                          margin: const EdgeInsets.only(left: 16.0),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(16)),
                            child: FadeInImage.assetNetwork(
                              image: user.profilePhoto,
                              fit: BoxFit.fill,
                              height: 36,
                              width: 36,
                              placeholder:
                              "assets/profile1.png",
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  /////////////////////////
                  Container(
                    margin: EdgeInsets.only(left: 24, top: 4, right: 24, bottom: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Popular",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle1,
                                fontWeight: 700,
                                color: Colors.black),
                          ),
                        ),
                        Text(
                          "View All",
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontWeight: 600,
                              color: themeData.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) => Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        child: InkWell(
                          onTap: () async{
                            UserDataProfileNotifier profileNotifier =
                            Provider.of<UserDataProfileNotifier>(
                                context,
                                listen: false);
                            var navigationResult =
                                await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) =>
                                    PostDetailsProv(posts[index],user),
                              ),
                            );
                            if (navigationResult == true) {
                              setState(() {
                                getProfile(profileNotifier);
                              });
                            }
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                border: Border.all(color: Color(0xffeef2fa), width: 0.20),
                                borderRadius: BorderRadius.all(Radius.circular(8))),
                            width:  200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 2,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8)),
                                          child: CachedNetworkImage(
                                            imageUrl: posts[index].image,
                                            placeholder: (context, url) => progressIndicator(MColors.primaryPurple),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom: -16,
                                        left: 16,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
                                          decoration: BoxDecoration(
                                              color: Color(0xffffffff),
                                              border: Border.all(
                                                  color: Color(0xffeef2fa), width: 0.5),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color(0xff1f1f1f).withAlpha(150),
                                                    blurRadius: 1,
                                                    offset: Offset(0, 1))
                                              ],
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(8))),
                                          child: Column(
                                            children: [
                                              Text('${format.format(posts[index].startdateTime.toDate())}',
                                                style: AppTheme.getTextStyle(
                                                    themeData.textTheme.bodyText2,
                                                    color: themeData.colorScheme.primary,
                                                    fontWeight: 600),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text('${format1.format(posts[index].startdateTime.toDate())}',
                                                style: AppTheme.getTextStyle(
                                                    themeData.textTheme.bodyText2,
                                                    fontSize: 11,
                                                    color: themeData.colorScheme.primary,
                                                    fontWeight: 600),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        posts[index].name,
                                        style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                                            color: Colors.black,
                                            fontWeight: 600),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Text(
                                                  //   subject,
                                                  //   style: AppTheme.getTextStyle(
                                                  //       themeData.textTheme.caption,
                                                  //       fontSize: 12,
                                                  //       color: themeData.colorScheme.onBackground,
                                                  //       fontWeight: 500,
                                                  //       xMuted: true),
                                                  // ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 2),
                                                    child:
                                                    Text('${format2.format(posts[index].startdateTime.toDate())} -${format3.format(posts[index].entdateTime.toDate())} ',
                                                      style: AppTheme.getTextStyle(
                                                          themeData.textTheme.caption,
                                                          fontSize: 10,
                                                          color: Colors.black,
                                                          fontWeight: 500,
                                                          xMuted: true),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                MdiIcons.heartOutline,
                                                color: themeData.colorScheme.primary,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (BuildContext context){
                      return ListView.builder(
                        physics: ClampingScrollPhysics(),
                        itemCount: posts.length,
                        padding: const EdgeInsets.only(top: 8),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return PostListView(
                            callback: () {},
                            posts: posts[index],
                          );
                        },
                      );
                    },
                  ),

                  SizedBox(height: 20),




                ],

              ),


            ),


          ),

        );
      },
    );
  }

}
