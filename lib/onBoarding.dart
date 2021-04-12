import 'package:we_invited/screens/home/Homepages.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:we_invited/main.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final pageDecoration = PageDecoration(
    titleTextStyle:
        PageDecoration().titleTextStyle.copyWith(color: Colors.black),
    bodyTextStyle: PageDecoration().bodyTextStyle.copyWith(color: Colors.black),
    contentPadding: const EdgeInsets.all(10),
  );

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        image: Image.asset("assets/Welcome.png"),
        title: "Welcome to We Invited",
        body: "Meet all your friends in your community",
        decoration: PageDecoration(
          titleTextStyle:
              PageDecoration().titleTextStyle.copyWith(color: Colors.black),
          bodyTextStyle:
              PageDecoration().bodyTextStyle.copyWith(color: Colors.black),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
      PageViewModel(
        image: Image.asset("assets/Connect.png"),
        title: "Connect & Exchange",
        body: "Connect with friend & Exchange stories",
        decoration: PageDecoration(
          titleTextStyle:
              PageDecoration().titleTextStyle.copyWith(color: Colors.black),
          bodyTextStyle:
              PageDecoration().bodyTextStyle.copyWith(color: Colors.black),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
      PageViewModel(
        image: Image.asset("assets/create.png"),
        title: "Create your activity",
        body: "Create or Searching for your activity",
        // footer: Text(
        //   "MTECHVIRAL",
        //   style: TextStyle(color: Colors.black),
        // ),
        decoration: PageDecoration(
          titleTextStyle:
              PageDecoration().titleTextStyle.copyWith(color: Colors.black),
          bodyTextStyle:
              PageDecoration().bodyTextStyle.copyWith(color: Colors.black),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    ];
  }

  createAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: 'Meet a Friend',
            description: 'Who will you meet today?',
          );
        });
  }

  @override
  void initState() {
    initializing();
    super.initState();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  void initializing() async {
    androidInitializationSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Hello there', 'please subscribe my channel', notificationDetails);
    createAlertDialog();
  }

  Future<void> notificationAfterSec() async {
    // var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    var time = Time(21, 00, 0);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    // await flutterLocalNotificationsPlugin.schedule(1, 'Hello there',
    //     'please subscribe my channel', timeDelayed, notificationDetails);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        1, "Wiggle", "Meet a new friend now!", time, notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
      createAlertDialog();
    }
    // we can set navigator to navigate another screen
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Onboarding');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: IntroductionScreen(
        // globalBackgroundColor: Colors.white,
        showSkipButton: true,
        skip: Text("Skip"),
        pages: getPages(),
        done: Text(
          "Let's We Invited",
          style: TextStyle(color: Colors.black),
        ),
        onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        },
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({this.title, this.description, this.buttonText, this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: dialogContent(context),
    );
  }

  // dialogContent(BuildContext context) {
  //   final user = Provider.of<User>(context) ?? User();
  //   // final wiggles = Provider.of<List<Wiggle>>(context) ?? [];
  //   return StreamBuilder<Object>(
  //       stream: DatabaseService(uid: user.uid).userData,
  //       builder: (context, snapshot) {
  //         UserData userData = snapshot.data;
  //         if (userData != null) {
  //           return Stack(
  //             children: <Widget>[
  //               Container(
  //                   padding: EdgeInsets.only(
  //                       top: 100, bottom: 16, left: 14, right: 14),
  //                   margin: EdgeInsets.only(top: 50),
  //                   decoration: BoxDecoration(
  //                       color: Color(0xFF505050),
  //                       shape: BoxShape.rectangle,
  //                       borderRadius: BorderRadius.circular(17),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black26,
  //                           blurRadius: 10,
  //                           offset: Offset(0, 10),
  //                         )
  //                       ]),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: <Widget>[
  //                       Text(title,
  //                           style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.w600,
  //                               color: Color(0xFFFFC107))),
  //                       Text(description,
  //                           style: TextStyle(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.w100,
  //                               color: Color(0xFFFFC107))),
  //                       Align(
  //                         alignment: Alignment.bottomRight,
  //                         child: FlatButton(
  //                           onPressed: () {
  //                             Navigator.of(context).pushReplacement(
  //                               MaterialPageRoute(
  //                                 builder: (context) => Wrapper(),
  //                               ),
  //                             );
  //                           },
  //                           child: Text(
  //                             'LETZ GEDDIT',
  //                             style: TextStyle(
  //                                 color: Color(0xFFFFC107),
  //                                 fontWeight: FontWeight.w500),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   )),
  //               Positioned(
  //                   top: 0,
  //                   left: 0,
  //                   right: 0,
  //                   child: CircleAvatar(
  //                     backgroundColor: Colors.blueGrey,
  //                     radius: 60,
  //                     backgroundImage: AssetImage('assets/images/WTaB.gif'),
  //                   ))
  //             ],
  //           );
  //         } else {
  //           return Loading();
  //         }
  //       });
  // }
}
