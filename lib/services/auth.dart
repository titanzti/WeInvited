// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:we_invited/models/user.dart';
// import 'package:we_invited/services/database.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   User _userFromFirebaseuser(FirebaseUser user) {
//     return user != null ? User(uid: user.uid) : null;
//   }
//   //auth change user stream
//   Stream<User> get user {
//     return _auth.onAuthStateChanged.map(_userFromFirebaseuser);
//   }
//
//   Future signInWithEmailAndPassword(String email, String password) async {
//     try {
//       AuthResult result = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       FirebaseUser user = result.user;
//       return _userFromFirebaseuser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
//   //get the user
//   Future getUser() async {
//     var firebaseUser = await _auth.currentUser();
//     return User(uid: firebaseUser.uid);
//   }
//
//
//   // Future registerWithEmailAndPassword(String email, String password) async {
//   //   try {
//   //     AuthResult result = await _auth.createUserWithEmailAndPassword(
//   //         email: email, password: password);
//   //     FirebaseUser user = result.user;
//   //     return _userFromFirebaseuser(user);
//   //   } catch (e) {
//   //     print(e.toString());
//   //     return null;
//   //   }
//   // }
//
//   Future signInAnon() async {
//     try {
//       AuthResult result = await _auth.signInAnonymously();
//       FirebaseUser user = result.user;
//       return _userFromFirebaseuser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
//   Future registerWithEmailAndPassword(
//   String email,
//       String password,
//       String name,
//   String gender,
//   String bio,
//   String dp,
//   String media) async{
//   try {
//     AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//     FirebaseUser user = result.user;
//
//     await DatabaseService(uid: user.uid).uploadUserData(email, name, gender, bio, dp, media);
//     return _userFromFirebaseuser(user);
//   }catch(e){
//     print(e.toString());
//     return null;
//    }
//   }
//   //validate curren password
//   Future validatePassword(String password) async {
//     var baseUser = await _auth.currentUser();
//
//     // var authCrudentials = EmailAuthProvider.getCredential(
//     //     email: firebaseUser.email, password: password);
//     // print(authCrudentials);
//
//     try {
//       //sign in method is used instead of reauthenticate with credential because
//       //it was buggy
//       var firebaseUser = await _auth.signInWithEmailAndPassword(
//           email: baseUser.email, password: password);
//       return firebaseUser != null;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }
//
//   Future<void> updatePassword(String password) async {
//     var firebaseUser = await _auth.currentUser();
//     firebaseUser.updatePassword(password);
//   }
//
//   //sign out
//   Future signOut() async {
//     try {
//       return await _auth.signOut();
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
//
// }
