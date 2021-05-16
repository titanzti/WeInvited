import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:we_invited/models/postrecom2.dart';
import 'package:we_invited/models/postrecom3.dart';
import 'package:we_invited/models/postrecom4.dart';

class PostRrcomNotifier2 with ChangeNotifier {
  List<Postrecom2> _postrecom2List = [];
  Postrecom2 _currentPostRecom2 = Postrecom2();

  UnmodifiableListView<Postrecom2> get postrecomList2 => UnmodifiableListView(_postrecom2List);

  Postrecom2 get currentPost => _currentPostRecom2;

  set postrecomList2(List<Postrecom2> postrecomList2) {
    _postrecom2List = [];
    _postrecom2List = postrecomList2;
    notifyListeners();
  }

  set currentPost(Postrecom2 postrecom2) {
    _currentPostRecom2 = postrecom2;
    notifyListeners();
  }

  addPost(Postrecom2 postrecom2) async {
    _postrecom2List.insert(0, postrecom2);
    notifyListeners();
  }

  deletePost(Postrecom2 postrecom2) {
    _postrecom2List.removeWhere((_postrecom2) => _postrecom2.postid == postrecom2.postid);
    notifyListeners();
  }
}





class PostRrcomNotifier3 with ChangeNotifier {
  List<Postrecom3> _postrecom3List = [];
  Postrecom3 _currentPostRecom3 = Postrecom3();

  UnmodifiableListView<Postrecom3> get postrecomList3 => UnmodifiableListView(_postrecom3List);

  Postrecom3 get currentPost => _currentPostRecom3;

  set postrecomList3(List<Postrecom3> postrecomList3) {
    _postrecom3List = [];
    _postrecom3List = postrecomList3;
    notifyListeners();
  }

  set currentPost(Postrecom3 postrecom3) {
    _currentPostRecom3 = postrecom3;
    notifyListeners();
  }

  addPost(Postrecom3 postrecom3) async {
    _postrecom3List.insert(0, postrecom3);
    notifyListeners();
  }

  deletePost(Postrecom3 postrecom3) {
    _postrecom3List.removeWhere((_postrecom3) => _postrecom3.postid == postrecom3.postid);
    notifyListeners();
  }
}

class PostRrcomNotifier4 with ChangeNotifier {
  List<Postrecom4> _postrecom4List = [];
  Postrecom4 _currentPostRecom4= Postrecom4();

  UnmodifiableListView<Postrecom4> get postrecomList4 => UnmodifiableListView(_postrecom4List);

  Postrecom4 get currentPost => _currentPostRecom4;

  set postrecomList4(List<Postrecom4> postrecomList4) {
    _postrecom4List = [];
    _postrecom4List = postrecomList4 ;
    notifyListeners();
  }

  set currentPost(Postrecom4 postrecom4) {
    _currentPostRecom4 = postrecom4;
    notifyListeners();
  }

  addPost(Postrecom4 postrecom4) async {
    _postrecom4List.insert(0, postrecom4);
    notifyListeners();
  }

  deletePost(Postrecom4 postrecom4) {
    _postrecom4List.removeWhere((_postrecom4) => postrecom4.postid == postrecom4.postid);
    notifyListeners();
  }
}