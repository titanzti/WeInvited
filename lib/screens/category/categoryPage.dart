import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/Activity/Post_activity.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:we_invited/shared/icon_badge.dart';


class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    PostNotifier postNotifier = Provider.of<PostNotifier>(context);

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
                      'Home',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          postNotifier.currentPost = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return PostActivity(
                isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          ('Category'),
          style: TextStyle(color: Colors.black, fontSize: 30),

        ),
      ),
    );
  }
}
