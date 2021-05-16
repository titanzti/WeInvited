import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:we_invited/models/postrecom1.dart';

class PostRrcomNotifier1 with ChangeNotifier {
  List<Postrecom1> _postrecom1List = [];
  Postrecom1 _currentPostRecom1 = Postrecom1();

  UnmodifiableListView<Postrecom1> get postrecomList1 => UnmodifiableListView(_postrecom1List);

  Postrecom1 get currentPost => _currentPostRecom1;

  set postrecomList1(List<Postrecom1> postrecomList1) {
    _postrecom1List = [];
    _postrecom1List = postrecomList1;
    notifyListeners();
  }

  set currentPost(Postrecom1 postrecom1) {
    _currentPostRecom1 = postrecom1;
    notifyListeners();
  }

  addPost(Postrecom1 postrecom1) async {
    _postrecom1List.insert(0, postrecom1);
    notifyListeners();
  }

  deletePost(Postrecom1 postrecom1) {
    _postrecom1List.removeWhere((_postrecom1) => _postrecom1.postid == postrecom1.postid);
    notifyListeners();
  }
}
