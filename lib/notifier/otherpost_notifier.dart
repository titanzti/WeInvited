import 'dart:collection';
import 'package:we_invited/models/post.dart';
import 'package:flutter/foundation.dart';

class OtherPostNotifier with ChangeNotifier {
  List<Post> _otherpostList = [];
  Post _currentOtherPost = Post();

  UnmodifiableListView<Post> get otherpostList =>
      UnmodifiableListView(_otherpostList);

  Post get currentOtherPost => _currentOtherPost;

  set otherpostList(List<Post> otherpostList) {
    _otherpostList = [];
    _otherpostList = otherpostList;
    notifyListeners();
  }

  set currentOtherPost(Post otherpost) {
    _currentOtherPost = otherpost;
    notifyListeners();
  }

  addOtherPost(Post otherpost) async {
    _otherpostList.insert(0, otherpost);
    notifyListeners();
  }

  deleteOtherPost(Post otherpost) {
    _otherpostList
        .removeWhere((_otherpost) => _otherpost.postid == otherpost.postid);
    notifyListeners();
  }
}
