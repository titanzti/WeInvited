import 'package:cloud_firestore/cloud_firestore.dart';

class Userpro {
  final String uid;


  Userpro({this.uid});
}

class UserDataProfile {
  String email;
  String name;
  String password;
  String gender;
  String age;
  String county;
  String Birthday;
 String profilePhoto;

  UserDataProfile({
    this.email,
    this.name,
    this.password,
    this.gender,
    this.Birthday,
    this.profilePhoto,

  });

  UserDataProfile.fromMap(Map<String, dynamic> data) {
    email = data['email'];
    name = data['name'];
    password = data['password'];
    gender = data['gender'];
    county = data['county'];
    age = data['age'];
    Birthday = data['Birthday'];
    profilePhoto = data['profilePhoto'];


  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'gender': gender,
      'county': county,
      'age': age,
      'Birthday': Birthday,
      'profilePhoto': profilePhoto,
    };
  }

}
