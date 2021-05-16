import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:we_invited/models/TokenModel.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:intl/intl.dart';

///ฟังชั่นลงทะเบียนยูสเซอร์
storeNewUser(_name, _phone, _email, _gender, age, birthDate) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('userData');
  final FirebaseMessaging _fcm = FirebaseMessaging();
  DateTime tempDate = new DateFormat("dd-MMM-yyyy").parse(birthDate);

  var user = FirebaseAuth.instance.currentUser.displayName;
  user = _name;
  print(user);

  await db
      .collection("userData")
      .doc(uEmail)
      .collection("profile")
      .doc(uEmail)
      .set({
    'name': _name,
    'phone': _phone,
    'email': _email,
    'gender': 'กรุณาเลือกเพศ',
    'age': age,
    'birthDate': tempDate,
    'profilePhoto':
        'https://firebasestorage.googleapis.com/v0/b/we-invited.appspot.com/o/placeholderperson2.jpg?alt=media&token=a2dd3d04-9960-4aa1-a268-b8b93bd4af8c',
  }).catchError((e) {
    print(e);
  });
  FirebaseFirestore.instance
      .collection("interest")
      .doc(_email)
      .collection('like')
      .doc(_email)
      .set({
    'Business': 0,
    'Education': 0,
    'Food': 0,
    'Games': 0,
    'Health': 0,
    'Nature': 0,
    'Other': 0,
    'Shopping': 0,
    'Sport': 0,
    'Party': 0,
  }).catchError((e) {
    print(e);
  });
  try {
    var usersDocumentSnapshot = await _usersCollectionReference.get();
    String fcmToken = await _fcm.getToken();

    final tokenRef = _usersCollectionReference
        .doc(_email)
        .collection('tokens')
        .doc(fcmToken);
    await tokenRef.set(
      TokenModel(token: fcmToken, createdAt: FieldValue.serverTimestamp())
          .toJson(),
    );
    if (usersDocumentSnapshot.docs.isNotEmpty) {
      return usersDocumentSnapshot.docs
          .map((snapshot) => UserDataProfile.fromMap1(snapshot.data()))
          .where((mappedItem) => mappedItem.email != _email)
          .toList();
    }
  } catch (e) {
    // TODO: Find or create a way to repeat error handling without so much repeated code
    if (e is PlatformException) {
      return e.message;
    }

    return e.toString();
  }
}

//โชว์โปรไฟล์ยูสเซอร์
getProfile(UserDataProfileNotifier profileNotifier) async {
  final uEmail = await AuthService().getCurrentEmail();

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("userData")
      .doc(uEmail)
      .collection("profile")
      .get();

  List<UserDataProfile> _userDataProfileList = [];

  snapshot.docs.forEach((doc) {
    UserDataProfile userDataProfile = UserDataProfile.fromMap(doc.data());
    _userDataProfileList.add(userDataProfile);
  });

  profileNotifier.userDataProfileList = _userDataProfileList;
}

//Updating User profile
updateProfile(_name, _gender) async {
  print("updateProfile");
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();

  CollectionReference profileRef =
      db.collection("userData").doc(uEmail).collection("profile");
  await profileRef.doc(uEmail).update(
    {
      'name': _name,
      'gender': _gender,
    },
  );
}

//Updating User whit photo profile
Future updateProfilePhoto(file) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();
  final udid = await AuthService().getCurrentUID();

  //Input the link to your own firebase storage bucket
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://we-invited.appspot.com');

  String filePath = 'userImages/$uEmail.png';

  StorageUploadTask uploadTask = _storage.ref().child(filePath).putFile(file);

  StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

  var ref = storageTaskSnapshot.ref;
  var profilePhoto = await ref.getDownloadURL();

  print(profilePhoto);

  CollectionReference profileRef =
      db.collection("userData").doc(uEmail).collection("profile");
  await profileRef.doc(uEmail).update(
    {
      'profilePhoto': profilePhoto,
    },
  );

  CollectionReference profileRef1 = db.collection("Posts");

  await profileRef1.doc(udid).update({
    'postbyimage': profilePhoto,
  });
}
