// import 'dart:collection';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_invited/models/post.dart';
// import 'package:we_invited/models/user.dart';
// import 'package:we_invited/shared/constant.dart';
// import 'package:we_invited/models/wiggle.dart';
// import 'dart:io';
//
// class DatabaseService {
//   final String uid;
//
//   DatabaseService({this.uid});
//
//   getUserByUsername(String name) async {
//     return Firestore.instance
//         .collection('users')
//         .where("name", isGreaterThanOrEqualTo: name)
//         .getDocuments();
//   }
//
//   getUserByUserEmail(String email) async {
//     return Firestore.instance
//         .collection('users')
//         .where("email", isEqualTo: email)
//         .getDocuments();
//   }
//
//   //collection reference
//   final CollectionReference wiggleCollection =
//   Firestore.instance.collection('users');
//   final postReference = Firestore.instance.collection('Posts');
//
//   Future<void> addData(blogData, String description) async {
//     Firestore.instance
//         .collection("blogs")
//         .document('$description')
//         .setData(blogData)
//         .catchError((e) {
//       print(e);
//     });
//   }
//
//
//
//   Future uploadUserData(
//       String email,
//       String name,
//       String gender,
//       String bio,
//       String dp,
//       String media,
//  ) async {
//
//     return await wiggleCollection.document(uid).setData({
//       "email": email,
//       "name": name,
//       "gender": gender,
//       "bio": bio,
//       "dp": dp,
//       'anonBio': '',
//       'anonInterest': '',
//       'anonDp': '',
//       'id': uid,
//       'fame': 0,
//       'media': media,
//
//     });
//   }
//
//   Future updateAnonymous(bool isAnonymous) async {
//     return await wiggleCollection
//         .document(uid)
//         .updateData({"isAnonymous": isAnonymous});
//   }
//
//   Future updateAnonData(String anonBio, String anonInterest, String anonDp,
//       String nickname) async {
//     return await wiggleCollection.document(uid).updateData({
//       'anonBio': anonBio,
//       'anonInterest': anonInterest,
//       'anonDp': anonDp,
//       'nickname': nickname
//     });
//   }
//
//   Future increaseFame(
//       int initialvalue, String raterEmail, bool isAdditional) async {
//     if (isAdditional) {
//       await wiggleCollection
//           .document(uid)
//           .collection('likes')
//           .document(raterEmail)
//           .setData({'like': raterEmail});
//     }
//     return await wiggleCollection
//         .document(uid)
//         .updateData({'fame': initialvalue + 1});
//   }
//
//   Future likepost(int initialvalue, String postId, String userEmail) async {
//     await Firestore.instance
//         .collection("posts")
//         .document(postId)
//         .collection('likes')
//         .document(userEmail)
//         .setData({'liked': userEmail});
//
//     return await Firestore.instance
//         .collection("posts")
//         .document(postId)
//         .updateData({'likes': initialvalue + 1});
//   }
//
//   Future unlikepost(int initialvalue, String postId, String userEmail) async {
//     await Firestore.instance
//         .collection("posts")
//         .document(postId)
//         .collection('likes')
//         .document(userEmail)
//         .delete();
//
//     return await Firestore.instance
//         .collection("posts")
//         .document(postId)
//         .updateData({'likes': initialvalue - 1});
//   }
//
//   Future decreaseFame(
//       int initialvalue, String raterEmail, bool isAdditional) async {
//     if (isAdditional) {
//       await wiggleCollection
//           .document(uid)
//           .collection('dislikes')
//           .document(raterEmail)
//           .setData({'dislike': raterEmail});
//     }
//     return await wiggleCollection
//         .document(uid)
//         .updateData({'fame': initialvalue - 1});
//   }
//
//   Future updateUserData(
//       String email,
//       String name,
//       String gender,
//       String block,
//       String bio,
//       String dp,
//
//
//       ) async {
//     return await wiggleCollection.document(uid).updateData({
//       "email": email,
//       "name": name,
//       "gender": gender,
//       "block": block,
//       "bio": bio,
//       "dp": dp,
//       'id': uid,
//
//     });
//   }
//
//   //wiggle list from snapshot
//   List<Wiggle> _wiggleListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.documents.map((doc) {
//       return Wiggle(
//           id: doc.data['id'] ?? '',
//           email: doc.data['email'] ?? '',
//           dp: doc.data['dp'] ?? '',
//           name: doc.data['name'] ?? '',
//           startdateTime: doc.data['startdateTime'],
//           bio: doc.data['bio'] ?? '',
//           community: doc.data['community'] ?? '',
//           gender: doc.data['gender'] ?? '',
//           fame: doc.data['fame'] ?? 0,
//           media: doc.data['media'] ?? '');
//
//     }).toList();
//   }
//
//   //get wiggle stream
//   Stream<List<Wiggle>> get wiggles {
//     return wiggleCollection.snapshots().map(_wiggleListFromSnapshot);
//   }
//
//   List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.documents.map((doc) {
//       return Post(
//           postid : doc.data ['postid'] ?? '',
//           uid : doc.data ['uid'] ?? '',
//           name :  doc.data ['name'] ?? '',
//           place :  doc.data ['place'] ?? '',
//           createdAt :  doc.data ['createdAt'] ?? '',
//           updatedAt :  doc.data ['updatedAt'] ??'',
//           image :  doc.data ['image']?? '',
//           startdateTime :  doc.data['startdateTime'] ?? '',
//           entdateTime :  doc.data['entdateTime'] ?? '',
//           description :  doc.data['description'] ?? '',
//           emailuser :  doc.data['emailuser'] ?? '');
//
//     }).toList();
//   }
//
//   Stream<List<Post>> get posts {
//     return wiggleCollection.snapshots().map(_postListFromSnapshot);
//   }
//
//
//
//
//
//   //userData from snapshot
//   UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
//     return UserData(
//         email: snapshot.data['email'],
//         bio: snapshot.data['bio'],
//         name: snapshot.data['name'],
//         gender: snapshot.data['gender'],
//         dp: snapshot.data['dp'],
//         fame: snapshot.data['fame'] ?? 0,
//         media: snapshot.data['media'] ?? '');
//   }
//
//
//
//   //get user doc stream
//   Stream<UserData> get userData {
//     return wiggleCollection
//         .document(uid)
//         .snapshots()
//         .map(_userDataFromSnapshot);
//   }
//
//
//   getPosts() async {
//     return Firestore.instance
//         .collection("Posts")
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//
//   Stream<QuerySnapshot> getphotos() {
//     return wiggleCollection.document(uid).collection('photos').snapshots();
//   }
// }
//
