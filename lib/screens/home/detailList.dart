import 'package:flutter/material.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/post.dart';
import 'package:we_invited/models/user.dart';

class DetailList extends StatefulWidget {
  final Post postDetails ;
  final UserDataProfile userData;
  final JoinEvent joinEvent;
  DetailList(this.postDetails, this.userData, this.joinEvent);

  @override
  _DetailListState createState() => _DetailListState();
}

class _DetailListState extends State<DetailList> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
