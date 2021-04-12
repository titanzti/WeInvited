import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:we_invited/models/bannerAds.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/bannerAd_notifier.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/notifier/otherpost_notifier.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:path/path.dart' as path;
import 'package:we_invited/services/user_management.dart';

final db = FirebaseFirestore.instance;

//
//Adding users' product to cart
addProductToCart(product) async {
  final uEmail = await AuthService().getCurrentEmail();

  await db
      .collection("userCart")
      .doc(uEmail)
      .collection("cartItems")
      .doc(product.productID)
      .set(product.toMap())
      .catchError((e) {
    print(e);
  });
}

///////ฟังชั่นโขว์โพส
getPosts(PostNotifier postNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .orderBy("createdAt", descending: true)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

getPostsPop(PostNotifier postNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .orderBy("likes", descending: true)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

getOtherPosts(PostNotifier postNotifier, myuid) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .where('uid', isEqualTo: myuid)
      .get();

  List<Post> _postsList = [];

  snapshot.docs.forEach((document) {
    Post posts = Post.fromMap(document.data());
    _postsList.add(posts);
  });

  postNotifier.postList = _postsList;
}

// getOtherPosts(OtherPostNotifier otherpostNotifier, myuid) async {
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection("Posts")
//       .where('uid', isEqualTo: myuid)
//       .orderBy("createdAt", descending: true)
//       .get();

//   List<Post> _otherpostList = [];

//   snapshot.docs.forEach((document) {
//     Post otherposts = Post.fromMap(document.data());
//     _otherpostList.add(otherposts);
//   });

//   otherpostNotifier.otherpostList = _otherpostList;
// }

getPosts1(PostNotifier postNotifier, String _title) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("Posts")
      .where('category', isEqualTo: _title)
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

// uploadPostAndImage(
//     Post post, bool isUpdating, File localFile, Function foodUploaded) async {
//   if (localFile != null) {
//     print("uploading image");
//
//     var fileExtension = path.extension(localFile.path);
//     print(fileExtension);
//
//     var uuid = Uuid().v4();
//
//     final StorageReference firebaseStorageRef = FirebaseStorage.instance
//         .ref()
//         .child('posts/images/$uuid$fileExtension');
//
//     await firebaseStorageRef
//         .putFile(localFile)
//         .onComplete
//         .catchError((onError) {
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
// _uploadPost(Post post, bool isUpdating, Function foodUploaded,
//     {String imageUrl}) async {
//   final db = FirebaseFirestore.instance;
//   final uEmail = await AuthService().getCurrentEmail();
//
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   // DateTime _date = DateTime.now();
//
//   // final User user = await auth.currentUser;
//   // final uid = user.uid;
//   // final emailuser = user.email;
//
//   if (imageUrl != null) {
//     post.image = imageUrl;
//   }
//
//   if (isUpdating) {
//     post.updatedAt = Timestamp.now();
//
//     // await db
//     //     .collection("Posts")
//     //     .doc(uEmail)
//     //     .collection("PostsItems")
//     //     .doc(post.postid)
//     //     .set(post.toMap())
//     //     .catchError((e) {
//     //   print(e);
//     // });
//     await db.doc(post.postid).update(post.toMap());
//
//     foodUploaded(post);
//     print('updated food with id: ${post.postid}');
//   } else {
//     // post.startdateTime = _date;
//     print('uploaded food successfully: ${post.toString()}');
//
//     foodUploaded(post);
//   }
// }
//

//Getting bannersAds
// getBannerAds(BannerAdNotifier bannerAdNotifier) async {
//   QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection("bannerAds").get();
//
//   List<BannerAds> _bannerAdsList = [];
//
//   snapshot.docs.forEach((document) {
//     BannerAds bannerAds = BannerAds.fromMap(document.data());
//     _bannerAdsList.add(bannerAds);
//   });
//
//   bannerAdNotifier.bannerAdsList = _bannerAdsList;
// }

//Getting users' cart
// getCart(CartNotifier cartNotifier) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection("userCart")
//       .doc(uEmail)
//       .collection("cartItems")
//       .get();
//
//   List<Cart> _cartList = [];
//
//   snapshot.docs.forEach((document) {
//     Cart cart = Cart.fromMap(document.data());
//     _cartList.add(cart);
//   });
//
//   cartNotifier.cartList = _cartList;
// }

//Adding item quantity, Price and updating data in cart
// addAndApdateData(cartItem) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   if (cartItem.quantity >= 9) {
//     cartItem.quantity = cartItem.quantity = 9;
//   } else {
//     cartItem.quantity = cartItem.quantity + 1;
//   }
//   cartItem.totalPrice = cartItem.price * cartItem.quantity;
//
//   CollectionReference cartRef =
//       db.collection("userCart").doc(uEmail).collection("cartItems");
//
//   await cartRef.doc(cartItem.productID).update(
//     {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
//   );
// }
//
// //Subtracting item quantity, Price and updating data in cart
// subAndApdateData(cartItem) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   if (cartItem.quantity <= 1) {
//     cartItem.quantity = cartItem.quantity = 1;
//   } else {
//     cartItem.quantity = cartItem.quantity - 1;
//   }
//   cartItem.totalPrice = cartItem.price * cartItem.quantity;
//
//   CollectionReference cartRef =
//       db.collection("userCart").doc(uEmail).collection("cartItems");
//
//   await cartRef.doc(cartItem.productID).update(
//     {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
//   );
// }
//
// //Removing item from cart
// removeItemFromCart(cartItem) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   await db
//       .collection("userCart")
//       .doc(uEmail)
//       .collection("cartItems")
//       .doc(cartItem.productID)
//       .delete();
// }
//
// //Clearing users' cart
// clearCartAfterPurchase() async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   await db
//       .collection('userCart')
//       .doc(uEmail)
//       .collection("cartItems")
//       .get()
//       .then((snapshot) {
//     for (DocumentSnapshot doc in snapshot.docs) {
//       doc.reference.delete();
//     }
//   });
// }
//
// //Adding users' product to cart
// addCartToOrders(cartList, orderID, addressList) async {
//   final uEmail = await AuthService().getCurrentEmail();
//   var orderDate = FieldValue.serverTimestamp();
//
//   var orderStatus = "processing";
//   var shippingAddress = addressList.first.addressNumber +
//       ", " +
//       addressList.first.addressLocation;
//
//   await db
//       .collection("userOrder")
//       .doc(uEmail)
//       .collection("orders")
//       .doc(orderID)
//       .set(
//     {
//       'orderID': orderID,
//       'orderDate': orderDate,
//       'orderStatus': orderStatus,
//       'shippingAddress': shippingAddress,
//       'order': cartList.map((i) => i.toMap()).toList(),
//     },
//   ).catchError((e) {
//     print(e);
//   });
//
//   //Sending orders to merchant
//   await db
//       .collection("merchantOrder")
//       .doc(uEmail)
//       .collection("orders")
//       .doc(orderID)
//       .set(
//     {
//       'orderID': orderID,
//       'orderDate': orderDate,
//       'shippingAddress': shippingAddress,
//       'order': cartList.map((i) => i.toMap()).toList(),
//     },
//   ).catchError((e) {
//     print(e);
//   });
// }
//
// //Getting users' orders
// getOrders(
//   OrderListNotifier orderListNotifier,
// ) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   QuerySnapshot ordersSnapshot =
//       await db.collection("userOrder").doc(uEmail).collection("orders").get();
//
//   List<OrdersList> _ordersListList = [];
//
//   ordersSnapshot.docs.forEach((document) {
//     OrdersList ordersList = OrdersList.fromMap(document.data());
//     _ordersListList.add(ordersList);
//   });
//   orderListNotifier.orderListList = _ordersListList;
// }
