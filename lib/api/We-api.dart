// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;
// import 'package:we_invited/models/place.dart';
// import 'package:we_invited/models/wiggle.dart';
// import 'package:we_invited/notifier/auth_notifier.dart';
// import 'package:we_invited/notifier/post_notifier.dart';
// import 'package:uuid/uuid.dart';
// import 'package:we_invited/models/post.dart';
// import 'package:we_invited/models/user.dart';
// import 'package:flutter/services.dart';
//
// class API {
//   final String uid;
//   DateTime _date = DateTime.now();
//
//   API({this.uid});
//   // Stream<UserData> get userData {
//   //
//   //   return wiggleCollection
//   //       .document(uid)
//   //       .snapshots()
//   //       .map(_userDataFromSnapshot);
//   // }
//
//
//   //userData from snapshot
//   // UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
//   //   return UserData(
//   //       email: snapshot.data['email'],
//   //       bio: snapshot.data['bio'],
//   //       name: snapshot.data['name'],
//   //       gender: snapshot.data['gender'],
//   //       dp: snapshot.data['dp']);
//   // }
//   //
//   //
//   //
//   // List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
//   //   return snapshot.documents.map((doc) {
//   //     return Post(
//   //         postid : doc.data ['postid'] ?? '',
//   //         uid : doc.data ['uid'] ?? '',
//   //         name :  doc.data ['name'] ?? '',
//   //         place :  doc.data ['place'] ?? '',
//   //         createdAt :  doc.data ['createdAt'] ?? '',
//   //         updatedAt :  doc.data ['updatedAt'] ??'',
//   //         image :  doc.data ['image']?? '',
//   //         startdateTime :  doc.data['startdateTime'] ?? '',
//   //         entdateTime :  doc.data['entdateTime'] ?? '',
//   //         emailuser :  doc.data['emailuser'] ?? '');
//   //     }).toList();
//   // }
//   //
//   // Stream<List<Post>> get posts {
//   //   return wiggleCollection.snapshots().map(_postListFromSnapshot);
//   // }
//
// }
//
//
// class PlacePlugin {
//
//   static const MethodChannel _channel = const MethodChannel('place_plugin');
//
//   static void initailize(String apiKey) async {
//     await _channel.invokeMethod("initialize",<String,dynamic>{
//       'apikey':apiKey
//     });
//   }
//   static Future<List<Place>> search(String keyword) async {
//   var result = await _channel.invokeMethod("Search",<String,dynamic>{
//     'keyword' : keyword
//   });
//   if (result != null) {
//     return Place.fromNative(result);
//   }
//   return [];
//   }
//
//   static Future<Place> getPlace(Place place) async{
//     var result = await _channel.invokeMethod('getPlace',<String, dynamic>{
//       'placeId' : place.placeId,
//     });
//
//     if (result != null) {
//       place.lat = double.parse(result["latitude"].toString());
//       place.lng = double.parse(result["longitude"].toString());
//       place.formatedAddress = result['formattedAddress'];
//       return place;
//     }
//     return null;
//   }
// }
//
// const googlePlaceApikey = "AIzaSyD0CjdKW4QgE-RRkbw1Qgdz8OkkPjjcJos";
//
// class SearchBloc{
//   var _searchController = StreamController();
//   Stream get searchStrem => _searchController.stream;
//
//   SearchBloc(){
//     PlacePlugin.initailize(googlePlaceApikey);
//   }
//
//   void searchPlace(String keyword){
//     if (keyword.isEmpty) {
//       _searchController.sink.add("searching_"); // for loading indicator
//       PlacePlugin.search(keyword).then((result){
//         _searchController.sink.add(result);
//       }).catchError((e){
//
//       });
//     } else{
//       _searchController.add([]);
//     }
//   }
// }
//
//
//
//
//
//
// final CollectionReference wiggleCollection =
// Firestore.instance.collection('users');
//
//
// uploadPostAndImage(Post post, bool isUpdating, File localFile, Function foodUploaded) async {
//   if (localFile != null) {
//     print("uploading image");
//
//     var fileExtension = path.extension(localFile.path);
//     print(fileExtension);
//
//     var uuid = Uuid().v4();
//
//     final StorageReference firebaseStorageRef =
//     FirebaseStorage.instance.ref().child('foods/images/$uuid$fileExtension');
//
//     await firebaseStorageRef.putFile(localFile).onComplete.catchError((onError) {
//       print(onError);
//       return false;
//     });
//
//     String url = await firebaseStorageRef.getDownloadURL();
//     print("download url: $url");
//     _uploadPost(post, isUpdating, foodUploaded, imageUrl: url);
//   } else {
//     print('...skipping image upload');
//     _uploadPost(post, isUpdating, foodUploaded);
//   }
// }
//
// _uploadPost(Post post, bool isUpdating, Function foodUploaded, {String imageUrl}) async {
//   CollectionReference postRef = Firestore.instance.collection('Posts');
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   DateTime _date = DateTime.now();
//
//   final FirebaseUser user = await auth.currentUser;
//   final uid = user.uid;
//   final emailuser = user.email;
//
//
//
//   if (imageUrl != null) {
//     post.image = imageUrl;
//   }
//
//   if (isUpdating) {
//     post.updatedAt = Timestamp.now();
//
//     await postRef.document(post.postid).updateData(post.toMap());
//
//     foodUploaded(post);
//     print('updated food with id: ${post.postid}');
//   } else {
//     post.createdAt = Timestamp.now();
//
//     DocumentReference documentRef = await postRef.add(post.toMap());
//
//     post.postid = documentRef.documentID;
//     post.uid = uid;
//     post.emailuser = emailuser;
//     // post.startdateTime = _date;
//     print('uploaded food successfully: ${post.toString()}');
//
//     await documentRef.setData(post.toMap(), merge: true);
//
//     foodUploaded(post);
//   }
// }
//
// // _getPosts() async {
// //   return Firestore.instance
// //       .collection("Posts")
// //       .orderBy("createdAt", descending: true)
// //       .snapshots();
// //}
//
//
//
