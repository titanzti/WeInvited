import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:we_invited/main.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class InterestScreen extends StatefulWidget {
  final String title;

  const InterestScreen({Key key, this.title}) : super(key: key);

  @override
  _InterestScreenState createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  // single choice value
  int tag = 1;

  // multiple choice value
  List<String> tags = [];

  // list of string options
  List<String> options = [
    'Business',
    'Education',
    'Food',
    'Games',
    'Health',
    'Nature',
    'Other',
    'Party',
    'Shopping',
    'Sport',
  ];

  var select;

  String user;
  final usersMemoizer = AsyncMemoizer<List<C2Choice<String>>>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final formKey = GlobalKey<FormState>();
  List<String> formValue;
/* อัพเดทinterest */
  Future<User> updateinterest() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User user = _auth.currentUser;
/* userไม่เท่ากับค่าว่างให้อัพเดท */

    if (user != null) {
      FirebaseFirestore.instance.collection("userData").doc(user.email)
        ..collection("profile").doc(user.email).update({
          'Listinterest': formValue,
        }).catchError((e) {
          print(e);
        });
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    print('${formValue.toString()}');
    return Scaffold(
      appBar: primaryAppBar(
        null,
        Text(
          "Select Interest",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.27,
            color: MColors.primaryPurple,
          ),
          // style: boldFont(MColors.primaryPurple, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 6, right: 5, bottom: 30, top: 50),
        child: Row(
          children: [
            Expanded(
              child: ListView(
                addAutomaticKeepAlives: true,
                children: <Widget>[
                  Content(
                    title: 'Interest',
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          FormField<List<String>>(
                            autovalidate: true,
                            initialValue: formValue,
                            onSaved: (val) {
                              setState(() {
                                formValue = val;
                              });
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? value == null) {
                                return 'Please select some categories';
                              }
                              if (value.length > 5) {
                                return "Can't select more than 5 categories";
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ChipsChoice<String>.multiple(
                                      value: state.value,
                                      onChanged: (val) {
                                        state.didChange(val);
                                        setState(() {
                                          select = val;
                                        });
                                        print(val);
                                      },
                                      choiceItems:
                                          C2Choice.listFrom<String, String>(
                                        source: options,
                                        value: (i, v) => v.toLowerCase(),
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceStyle: const C2ChoiceStyle(
                                        color: Colors.indigo,
                                        borderOpacity: .3,
                                      ),
                                      choiceActiveStyle: const C2ChoiceStyle(
                                        color: Colors.indigo,
                                        brightness: Brightness.dark,
                                      ),
                                      wrapped: true,
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 10),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        state.errorText ??
                                            state.value.length.toString() +
                                                '/5 selected',
                                        style: TextStyle(
                                            color: state.hasError
                                                ? Colors.redAccent
                                                : Colors.green),
                                      ))
                                ],
                              );
                            },
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Expanded(
                                //   child: Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: <Widget>[
                                //         const Text('Selected Value:'),
                                //         SizedBox(height: 5),
                                //         Text('$select'),
                                //       ]),
                                // ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                RaisedButton(
                                    child: const Text('Submit'),
                                    color: Colors.blueAccent,
                                    padding: const EdgeInsets.only(
                                        left: 100,
                                        right: 100,
                                        bottom: 16,
                                        top: 16),
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(16),
                                      // side: BorderSide(color: Colors.black),
                                    ),
                                    onPressed: () async {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      if (formKey.currentState.validate()) {
                                        // If the form is valid, save the value.
                                        formKey.currentState.save();
                                        updateinterest();

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        MyApp()),
                                            (Route<dynamic> route) => false);
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final Color color;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final bool selected;
  final Function(bool selected) onSelect;

  CustomChip({
    Key key,
    this.label,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.selected,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: this.width,
      height: this.height,
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 5,
          ),
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: selected ? (color ?? Colors.green) : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(selected ? 25 : 10)),
        border: Border.all(
          color: selected ? (color ?? Colors.green) : Colors.grey,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelect(!selected),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Visibility(
                visible: selected,
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                )),
            Positioned(
              left: 9,
              right: 9,
              bottom: 7,
              child: Container(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  Content({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content>
    with AutomaticKeepAliveClientMixin<Content> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.blueGrey[50],
            child: Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.blueGrey, fontWeight: FontWeight.w500),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}

// void _about(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (_) => Dialog(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           ListTile(
//             title: Text(
//               'chips_choice',
//               style: Theme.of(context)
//                   .textTheme
//                   .headline5
//                   .copyWith(color: Colors.black87),
//             ),
//             subtitle: const Text('by davigmacode'),
//             trailing: IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.loose,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Text(
//                     'Easy way to provide a single or multiple choice chips.',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyText2
//                         .copyWith(color: Colors.black54),
//                   ),
//                   Container(height: 15),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
