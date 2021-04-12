



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/notifier/join_notifier.dart';
import 'package:we_invited/services/auth_service.dart';

getEvenReqPosts(JoinNotifier joinNotifier,String myuid) async {
  final uEmail = await AuthService().getCurrentEmail();
  final uid = await AuthService().getCurrentUID();
  print(uid);

  QuerySnapshot snapshot= await  FirebaseFirestore.instance
      .collection('JoinEvent')
      .doc(myuid)
      .collection('JoinEventList')
  // .where('receiverUidjoin',isEqualTo: myuid)
      .get();


  List<JoinEvent> _joinsList = [];

  snapshot.docs.forEach((document) {
    JoinEvent joinevent = JoinEvent.fromMap(document.data());
    _joinsList.add(joinevent);
  });

  joinNotifier.joineventList = _joinsList;
}