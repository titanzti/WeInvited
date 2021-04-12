import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:we_invited/models/joinevent.dart';

class JoinNotifier with ChangeNotifier {
  List<JoinEvent> _joineventList = [];
  JoinEvent _currentjoinEvent = JoinEvent();

  UnmodifiableListView<JoinEvent> get joineventList => UnmodifiableListView(_joineventList);

  JoinEvent get currentJoinEvent=> _currentjoinEvent;

  set joineventList(List<JoinEvent> joinEventList) {
    _joineventList = [];
    _joineventList = joinEventList;
    notifyListeners();
  }

  set currentJoinEvent(JoinEvent joinevent) {
    _currentjoinEvent = joinevent;
    notifyListeners();
  }

  addJoinEvent(JoinEvent joinevent) async {
    _joineventList.insert(0, joinevent);
    notifyListeners();
  }

  deleteJoinEvent(JoinEvent joinevent) {
    _joineventList.removeWhere((_joinevent) => _joinevent.postid == joinevent.postid);
    notifyListeners();
  }
}
