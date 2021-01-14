// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_invited/models/post.dart';
// import 'package:we_invited/notifier/post_notifier.dart';
//
//
// final db = Firestore.instance;
//
// getPostFeed(PostNotifier postNotifier) async {
//   QuerySnapshot snapshot =
//   await Firestore.instance.collection("Post").getDocuments();
//
//   List<Post> _postList = [];
//
//   snapshot.documents.forEach((doc) {
//     Post posts = Post.fromMap(doc.data);
//
//     _postList.add(posts);
//   });
//
//   postNotifier.postList = _postList;
// }
