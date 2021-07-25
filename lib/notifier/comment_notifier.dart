import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:we_invited/models/Comment.dart';

class CommentNotifier with ChangeNotifier {
  List<Comment> _commentList = [];
  Comment _currentcomment = Comment();

  UnmodifiableListView<Comment> get commentList => UnmodifiableListView(_commentList);

  Comment get currentcomment=> _currentcomment;

  set commentList(List<Comment> commentList) {
    _commentList = [];
    _commentList = commentList;
    notifyListeners();
  }

  set currentcomment(Comment comment) {
    _currentcomment = comment;
    notifyListeners();
  }

  addCommentEvent(Comment comment) async {
    _commentList.insert(0, comment);
    notifyListeners();
  }

  deleteJoinEvent(Comment comment) {
    _commentList.removeWhere((_commentList) => _commentList.commentid == comment.commentid);
    notifyListeners();
  }
}
