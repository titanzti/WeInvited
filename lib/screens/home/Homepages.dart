import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/bannerAd_notifier.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/Notification/Notifica.dart';
import 'package:we_invited/screens/auth/interest.dart';
import 'package:we_invited/screens/create_event/Post_activity.dart';
import 'package:we_invited/screens/home/EventList.dart';
import 'package:we_invited/shared/text_style.dart';
import 'package:we_invited/screens/home/EventDetail.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'dart:ui';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/app_utils.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/ui_helper.dart';
import 'package:expandable_text/expandable_text.dart';

class HomeFeed extends StatefulWidget {
  final JoinEvent joinEvent;
  final Post postDetails;

  HomeFeed({Key key, this.joinEvent, this.postDetails}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(joinEvent, postDetails);
}

class _HomeState extends State<HomeFeed> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Post postDetails = Post();

  ThemeData themeData;
  int selectedCategory = 0;
  CustomAppTheme customAppTheme;
  DateTime _date = DateTime.now();
  var myuid;
  ScrollController scrollController;
  AnimationController controller;
  AnimationController opacityController;
  Animation<double> opacity;
  final JoinEvent joinEvent;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  TextEditingController _searchController = TextEditingController();

  Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  bool isExpanded = false;
  double _height;
  double _width;
  String _token = "token";

  Future getPostsFuture;
  Future getPopPostsFuture;

  Future getOtherPostsFuture;

  Future getProfileFuture;
  Future getEvenReqFuture;
  Future getBannerAdsFuture;
  List<String> formValue;

  _HomeState(this.joinEvent, this.postDetails);

  @override
  void initState() {
    print("initStateHome");

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
                  initFirebaseMessaging();
                  // getCurrentUser();
                  // updateToken();

                  _fcm.getToken().then((String token) {
                    _token = '$token';

                    // setState(() {
                    //   _token='$token';
                    // });
                    assert(token != null);
                    print("Token : $token");
                  });

                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPostsFuture = getPosts(postsNotifier);

                  PostNotifier postsPopNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPopPostsFuture = getPostsPop(postsPopNotifier);

                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfileFuture = getProfile(profileNotifier);

                  JoinNotifier joinNotifier =
                      Provider.of<JoinNotifier>(context, listen: false);
                  getEvenReqFuture = getEvenReqPosts(joinNotifier);

                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final User user = auth.currentUser;
                  final uid = user.uid.toString();
                  myuid = uid;

                  BannerAdNotifier bannerAdNotifier =
                      Provider.of<BannerAdNotifier>(context, listen: false);
                  getBannerAdsFuture = getBannerAds(bannerAdNotifier);

                  // resultsLoaded = getUsersPastTripsStreamSnapshots();

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
    _searchController.addListener(_onSearchChanged);
  }

  void initFirebaseMessaging() {
    print("initFirebaseMessaging");
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        final snackbar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () => null,
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        final snackbar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () => null,
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final snackbar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () => null,
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
    );

    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _fcm.getToken().then((String token) {
      assert(token != null);
      print("Token : $token");
    });
  }

  @override
  void dispose() {
    print("disposeHome");
    PostNotifier postsNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    getPosts(postsNotifier);

    controller.dispose();
    scrollController.dispose();
    opacityController.dispose();

    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    resultsLoaded = getUsersPastTripsStreamSnapshots();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    resultsLoaded = getUsersPastTripsStreamSnapshots();

    super.didChangeDependencies();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var tripSnapshot in _allResults) {
        var title = Post.fromSnapshot(tripSnapshot).name.toLowerCase();

        if (title.contains(_searchController.text.toLowerCase())) {
          showResults.add(tripSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    if (this.mounted) {
      setState(() {
        print('setStatesearchResultsList');
        _resultsList = showResults;
      });
    }
    if (!mounted) return progressIndicator(MColors.primaryPurple);
  }

  getUsersPastTripsStreamSnapshots() async {
    print("getUsersPastTripsStreamSnapshots");
    var data = await FirebaseFirestore.instance
        .collection("Posts")
        // .where("name", isLessThanOrEqualTo: _searchController)
        .get();
    if (this.mounted) {
      setState(() {
        print("setStategetUsersPastTripsStreamSnapshots");
        _allResults = data.docs;
      });
    }
    if (!mounted) return progressIndicator(MColors.primaryPurple);

    searchResultsList();
    return "complete";
  }

  getEvenReqPosts(JoinNotifier joinNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
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

  void _expand() {
    setState(() {
      isExpanded ? isExpanded = false : isExpanded = true;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    print("buildHome");

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    var posts = postsNotifier.postList;
    themeData = Theme.of(context);

    final PostNotifier postsPopNotifier = Provider.of<PostNotifier>(context);
    var postspop = postsPopNotifier.postList;

    UserDataProfileNotifier profileNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;

    JoinNotifier joinNotifier =
        Provider.of<JoinNotifier>(context, listen: false);

    var joins = joinNotifier.joineventList;

    BannerAdNotifier bannerAdNotifier = Provider.of<BannerAdNotifier>(context);
    var bannerAds = bannerAdNotifier.bannerAdsList;

    final format = DateFormat("dd");
    final format1 = DateFormat("MMM");
    final format2 = new DateFormat(' h:mm');
    final format3 = new DateFormat(' h:mm ');
    // print();
    return FutureBuilder(
      future: Future.wait([
        getPostsFuture,
        getProfileFuture,
        getEvenReqFuture,
        getBannerAdsFuture,
        getPopPostsFuture,
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                postsNotifier.currentPost = null;
                UserDataProfileNotifier profileNotifier =
                    Provider.of<UserDataProfileNotifier>(context,
                        listen: false);
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => PostActivity(
                      isUpdating: false,
                      userData: user,
                    ),
                  ),
                );
                if (navigationResult == true) {
                  setState(() {
                    print("setStategetProfile");
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
            // backgroundColor: Colors.black,
            body: RefreshIndicator(
              onRefresh: () => () async {
                await getPosts(postsNotifier);
                await getProfile(profileNotifier);
                await getEvenReqPosts(joinNotifier);
                await getBannerAds(bannerAdNotifier);
                await getPostsPop(postsPopNotifier);
              }(),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 24, top: 5, right: 24, bottom: 0),
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
                                    "We Invited",
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.headline5,
                                        fontSize: 24,
                                        fontWeight: 700,
                                        letterSpacing: -0.3,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              // Container(
                              //   padding: const EdgeInsets.all(10.0),
                              //   decoration: BoxDecoration(
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(8)),
                              //   ),
                              //   child: InkWell(
                              //     onTap: () async {
                              //       print('ปุ่มกด');
                              //       // signOutGoogle(_token);
                              //       HapticFeedback.mediumImpact();
                              //       // postsNotifier.currentPost = null;
                              //       // UserDataProfileNotifier profileNotifier =
                              //       //     Provider.of<UserDataProfileNotifier>(
                              //       //         context,
                              //       //         listen: false);
                              //       // PostNotifier postsNotifier =
                              //       //     Provider.of<PostNotifier>(context,
                              //       //         listen: false);
                              //       // var navigationResult =
                              //       //     await
                              //       // if (navigationResult == true) {
                              //       //   setState(() {
                              //       //     getProfile(profileNotifier);
                              //       //     getPosts(postsNotifier);
                              //       //     getEvenReqPosts(joinNotifier);
                              //       //   });
                              //       // }
                              //       Navigator.of(context).push(
                              //         CupertinoPageRoute(
                              //           builder: (BuildContext context) =>
                              //               ChangeNotifierProvider<
                              //                   JoinNotifier>(
                              //             create: (context) => JoinNotifier(),
                              //             builder: (context, child) =>
                              //                 NotificationPage(),
                              //           ),
                              //         ),
                              //       );
                              //     },
                              //     child: Icon(
                              //       MdiIcons.bell,
                              //       size: 18,
                              //       color: Colors.grey,
                              //     ),
                              //   ),
                              // ),

                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    bottom_sheet(context, formValue);
                                  },
                                  child: Icon(
                                    MdiIcons.settingsHelper,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Container(
                          //   margin: const EdgeInsets.only(left: 16.0),
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.all(Radius.circular(16)),
                          //     child: user.profilePhoto != null
                          //         ? FadeInImage.assetNetwork(
                          //             image: user.profilePhoto,
                          //             fit: BoxFit.fill,
                          //             height: 36,
                          //             width: 36,
                          //             placeholder: "assets/profile1.png",
                          //           )
                          //         : FadeInImage.assetNetwork(
                          //             image: 'assets/profile1.png',
                          //             fit: BoxFit.fill,
                          //             height: 36,
                          //             width: 36,
                          //             placeholder: "assets/profile1.png",
                          //           ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    /////////////////////////

                    Container(
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 170.0,
                          enableInfiniteScroll: false,
                          initialPage: 0,
                          viewportFraction: 0.95,
                          scrollPhysics: BouncingScrollPhysics(),
                        ),
                        items: bannerAds.map((banner) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: FadeInImage.assetNetwork(
                                    image: banner.bannerAd,
                                    fit: BoxFit.fill,
                                    placeholder: "assets/placeholder.jpg",
                                    placeholderScale:
                                        MediaQuery.of(context).size.width / 2,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, right: 40, top: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 8,
                        child: Container(
                          child: TextFormField(
                            controller: _searchController,
                            cursorColor: Colors.orange[200],
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.orange[200], size: 30),
                              hintText: "What're you looking for?",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Text('Category', style: TextStyle(fontSize: 16)),
                          // GestureDetector(
                          //     onTap: _expand,
                          //     child: Text(
                          //       isExpanded ? "Show less" : "Show all",
                          //       style: TextStyle(
                          //         color: Colors.orange[200],
                          //       ),
                          //     )),
                          //IconButton(icon: isExpanded? Icon(Icons.arrow_drop_up, color: Colors.orange[200],) : Icon(Icons.arrow_drop_down, color: Colors.orange[200],), onPressed: _expand)
                        ],
                      ),
                    ),
                    // expandList(),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    // Divider(),

                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 4, right: 10, bottom: 0),
                      child: Row(
                        children: [
                          Divider(),
                          Expanded(
                            child: Text(
                              "Popular",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle1,
                                  fontWeight: 700,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 8, bottom: 16),
                      margin: EdgeInsets.only(
                          left: 10, top: 4, right: 18, bottom: 0),
                      child: SizedBox(
                        //ขนาดPopular
                        height: 300.0,
                        // width: 800.0,
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: posts.length,
                          itemBuilder: (BuildContext context, int index) =>
                              Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            child: InkWell(
                              onTap: () async {
                                UserDataProfileNotifier profileNotifier =
                                    Provider.of<UserDataProfileNotifier>(
                                        context,
                                        listen: false);

                                JoinNotifier joinNotifier =
                                    Provider.of<JoinNotifier>(context,
                                        listen: false);

                                // getEvenReqPosts(joinNotifier);
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) =>
                                        ChangeNotifierProvider(
                                      create: (context) => JoinNotifier(),
                                      builder: (context, child) =>
                                          PostDetailsV1(
                                              postspop[index], user, joinEvent),
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  setState(() {
                                    print("getProfile -getEvenReqPosts");
                                    // getProfile(profileNotifier);
                                    getEvenReqPosts(joinNotifier);
                                  });
                                }
                              },
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    border: Border.all(
                                        color: Color(0xffeef2fa), width: 0.60),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                width: 250,
                                // height: 200,
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
                                                placeholder: (context, url) =>
                                                    progressIndicator(
                                                        MColors.primaryPurple),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -16,
                                            left: 16,
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 8,
                                                  top: 4,
                                                  right: 8,
                                                  bottom: 4),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffffffff),
                                                  border: Border.all(
                                                      color: Color(0xffeef2fa),
                                                      width: 0.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color(0xff1f1f1f)
                                                            .withAlpha(150),
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1))
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${format.format(posts[index].startdateTime.toDate())}',
                                                    style:
                                                        AppTheme.getTextStyle(
                                                            themeData.textTheme
                                                                .bodyText2,
                                                            color: themeData
                                                                .colorScheme
                                                                .primary,
                                                            fontWeight: 600),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    '${format1.format(posts[index].startdateTime.toDate())}',
                                                    style:
                                                        AppTheme.getTextStyle(
                                                            themeData.textTheme
                                                                .bodyText2,
                                                            fontSize: 11,
                                                            color: themeData
                                                                .colorScheme
                                                                .primary,
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
                                      padding: EdgeInsets.only(
                                          left: 16,
                                          top: 24,
                                          right: 16,
                                          bottom: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(posts[index].name,
                                                  style: titleStyle),
                                              UIHelper.verticalSpace(4),
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.location_on,
                                                      size: 16,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  UIHelper.horizontalSpace(4),
                                                  // ExpandableText(
                                                  //   posts[index].place,
                                                  //   style: subtitleStyle,
                                                  //   expandText: 'show more',
                                                  //   collapseText: 'show less',
                                                  //   maxLines: 1,
                                                  //   linkColor: Colors.blue,
                                                  //   onExpandedChanged:
                                                  //       (value) => print(value),
                                                  // ),
                                                ],
                                              ),
                                              Text(
                                                posts[index].place,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                    ],
                                                  ),
                                                ),
                                                // Container(
                                                //   child: Icon(
                                                //     MdiIcons.heartOutline,
                                                //     color: themeData
                                                //         .colorScheme.primary,
                                                //   ),
                                                // )
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
                    ),
                    ///////////////////ค้นหา
                    _searchController.text == ""
                        ? Builder(
                            builder: (BuildContext context) {
                              return ListView.builder(
                                physics: ClampingScrollPhysics(),
                                itemCount: posts.length,
                                padding: const EdgeInsets.only(top: 8),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return PostListView(
                                    posts: posts[index],
                                  );
                                },
                              );
                            },
                          )
                        : Builder(
                            builder: (BuildContext context) {
                              return ListView.builder(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: _resultsList.length,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(top: 8),
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        buildTripCard(
                                            context, _resultsList[index], user),
                              );
                            },
                          ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTripCard(
      BuildContext context, DocumentSnapshot document, UserDataProfile user) {
    final posts = Post.fromSnapshot(document);

    final format2 = new DateFormat(' h:mm');
    final format3 = new DateFormat(' h:mm ');
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 16),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          UserDataProfileNotifier profileNotifier =
              Provider.of<UserDataProfileNotifier>(context, listen: false);

          JoinNotifier joinNotifier =
              Provider.of<JoinNotifier>(context, listen: false);

          // getEvenReqPosts(joinNotifier);
          var navigationResult = await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider(
                create: (context) => JoinNotifier(),
                builder: (context, child) =>
                    PostDetailsV1(posts, user, joinEvent),
              ),
            ),
          );
          if (navigationResult == true) {
            setState(() {
              getProfile(profileNotifier);
              getEvenReqPosts(joinNotifier);
            });
          }
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
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          child: FadeInImage.assetNetwork(
                                            image: posts.postbyimage,
                                            fit: BoxFit.fill,
                                            height: 39,
                                            width: 39,
                                            placeholder: "assets/profile1.png",
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
                                    // Text(
                                    //   posts.postbyname,
                                    //   textAlign: TextAlign.left,
                                    //   style: TextStyle(
                                    //     fontWeight: FontWeight.w600,
                                    //     fontSize: 15,
                                    //   ),
                                    // ),
                                    Text(
                                      posts.name ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 2),
                                          child: Text(
                                            '${format2.format(posts.startdateTime.toDate())} -${format3.format(posts.entdateTime.toDate())} ',
                                            style: AppTheme.getTextStyle(
                                                themeData.textTheme.caption,
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: 500,
                                                xMuted: true),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Icon(
                                          FontAwesomeIcons.mapMarkerAlt,
                                          size: 12,
                                          color: HotelAppTheme.buildLightTheme()
                                              .primaryColor,
                                        ),
                                      ],
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
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                DesignCourseAppTheme.nearlyBlue,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(24.0)),
                                            border: Border.all(
                                                color: DesignCourseAppTheme
                                                    .nearlyBlue)),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: Colors.white24,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(24.0)),
                                            onTap: () async {
                                              UserDataProfileNotifier
                                                  profileNotifier = Provider.of<
                                                          UserDataProfileNotifier>(
                                                      context,
                                                      listen: false);

                                              JoinNotifier joinNotifier =
                                                  Provider.of<JoinNotifier>(
                                                      context,
                                                      listen: false);

                                              // getEvenReqPosts(joinNotifier);
                                              var navigationResult =
                                                  await Navigator.of(context)
                                                      .push(
                                                CupertinoPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ChangeNotifierProvider<
                                                          JoinNotifier>(
                                                    create: (context) =>
                                                        JoinNotifier(),
                                                    builder: (context, child) =>
                                                        PostDetailsV1(posts,
                                                            user, joinEvent),
                                                  ),
                                                ),
                                              );
                                              if (navigationResult == true) {
                                                setState(() {
                                                  getProfile(profileNotifier);
                                                  getEvenReqPosts(joinNotifier);
                                                });
                                              }
                                              //   Navigator.of(context).push(
                                              //       CupertinoPageRoute(builder: (BuildContext context){
                                              //         return PostDetailsProv(posts);
                                              //       }));
                                              //
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 12,
                                                  left: 18,
                                                  right: 18),
                                              child: Center(
                                                child: Text(
                                                  "ดูเพิ่มเติม",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    letterSpacing: 0.27,
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

  Widget expandList() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: AnimatedCrossFade(
        firstChild: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    //Navigator.of(context).pushNamed(ELECTRONICS_ITEM_LIST);
                    print('Routing to Electronics item list');
                  },
                  child: Image.asset(
                    'assets/gadget.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Electronics",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(PROPERTIES_ITEM_LIST);
                      print('Routing to Properties item list');
                    },
                    child: Image.asset(
                      'assets/house.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Properties",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(JOBS_ITEM_LIST);
                      print('Routing to Jobs item list');
                    },
                    child: Image.asset(
                      'assets/job.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Jobs",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(FURNITURE_ITEM_LIST);
                      print('Routing to Furniture item list');
                    },
                    child: Image.asset(
                      'assets/sofa.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Furniture",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(CARS_ITEM_LIST);
                    print('Routing to Cars item list');
                  },
                  child: Image.asset(
                    'assets/car.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Cars",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(BIKES_ITEM_LIST);
                    print('Routing to Bikes item list');
                  },
                  child: Image.asset(
                    'assets/bike.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Bikes",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(MOBILES_ITEM_LIST);
                      print('Routing to Mobiles item list');
                    },
                    child: Image.asset(
                      'assets/smartphone.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Mobiles",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(PETS_ITEM_LIST);
                    print('Routing to Pets item list');
                  },
                  child: Image.asset(
                    'assets/pet.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Pets",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        secondChild: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(ELECTRONICS_ITEM_LIST);
                    print('Routing to Electronics item list');
                  },
                  child: Image.asset(
                    'assets/gadget.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Electronics",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(PROPERTIES_ITEM_LIST);
                      print('Routing to Properties item list');
                    },
                    child: Image.asset(
                      'assets/house.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Properties",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(JOBS_ITEM_LIST);
                      print('Routing to Jobs item list');
                    },
                    child: Image.asset(
                      'assets/job.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Jobs",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(FURNITURE_ITEM_LIST);
                      print('Routing to Furniture item list');
                    },
                    child: Image.asset(
                      'assets/sofa.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Furniture",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(CARS_ITEM_LIST);
                    print('Routing to Cars item list');
                  },
                  child: Image.asset(
                    'assets/car.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Cars",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(BIKES_ITEM_LIST);
                    print('Routing to Bikes item list');
                  },
                  child: Image.asset(
                    'assets/bike.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Bikes",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed(MOBILES_ITEM_LIST);
                      print('Routing to Mobiles item list');
                    },
                    child: Image.asset(
                      'assets/smartphone.png',
                      height: _height / 12,
                      width: _width / 12,
                    )),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Mobiles",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(PETS_ITEM_LIST);
                    print('Routing to Pets item list');
                  },
                  child: Image.asset(
                    'assets/pet.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Pets",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pushNamed(FASHION_ITEM_LIST);
                    print('Routing to Fashion item list');
                  },
                  child: Image.asset(
                    'assets/dress.png',
                    height: _height / 12,
                    width: _width / 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    "Fashion",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      ),
    );
  }
}

void bottom_sheet(BuildContext context, formValue) {
  final formKey = GlobalKey<FormState>();
  List<String> options = [
    'Sport',
    'Education',
    'Food & Drink',
    'Games',
    'Nature & Park',
    'Party',
    'Shopping',
    'Health',
    'Business',
    'Other',
  ];

  var select;
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        print('${formValue.toString()}');

        return Container(
          height: MediaQuery.of(context).size.height * .50,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                FormField<List<String>>(
                  autovalidate: true,
                  initialValue: formValue,
                  onSaved: (val) {
                    formValue = val;

                    // setState(() {
                    //   formValue = val;
                    // });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? value == null) {
                      return 'Please select some categories';
                    }
                    if (value.length > 5) {
                      return "Can't select more than 5 categories";
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: ChipsChoice<String>.multiple(
                            value: state.value,
                            onChanged: (val) {
                              state.didChange(val);
                              // setState(() {
                              //   select = val;
                              // });
                              print(val);
                            },
                            choiceItems: C2Choice.listFrom<String, String>(
                              source: options,
                              value: (i, v) => v.toLowerCase(),
                              label: (i, v) => v,
                              tooltip: (i, v) => v,
                            ),
                            choiceStyle: const C2ChoiceStyle(
                              color: Colors.indigo,
                              borderOpacity: .3,
                            ),
                            choiceActiveStyle: const C2ChoiceStyle(
                              color: Colors.indigo,
                              brightness: Brightness.dark,
                            ),
                            wrapped: true,
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              state.errorText ??
                                  state.value.length.toString() + '/5 selected',
                              style: TextStyle(
                                  color: state.hasError
                                      ? Colors.redAccent
                                      : Colors.green),
                            ))
                      ],
                    );
                  },
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Expanded(
                      //   child: Column(
                      //       crossAxisAlignment:
                      //           CrossAxisAlignment.start,
                      //       children: <Widget>[
                      //         const Text('Selected Value:'),
                      //         SizedBox(height: 5),
                      //         Text('$select'),
                      //       ]),
                      // ),
                      SizedBox(
                        height: 150,
                        width: 5,
                      ),
                      RaisedButton(
                          child: const Text('Submit'),
                          color: Colors.blueAccent,
                          padding: const EdgeInsets.only(
                              left: 100, right: 100, bottom: 16, top: 16),
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(16),
                            // side: BorderSide(color: Colors.black),
                          ),
                          onPressed: () async {
                            // // Validate returns true if the form is valid, or false otherwise.
                            // if (formKey.currentState.validate()) {
                            //   // If the form is valid, save the value.
                            //   formKey.currentState.save();
                            //   updateinterest();

                            //   Navigator.pushAndRemoveUntil(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (BuildContext context) =>
                            //               MyApp()),
                            //       (Route<dynamic> route) => false);
                            // }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
