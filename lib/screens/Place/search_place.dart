// import 'package:flutter/material.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:we_invited/Activity/Post_activity.dart';
// import 'package:we_invited/widgets/divider_with_text_widget.dart';
//
// class SearchPlace extends StatefulWidget {
//     String value;
//
//    SearchPlace({Key key, this.value}) : super(key: key);
//
//
//   @override
//   _SearchPlaceState createState() => _SearchPlaceState(value);
// }
//
// class _SearchPlaceState extends State<SearchPlace> {
//   String value;
//   _SearchPlaceState(this.value);
//
//   @override
//   void initState() {
//     super.initState();
//
//
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     TextEditingController _titleController = new TextEditingController();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('สถานที่'),
//         actions: <Widget>[
//           FlatButton(
//             // textColor: Colors.grey,
//             onPressed: () => Navigator.of(context).pop(null),
//             child: Text("Cancel"),
//           ),
//         ],
//         leading: new Container(),
//       ),
//
//       body:Center(
//         child: Column(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(30.0),
//               child: TextField(
//                 // controller: _searchController,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: new DividerWithText(
//                 // dividerText: _heading,
//               ),
//             ),
//             Expanded(
//               // child: ListView.builder(
//               //   itemCount: _placesList.length,
//               //   itemBuilder: (BuildContext context, int index) =>
//               //       buildPlaceCard(context, index),
//               // ),
//             ),
//           ],
//         ),
//       ),
//
//     );
//
//   }
//
//
// }
