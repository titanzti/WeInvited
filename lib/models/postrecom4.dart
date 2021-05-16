import 'package:cloud_firestore/cloud_firestore.dart';

class Postrecom4 {
  String postid;
  String uid;
  String name;
  String place;
  Timestamp startdateTime;
  Timestamp entdateTime;
  Timestamp createdAt;
  Timestamp updatedAt;
  String image;
  String emailuser;
  String address;
  String description;
  String category;
  String gender;
  String postbyname;
  String postbyimage;
  String Numpeople;
  String agerange;
  int likes;

  Postrecom4(
      // {this.name,
      //   this.uid,
      //   this.postid,
      //   this.place,
      //   this.startdateTime,
      //   this.entdateTime,
      //   this.createdAt,
      //   this.updatedAt,
      //   this.image,
      //   this.emailuser,
      //   this.address,
      //   this.description,
      //
      // }
      );

  Postrecom4.fromMap(Map<String, dynamic> data) {
    name = data["name"] ?? '';
    uid = data["uid"] ?? '';
    postid = data["postid"] ?? '';
    place = data["place"] ?? '';
    createdAt = data["createdAt"];
    updatedAt = data["updatedAt"];
    image = data["image"] ?? '';
    startdateTime = data["startdateTime"];
    entdateTime = data["entdateTime"];
    emailuser = data["emailuser"] ?? '';
    address = data["address"] ?? '';
    description = data["description"] ?? '';
    category = data["category"] ?? '';
    gender = data["gender"] ?? '';
    postbyname = data["postbyname"] ?? '';
    postbyimage = data["postbyimage"] ?? '';
    Numpeople = data["Numpeople"] ?? '';
    agerange = data["agerange"] ?? '12-16';
    likes = data["likes"] ?? '';
  }
  Postrecom4.fromSnapshot(DocumentSnapshot snapshot) {
    name = snapshot["name"] ?? '';
    uid = snapshot["uid"] ?? '';
    postid = snapshot["postid"] ?? '';
    place = snapshot["place"] ?? '';
    createdAt = snapshot["createdAt"];
    updatedAt = snapshot["updatedAt"];
    image = snapshot["image"] ?? '';
    startdateTime = snapshot["startdateTime"];
    entdateTime = snapshot["entdateTime"];
    emailuser = snapshot["emailuser"] ?? '';
    address = snapshot["address"] ?? '';
    description = snapshot["description"] ?? '';
    category = snapshot["category"] ?? '';
    gender = snapshot["gender"] ?? '';
    postbyname = snapshot["postbyname"] ?? '';
    postbyimage = snapshot["postbyimage"] ?? '';
    Numpeople = snapshot["Numpeople"] ?? '';
    agerange = snapshot["agerange"] ?? '';
    likes = snapshot["likes"] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'postid': postid,
      'uid': uid,
      'name': name,
      'place': place,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'image': image,
      'startdateTime': startdateTime,
      'entdateTime': entdateTime,
      'emailuser': emailuser,
      'address': address,
      'description': description,
      'category': category,
      'gender': gender,
      'postbyname': postbyname,
      'postbyimage': postbyimage,
      'Numpeople': Numpeople,
      'agerange': agerange,
      'likes': likes,
    };
  }
}
