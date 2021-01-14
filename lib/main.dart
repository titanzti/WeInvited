import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_invited/Activity/Post_activity.dart';
import 'package:we_invited/notifier/join_notifier.dart';

import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/onBoarding.dart';
import 'package:we_invited/screens/home/home.dart';
import 'package:we_invited/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/services/login.dart';
import 'package:we_invited/widgets/provider.dart';
import 'package:we_invited/notifier/post_notifier.dart';

import 'screens/home/testdetail.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return exit(0);
        }
        // Once complete
        if (snapshot.connectionState == ConnectionState.done) {
          return MyProvider(
            auth: AuthService(),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: HomeController(),
            ),
          );
        }
        return SplashScreen();
      },
    );
  }
}

class HomeController extends StatefulWidget {
  const HomeController({Key key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  @override
  Widget build(BuildContext context) {
    
    final AuthService auth = MyProvider.of(context).auth;
    return StreamBuilder(
        stream: auth.onAuthStateChanged,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool signedIn = snapshot.hasData;
            return MaterialApp(
              title: "We Invited",
              theme: ThemeData(),
              debugShowCheckedModeBanner: false,
              home: signedIn
                  ? MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => PostNotifier(),
                          // value: PostNotifier(),
                          child: PostActivity(),
                        ),
                        ChangeNotifierProvider(
                          create: (context) => UserDataProfileNotifier(),
                        ),
                        ChangeNotifierProvider(
                          create: (context) => JoinNotifier(),
                        ),
                        // ChangeNotifierProvider(
                        //   create: (context) => BrandsNotifier(),
                        // ),
                        // ChangeNotifierProvider(
                        //   create: (context) => CartNotifier(),
                        // ),

                        // ChangeNotifierProvider(
                        //   create: (context) => UserDataAddressNotifier(),
                        // ),
                        // ChangeNotifierProvider(
                        //   create: (context) => OrderListNotifier(),
                        // ),
                        // ChangeNotifierProvider(
                        //   create: (context) => NotificationsNotifier(),
                        // ),
                        // ChangeNotifierProvider(
                        //   create: (context) => BannerAdNotifier(),
                        // ),
                      ],
                      child: Home(),
                    )
                  : Log(),
            );
          }
          return SplashScreen();
        });
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
