import 'package:cloud_firestore/cloud_firestore.dart';

class JoinEvent{
  String postid ;
  String joinid ;
  String ownerID;
  String ownerName;
  String senderAvatar;
  String senderName;
  String senderUid;
  String receiverUidjoin;
  String requestpostid;
  String senderEmail;
  String status;
  String type;
  Timestamp createdAt;
  String title;
  String receiveremail;




  JoinEvent(

      // this.requestpostid,

  );



  JoinEvent.fromMap(Map<String, dynamic> data) {
    postid = data["postid"] ?? '';
    joinid = data["joinid"] ?? '';
    ownerID = data["ownerID"] ?? '';
    ownerName = data["ownerName"] ?? '';
    senderAvatar = data["senderAvatar"] ?? '';
    senderName = data["senderName"] ?? '';
    senderUid = data["senderUid"] ?? '';
    receiverUidjoin = data["receiverUidjoin"] ?? '';
    requestpostid = data["requestpostid"] ?? '';
    senderEmail = data["senderEmail"] ?? '';
    status = data["status"] ?? '';
    createdAt = data["createdAt"];
    type = data["type"] ?? '';
    title = data["title"] ?? '';
    receiveremail = data["receiveremail"] ?? '';

  }

  Map<String, dynamic> toMap() {
    return{
      'postid' :postid,
      'joinid' :joinid,
      'ownerID' :ownerID,
      'ownerName' :ownerName,
      'senderAvatar' :senderAvatar,
      'senderName' :senderName,
      'senderUid' :senderUid,
      'receiverUidjoin' :receiverUidjoin,
      'requestpostid' :requestpostid,
      'senderEmail' :senderEmail,
      'status' :status,
      'createdAt' :createdAt,
      'type' :type,
      'title' :title,
      'receiveremail' :receiveremail,

    };
  }


}