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
        'https://firebasestorage.googleapis.com/v0/b/we-invited.appspot.com/o/placeholderperson.jpg?alt=media&token=832d9ccc-5027-4a0a-950a-14c46ec13905',
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

// Adding new address
storeAddress(
  fullLegalName,
  addressLocation,
  addressNumber,
) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();

  await db
      .collection("userData")
      .doc(uEmail)
      .collection("address")
      .doc(uEmail)
      .set({
    'fullLegalName': fullLegalName,
    'addressLocation': addressLocation,
    'addressNumber': addressNumber,
  }).catchError((e) {
    print(e);
  });
}

//get users address
// getAddress(UserDataAddressNotifier addressNotifier) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection("userData")
//       .doc(uEmail)
//       .collection("address")
//       .get();
//
//   List<UserDataAddress> _userDataAddressList = [];
//
//   snapshot.docs.forEach((doc) {
//     UserDataAddress userDataAddress = UserDataAddress.fromMap(doc.data());
//     _userDataAddressList.add(userDataAddress);
//   });
//
//   addressNotifier.userDataAddressList = _userDataAddressList;
// }

//Updating new address
updateAddress(
  fullLegalName,
  addressLocation,
  addressNumber,
) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();

  CollectionReference addressRef =
      db.collection("userData").doc(uEmail).collection("address");
  await addressRef.doc(uEmail).update(
    {
      'fullLegalName': fullLegalName,
      'addressLocation': addressLocation,
      'addressNumber': addressNumber,
    },
  );
}

//Adding new card
storeNewCard(
  cardHolder,
  cardNumber,
  validThrough,
  securityCode,
) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();

  await db
      .collection("userData")
      .doc(uEmail)
      .collection("card")
      .doc(uEmail)
      .set({
    'cardHolder': cardHolder,
    'cardNumber': cardNumber,
    'validThrough': validThrough,
    'securityCode': securityCode,
  }).catchError((e) {
    print(e);
  });
}

//get users card
// getCard(UserDataCardNotifier cardNotifier) async {
//   final uEmail = await AuthService().getCurrentEmail();
//
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection("userData")
//       .doc(uEmail)
//       .collection("card")
//       .get();
//
//   List<UserDataCard> _userDataCardList = [];
//
//   snapshot.docs.forEach((doc) {
//     UserDataCard userDataCard = UserDataCard.fromMap(doc.data());
//     _userDataCardList.add(userDataCard);
//   });
//
//   cardNotifier.userDataCardList = _userDataCardList;
// }

//Updating new card
updateCard(
  cardHolder,
  cardNumber,
  validThrough,
  securityCode,
) async {
  final db = FirebaseFirestore.instance;
  final uEmail = await AuthService().getCurrentEmail();

  CollectionReference cardRef =
      db.collection("userData").doc(uEmail).collection("card");
  await cardRef.doc(uEmail).update(
    {
      'cardHolder': cardHolder,
      'cardNumber': cardNumber,
      'validThrough': validThrough,
      'securityCode': securityCode,
    },
  );
}

saveDeviceToken() async {
  final db = FirebaseFirestore.instance;
  final _fcm = FirebaseMessaging();

  final uEmail = await AuthService().getCurrentEmail();

  //Getting device token
  String fcmToken = await _fcm.getToken();

  //Storing token
  if (fcmToken != null) {
    await db.collection("userToken").doc(uEmail).set({
      'userEmail': uEmail,
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }
}
