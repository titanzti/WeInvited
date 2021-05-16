import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/joinevent.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/screens/category/category_card.dart';
import 'package:we_invited/screens/profile/otherprofile.dart';
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/shared/constant.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class CategoryPage extends StatefulWidget {
  final JoinEvent joinEvent;
  final UserDataProfile user;

  CategoryPage({Key key, this.joinEvent, this.user}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState(joinEvent, user);
}

class _CategoryPageState extends State<CategoryPage> {
  final JoinEvent joinEvent;
  final UserDataProfile user;

  _CategoryPageState(this.joinEvent, this.user);

  @override
  Widget build(BuildContext context) {
    // PostNotifier postNotifier = Provider.of<PostNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     signOutGoogleV1();

      //     // Navigator.pushAndRemoveUntil(
      //     //     context,
      //     //     MaterialPageRoute(
      //     //         builder: (BuildContext context) => Otherprofile()),
      //     //     (Route<dynamic> route) => false);
      //   },
      //   child: Icon(Icons.add),
      //   foregroundColor: Colors.white,
      // ),
      appBar: primaryAppBar(
        null,
        Text(
          "Category",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.27,
            color: MColors.primaryPurple,
          ),
          // style: boldFont(MColors.primaryPurple, 16.0),
        ),
        Colors.white,
        null,
        true,
        <Widget>[],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     postNotifier.currentPost = null;
      //     Navigator.of(context).push(
      //       MaterialPageRoute(builder: (BuildContext context) {
      //         return PostActivity(
      //           isUpdating: false,
      //         );
      //       }),
      //     );
      //   },
      //   child: Icon(Icons.add),
      //   foregroundColor: Colors.white,
      // ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: categoryData.map((category) {
                  return CategoryCard(
                      category['title'],
                      category['courseAmount'],
                      category['imageUrl'],
                      joinEvent,
                      user);
                }).toList(),
              ),
              Row(
                children: [
                  // Container(
                  //
                  //   margin: EdgeInsets.only(
                  //       left: 24, top: 45, right: 24, bottom: 0),
                  //   child: Row(
                  //   children: [
                  //
                  //
                  //   ],
                  // ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
