import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataProfile {
  String email;
  String name;
  String password;
  String gender;
  String age;
  String county;
  Timestamp birthday;
  String profilePhoto;
  String phone;

  UserDataProfile({
    this.email,
    this.name,
    this.password,
    this.gender,
    this.birthday,
    this.profilePhoto,
    this.county,
    this.age,
    this.phone,
  });

  UserDataProfile.fromMap(Map<String, dynamic> data) {
    email = data['email'];
    name = data['name'];
    password = data['password'];
    gender = data['gender'];
    county = data['county'];
    age = data['age'];
    birthday = data['birthDate'];
    profilePhoto = data['profilePhoto'];
    phone = data['phone'];
  }

  UserDataProfile.fromData(Map<String, dynamic> data)
      : email = data['email'],
        name = data['name'],
        password = data['password'],
        gender = data['gender'],
        county = data['county'],
        age = data['age'],
        birthday = data['birthDate'],
        phone = data['phone'],
        profilePhoto = data['profilePhoto'];

  static UserDataProfile fromMap1(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserDataProfile(
      email: map['email'],
      name: map['name'],
      password: map['password'],
      gender: map['gender'],
      county: map['email'],
      age: map['age'],
      birthday: map['birthDate'],
      profilePhoto: map['profilePhoto'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'gender': gender,
      'county': county,
      'age': age,
      'birthDate': birthday,
      'profilePhoto': profilePhoto,
      'phone': phone,
    };
  }
}
