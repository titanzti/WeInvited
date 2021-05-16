import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Checking if user is signed in
  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
      );

  //Get UID
  Future<String> getCurrentUID() async {
    return (_firebaseAuth.currentUser).uid;
  }

  //Get Email
  Future<String> getCurrentEmail() async {
    return (_firebaseAuth.currentUser).email;
  }

  //Get Current user
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  //Email and Pasword Sign Up Firebase
  Future<String> createUserWithEmailAndPassword(
    email,
    password,
  ) async {
    final User currentUser =
        (await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
            .user;

    await currentUser.reload();
    return currentUser.uid;
  }

  //Email and Password Sign in Firebase
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    getCurrentUser();
    return ((await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
            .user)
        .uid;
  }

  //Sign Out
  signOut() {
    return FirebaseAuth.instance.signOut();
  }

  //Reset password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/user.birthday.read	',
  ],
);
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<String> signupWithGoogle() async {
  /////////Login with Google

  print('signupWithGoogle');

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User user1 = _auth.currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  DateTime currentPhoneDate = DateTime.now(); //DateTime

  Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);

  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication.catchError((onError) {
    print("error $onError");
  });

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential).catchError((onError) {
    print("error $onError");
  });

  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    String _token = "token";

    _fcm.getToken().then((String token) {
      _token = '$token';

      // setState(() {
      //   _token='$token';
      // });
      assert(token != null);
      print("Token : $token");
    });
/////////setข้อมูลลงfirebase
    FirebaseFirestore.instance
        .collection("userData")
        .doc(user.email)
        .get()
        .then((value) {
      if (value.data != null) {
        FirebaseFirestore.instance
            .collection("userData")
            .doc(user.email)
            .collection("profile")
            .doc(user.email)
            .set({
          'name': user.displayName,
          'profilePhoto': user.photoURL,
          'email': user.email,
          'birthDate': myTimeStamp,
          'age': 'กรุณาใส่อายุ',
          'phone': 'Example XX XXXX-XXXX',
          // 'gender': getGender(),
        }).catchError((e) {
          print(e);
        });
//set token ลงfirebase
        FirebaseFirestore.instance
            .collection("userData")
            .doc(user.email)
            .collection('tokens')
            .doc(_token)
            .set({
          'token': _token,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((e) {
          print(e);
        });
//set interest
        FirebaseFirestore.instance
            .collection("interest")
            .doc(user.email)
            .collection('like')
            .doc(user.email)
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
      }
      // getCurrentUser();
      print('signInWithGoogle succeeded: $user');
    });
    return '$user1';
  }

  return null;
}

//////////////signInWithGoogle
Future<String> signInWithGoogleV1() async {
  print('signInWithGoogle');

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User user1 = _auth.currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication.catchError((onError) {
    print("error $onError");
  });

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential).catchError((onError) {
    print("error $onError");
  });

  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    String _token = "token";

    _fcm.getToken().then((String token) {
      _token = '$token';

      // setState(() {
      //   _token='$token';
      // });
      assert(token != null);
      print("Token : $token");
    });

    FirebaseFirestore.instance
        .collection("userData")
        .doc(user.email)
        .get()
        .then((value) {
      if (value.data != null) {
        FirebaseFirestore.instance
            .collection("userData")
            .doc(user.email)
            .collection('tokens')
            .doc(_token)
            .update({
          'token': _token,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((e) {
          print(e);
        });
      }

      // getCurrentUser();
      print('signInWithGoogle succeeded: $user');
    });

    return '$user1';
  }

  return null;
}

// Future<String> getGender() async {
//   print('getGender');
//   final headers = await googleSignIn.currentUser.authHeaders;
//   final r = await http.get(
//       "https://people.googleapis.com/v1/people/me?personFields=genders&key=",
//       headers: {"Authorization": headers["Authorization"]});

//   final response = jsonDecode(r.body);
//   return response["genders"][0]["formattedValue"];
// }

// Future<User> updateToken() async {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseMessaging _fcm = FirebaseMessaging();
//   final User user = _auth.currentUser;
//   String _token = "token";

//   _fcm.getToken().then((String token) {
//     _token = '$token';

//     // setState(() {
//     //   _token='$token';
//     // });
//     assert(token != null);
//     print("Token : $token");
//   });

//   if (user != null) {
//     FirebaseFirestore.instance
//         .collection("userData")
//         .doc(user.email)
//         .get()
//         .then((value) {
//       if (value.data != null) {
//         FirebaseFirestore.instance
//             .collection("userData")
//             .doc(user.email)
//             .collection('tokens')
//             .doc(_token)
//             .set({
//           'token': _token,
//           'createdAt': FieldValue.serverTimestamp(),
//         }).catchError((e) {
//           print(e);
//         });
//       } else {
//         FirebaseFirestore.instance
//             .collection("userData")
//             .doc(user.email)
//             .collection('tokens')
//             .doc(_token)
//             .update({
//           'token': _token,
//           'createdAt': FieldValue.serverTimestamp(),
//         }).catchError((e) {
//           print(e);
//         });
//       }
//     });
//   }
//   return user;
// }

Future<User> updateToken() async {
  print('getCurrentUser');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  final User user = _auth.currentUser;
  String _token = "token";

  _fcm.getToken().then((String token) {
    _token = '$token';

    // setState(() {
    //   _token='$token';
    // });
    assert(token != null);
    print("Token : $token");
  });

  if (user != null) {
    FirebaseFirestore.instance
        .collection("userData")
        .doc(user.email)
        .get()
        .then((value) {
      if (value.data != null) {
        // FirebaseFirestore.instance
        //     .collection("userData")
        //     .doc(user.email)
        //     .collection("profile")
        //     .doc(user.email)
        //     .set({
        //   'name': user.displayName,
        //   'profilePhoto': user.photoURL,
        //   'email': user.email,
        // }).catchError((e) {
        //   print(e);
        // });

        FirebaseFirestore.instance
            .collection("userData")
            .doc(user.email)
            .collection('tokens')
            .doc(_token)
            .set({
          'token': _token,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((e) {
          print(e);
        });
      }
    });
    return user;
  }
  return null;
}

//signOutGoogle
void signOutGoogle(_tokens) async {
  final uEmail = await AuthService().getCurrentEmail();

  await FirebaseFirestore.instance
      .collection("userData")
      .doc(uEmail)
      .collection('tokens')
      .doc(_tokens)
      .delete();
  await googleSignIn.signOut();
  await _auth.signOut();
  print("User Signed Out");
}

// void signOutGoogleV1() async {
//   await googleSignIn.signOut();
//   await _auth.signOut();
//   print("User Signed Out");
// }
