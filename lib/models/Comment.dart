import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String commentid;
  String commentbyname;

  Timestamp createdAt;
  String mesg;
  String commentbyprofilePhoto;

  Comment({
    this.commentid,
    this.commentbyname,
    this.createdAt,
    this.mesg,
    this.commentbyprofilePhoto,

  });

  Comment.fromMap(Map<String, dynamic> data) {
    commentid = data['commentid'];
    commentbyname = data['commentbyname'];
    createdAt = data['createdAt'];
    mesg = data['mesg'];
    commentbyprofilePhoto = data['commentbyprofilePhoto'];
  }

  Comment.fromData(Map<String, dynamic> data)
      : commentid = data['commentid'],
        commentbyname = data['commentbyname'],
        createdAt = data['createdAt'],
        mesg = data['mesg'],
        commentbyprofilePhoto = data['commentbyprofilePhoto'];


  Map<String, dynamic> toMap() {
    return {
      'commentid': commentid,
      'commentbyname': commentbyname,
      'createdAt': createdAt,
      'mesg': mesg,
      'commentbyprofilePhoto': commentbyprofilePhoto,
    };
  }
}
