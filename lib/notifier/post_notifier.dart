import 'dart:collection';
import 'package:we_invited/models/post.dart';
import 'package:flutter/foundation.dart';

class PostNotifier with ChangeNotifier {
  List<Post> _postList = [];
  Post _currentPost = Post();

  UnmodifiableListView<Post> get postList => UnmodifiableListView(_postList);

  Post get currentPost => _currentPost;

  set postList(List<Post> postList) {
    _postList = [];
    _postList = postList;
    notifyListeners();
  }

  set currentPost(Post post) {
    _currentPost = post;
    notifyListeners();
  }

  addPost(Post post) async {
    _postList.insert(0, post);
    notifyListeners();
  }

  deletePost(Post post) {
    _postList.removeWhere((_post) => _post.postid == post.postid);
    notifyListeners();
  }
}
