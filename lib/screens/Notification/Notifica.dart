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
import 'package:we_invited/screens/home/acposts_list_view.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/icon_badge.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class NotificationPage extends StatefulWidget {
  final Post postDetails;
  final UserDataProfile userData;
  NotificationPage({Key key, this.postDetails, this.userData}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}


class _NotificationPageState extends State<NotificationPage> {
   Post postDetails = Post();

var myuid;

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
      value == true
          ? () {
        PostNotifier postsNotifier = Provider.of<PostNotifier>(context, listen: false);
        getMyPosts(postsNotifier);
        print('เชื่อมต่อ');

        UserDataProfileNotifier profileNotifier = Provider.of<UserDataProfileNotifier>(context,
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


  getMyPosts(PostNotifier postNotifier) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();
    print(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
    .collection("Posts")
    .where("uid" , isGreaterThanOrEqualTo: uid.toString()).where("createdAt")
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
  void dispose() {
    PostNotifier postsNotifier = Provider.of<PostNotifier>(context, listen: false);
    getMyPosts(postsNotifier);

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {


    final PostNotifier postsNotifier = Provider.of<PostNotifier>(context);
    var posts = postsNotifier.postList;


    JoinNotifier joinNotifier = Provider.of<JoinNotifier>(context,
        listen: false);

    var joins = joinNotifier.joineventList;





    UserDataProfileNotifier profileNotifier =
    Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;

    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;

    print(user.name);
    //  print(user.profilePhoto);

    // user.profilePhoto!=null?print("มีรูป"):print("ไม่มีรูป");

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
        MColors.primaryWhiteSmoke,
        null,
        true,
        <Widget>[

        ],
      ),

      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhiteSmoke,
      body: RefreshIndicator(
        onRefresh: () => () async {
          // await getMyPosts(postsNotifier);
          await getEvenReqPosts(joinNotifier);
          await getProfile(profileNotifier);
        }(),
        child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return progressIndicator(MColors.primaryPurple);
              break;
            case ConnectionState.done:
              return joins.isNotEmpty
                  ? noNotifications()
                  : notificationsScreen(joins);
              break;
            case ConnectionState.waiting:
              return progressIndicator(MColors.primaryPurple);
              break;
            default:
              return joins.isEmpty
                ? noNotifications()
                : notificationsScreen(joins);
              break;

          }

        }
         ),
      ),
    );


    // return  StreamBuilder(
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.active:
    //         return progressIndicator(MColors.primaryPurple);
    //         break;
    //       case ConnectionState.done:
    //         return joins.isEmpty
    //             ? noNotifications()
    //             : notificationsScreen(nots);
    //         break;
    //       case ConnectionState.waiting:
    //         return progressIndicator(MColors.primaryPurple);
    //         break;
    //       default:
    //         return progressIndicator(MColors.primaryPurple);
    //
    //     }
    //     return Scaffold(
    //       appBar: primaryAppBar(
    //         null,
    //         Text(
    //           "Manager",
    //           textAlign: TextAlign.left,
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 22,
    //             letterSpacing: 0.27,
    //             color: MColors.primaryPurple,
    //           ),
    //           // style: boldFont(MColors.primaryPurple, 16.0),
    //         ),
    //         MColors.primaryWhiteSmoke,
    //         null,
    //         true,
    //         <Widget>[
    //
    //         ],
    //       ),
    //
    //       key: _scaffoldKey,
    //       backgroundColor: MColors.primaryWhiteSmoke,
    //       body: RefreshIndicator(
    //         onRefresh: () => () async {
    //           // await getMyPosts(postsNotifier);
    //           await getEvenReqPosts(joinNotifier);
    //           await getProfile(profileNotifier);
    //         }(),
    //         child: Container(
    //           child: ListView.builder(
    //             itemCount: joins.length,
    //             padding: const EdgeInsets.only(top: 8),
    //             scrollDirection: Axis.vertical,
    //             itemBuilder: (BuildContext context, int index) {
    //               return EventUserList(
    //                 joinEvent: joins[index],
    //               );
    //             },
    //           ),
    //         ),
    //       ),
    //
    //     );
    //   },
    // );

  }

   Widget notificationsScreen(joins){
     return Container(
       child: ListView.builder(
         itemCount: joins.length,
         padding: const EdgeInsets.only(top: 8),
         scrollDirection: Axis.vertical,
         itemBuilder: (BuildContext context, int index) {
           return EventUserList(
             joinEvent: joins[index],
           );
         },
       ),
     );
   }
   Widget noNotifications() {
     return emptyScreen(
       "assets/inbox.svg",
       "No Events Request",
       "Messages, promotions and general information from stores, pet news and the Pet Shop team will show up here.",
     );
   }
}
