import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_invited/models/bannerAds.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/postrecom.dart';
import 'package:we_invited/models/postrecom1.dart';
import 'package:we_invited/models/postrecom2.dart';
import 'package:we_invited/models/postrecom3.dart';
import 'package:we_invited/models/postrecom4.dart';
import 'package:we_invited/notifier/bannerAd_notifier.dart';
import 'package:we_invited/notifier/postRecom_notifier.dart';
import 'package:we_invited/notifier/postRecom1_notifier.dart';
import 'package:we_invited/notifier/postRecom2_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';

final db = FirebaseFirestore.instance;

///////getPosts
getPosts(PostNotifier postNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('ALL')
      .collection("PostsList")
      // .orderBy("likes", descending: true)
      .get();
  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

///getPosts ที่likeเยอะอยู่ต้นๆ
getPostsPop(PostNotifier postNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc("ALL")
      .collection('PostsList')
      .orderBy("likes", descending: true)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

getPostsRecom(
    PostRrcomNotifier postsrecomNotifier
    // ,totalcategoryFood
    // ,totalcategoryHealth
    ,
    interest

//    ,totalcategoryGames
//  ,totalcategoryBusiness
//  ,totalcategoryEducation
//  ,totalcategoryParty
//  ,totalcategoryNature
// ,totalcategoryOther
// ,totalcategoryShopping
// ,totalcategorySport
    ) async {
  print('totalcategoryFood>totalcategoryHealth');
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('$interest')
      .collection("PostsList")
      .limit(1)
      .orderBy("likes", descending: true)

      // .doc('Health').collection("PostsList")
      //  .where('category',isEqualTo: 'Health')
      // .orderBy("likes", descending: true)
      .get();

  List<Postrecom> _postsrecomList = [];

  snapshot.docs.forEach((document) {
    Postrecom postsrecom = Postrecom.fromMap(document.data());
    _postsrecomList.add(postsrecom);
  });

  postsrecomNotifier.postrecomList = _postsrecomList;
}

getPostsRecom1(
    PostRrcomNotifier1 postsrecom1Notifier
    // ,totalcategoryFood
    // ,totalcategoryHealth
    ,
    interest
//    ,totalcategoryGames
//  ,totalcategoryBusiness
//  ,totalcategoryEducation
//  ,totalcategoryParty
//  ,totalcategoryNature
// ,totalcategoryOther
// ,totalcategoryShopping
// ,totalcategorySport
    ) async {
  print('totalcategoryFood>totalcategoryHealth');
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('$interest')
      .collection("PostsList")
      .limit(1)
      .orderBy("likes", descending: true)

      // .doc('Health').collection("PostsList")
      //  .where('category',isEqualTo: 'Health')
      // .orderBy("likes", descending: true)
      .get();

  List<Postrecom1> _postsrecom1List = [];

  snapshot.docs.forEach((document) {
    Postrecom1 postsrecom1 = Postrecom1.fromMap(document.data());
    _postsrecom1List.add(postsrecom1);
  });

  postsrecom1Notifier.postrecomList1 = _postsrecom1List;
}

getPostsRecom2(PostRrcomNotifier2 postsrecom2Notifier, interest) async {
  print('totalcategoryFood>totalcategoryHealth');
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('$interest')
      .collection("PostsList")
      .limit(1)
      .orderBy("likes", descending: true)

      // .doc('Health').collection("PostsList")
      //  .where('category',isEqualTo: 'Health')
      // .orderBy("likes", descending: true)
      .get();

  List<Postrecom2> _postsrecom2List = [];

  snapshot.docs.forEach((document) {
    Postrecom2 postsrecom2 = Postrecom2.fromMap(document.data());
    _postsrecom2List.add(postsrecom2);
  });

  postsrecom2Notifier.postrecomList2 = _postsrecom2List;
// if(totalcategoryFood<totalcategoryHealth){
}

getPostsRecom3(PostRrcomNotifier3 postsrecom3Notifier, interest) async {
  print('totalcategoryFood>totalcategoryHealth');
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('$interest')
      .collection("PostsList")
      .limit(1)
      .orderBy("likes", descending: true)

      // .doc('Health').collection("PostsList")
      //  .where('category',isEqualTo: 'Health')
      // .orderBy("likes", descending: true)
      .get();

  List<Postrecom3> _postsrecom3List = [];

  snapshot.docs.forEach((document) {
    Postrecom3 postsrecom2 = Postrecom3.fromMap(document.data());
    _postsrecom3List.add(postsrecom2);
  });

  postsrecom3Notifier.postrecomList3 = _postsrecom3List;
// if(totalcategoryFood<totalcategoryHealth){
}

getPostsRecom4(PostRrcomNotifier4 postsrecom4Notifier, interest) async {
  print('totalcategoryFood>totalcategoryHealth');
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc('$interest')
      .collection("PostsList")
      .limit(1)
      .orderBy("likes", descending: true)

      // .doc('Health').collection("PostsList")
      //  .where('category',isEqualTo: 'Health')
      // .orderBy("likes", descending: true)
      .get();

  List<Postrecom4> _postsrecom4List = [];

  snapshot.docs.forEach((document) {
    Postrecom4 postsrecom4 = Postrecom4.fromMap(document.data());
    _postsrecom4List.add(postsrecom4);
  });

  postsrecom4Notifier.postrecomList4 = _postsrecom4List;
// if(totalcategoryFood<totalcategoryHealth){
}

//getOtherPosts คนอื่น จากuid
getOtherPosts(PostNotifier postNotifier, myuid) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc("ALL")
      .collection('PostsList')
      .where('uid', isEqualTo: myuid)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

//getPostswithcategory จาก หัวข้อ
getPostswithcategory(PostNotifier postNotifier, _title) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .doc(_title)
      .collection('PostsList')
      // .where('category', isEqualTo: _title)
      // .orderBy("createdAt", descending: true)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

getBannerAds(BannerAdNotifier bannerAdNotifier) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("bannerAds").get();

  List<BannerAds> _bannerAdsList = [];

  snapshot.docs.forEach((document) {
    BannerAds bannerAds = BannerAds.fromMap(document.data());
    _bannerAdsList.add(bannerAds);
  });

  bannerAdNotifier.bannerAdsList = _bannerAdsList;
}
