import 'dart:collection';
import 'package:we_invited/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:we_invited/models/postrecom.dart';

class PostRrcomNotifier with ChangeNotifier {
  List<Postrecom> _postrecomList = [];
  Postrecom _currentPostRecom = Postrecom();

  UnmodifiableListView<Postrecom> get postrecomList => UnmodifiableListView(_postrecomList);

  Postrecom get currentPost => _currentPostRecom;

  set postrecomList(List<Postrecom> postrecomList) {
    _postrecomList = [];
    _postrecomList = postrecomList;
    notifyListeners();
  }

  set currentPost(Postrecom postrecom) {
    _currentPostRecom = postrecom;
    notifyListeners();
  }

  addPost(Postrecom postrecom) async {
    _postrecomList.insert(0, postrecom);
    notifyListeners();
  }

  deletePost(Postrecom postrecom) {
    _postrecomList.removeWhere((_postrecom) => _postrecom.postid == postrecom.postid);
    notifyListeners();
  }
}
