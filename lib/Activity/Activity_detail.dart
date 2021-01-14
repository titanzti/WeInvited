import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/shared/icon_badge.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class ActivityDetail extends StatefulWidget {
  @override
  _ActivityDetailState createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  PostNotifier postsNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPosts(postsNotifier);
                  print('เชื่อมต่อ');
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    // TODO: implement initState
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // PostNotifier postsNotifier =
    // Provider.of<PostNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Detail',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.27,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: IconBadge(
                  icon: Icons.search,
                ),
                alignment: Alignment.topRight,
                onPressed: () => print("กดๆ"),
              ),
              IconButton(
                icon: IconBadge(
                  icon: Icons.notifications_none,
                ),
                alignment: Alignment.topRight,
                onPressed: () => print("กดๆ"),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              // Text(postsNotifier.currentPost.name),
            ],
          ),
        ),
      ),
    );
  }
}
