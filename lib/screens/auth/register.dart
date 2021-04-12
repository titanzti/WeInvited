import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/auth/interest.dart';
import 'package:we_invited/services/login.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/textFieldFormaters.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/widgets/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:we_invited/notifier/userData_notifier.dart';

import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/widgets/allWidgets.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  String name;
  String _phone;
  String _email;
  String _gender;

  String _password;
  String _error;
  bool _autoValidate = false;
  bool _isButtonDisabled = false;
  bool _obscureText = true;
  bool _isEnabled = true;

  bool loading = false;

  File _image;
  var x;
  List<String> _genderType = <String>[
    'Male',
    'Female',
  ];

  // Future getImage() async {
  //   var image = await picker.getImage(source: ImageSource.gallery);
  //   setState(() {
  //     _image = File(image.path);
  //   });
  // }
  /*คำนวณอายุจาก วดป ที่เลือก */
  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

/*เลือก วดป */
  selectDate(BuildContext context, DateTime initialDateTime,
      {DateTime lastDate}) async {
    Completer completer = Completer();
    String _selectedDateInString;
    if (Platform.isAndroid)
      showDatePicker(
              context: context,
              initialDate: initialDateTime,
              firstDate: DateTime(1970),
              lastDate: lastDate == null
                  ? DateTime(initialDateTime.year + 10)
                  : lastDate)
          .then((temp) {
        if (temp == null) return null;
        completer.complete(temp);
        setState(() {});
      });
    else
      DatePicker.showDatePicker(
        context,
        dateFormat: 'yyyy-mmm-dd',
        locale: 'en',
        onConfirm2: (temp, selectedIndex) {
          if (temp == null) return null;
          completer.complete(temp);

          setState(() {});
        },
      );
    return completer.future;
  }

  String birthDate = "";
  int age = -1;
  TextStyle valueTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  TextStyle textTextStyle = TextStyle(
    fontSize: 16,
  );
  TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  // pickImageFromGallery(context) async {
  //   Navigator.pop(context);
  //   File image = await ImagePicker.pickImage(
  //       source: ImageSource.gallery, imageQuality: 50);
  //   setState(() {
  //     _image = image;
  //   });
  // }

  // captureImageWithCamera(context) async {
  //   Navigator.pop(context);
  //   _image = await ImagePicker.pickImage(
  //       source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
  // }

  // takeImage(nContext) {
  //   return showDialog(
  //       context: nContext,
  //       builder: (context) {
  //         return SimpleDialog(
  //           title: Text("New Post"),
  //           children: <Widget>[
  //             SimpleDialogOption(
  //               child: Text(
  //                 "Capture Image with Camera",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () => captureImageWithCamera(nContext),
  //             ),
  //             SimpleDialogOption(
  //               child: Text(
  //                 "Select Image from Gallery",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () => pickImageFromGallery(nContext),
  //             ),
  //             SimpleDialogOption(
  //               child: Text(
  //                 "Cancel",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () => Navigator.pop(context),
  //             ),
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    // print(birthDate);
    // print(age);
    // print(name.toString());
    // print(_email);
    print(birthDate);
    return ChangeNotifierProvider<UserDataProfileNotifier>(
      create: (BuildContext context) => UserDataProfileNotifier(),
      child: Consumer<UserDataProfileNotifier>(
        builder: (context, profileNotifier, _) {
          return Scaffold(
            backgroundColor: MColors.primaryWhiteSmoke,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: primaryContainer(
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Text(
                        "Create your free account",
                        style: boldFont(MColors.textDark, 38.0),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    SizedBox(height: 20.0),

                    Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Already have an account? ",
                            style: normalFont(MColors.textGrey, 16.0),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            child: Text(
                              "Sign in!",
                              style: normalFont(MColors.primaryPurple, 16.0),
                              textAlign: TextAlign.start,
                            ),
                            onTap: () {
                              formKey.currentState.reset();
                              Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                  builder: (_) => Login(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    showAlert(),

                    SizedBox(height: 10.0),

                    //FORM
                    Form(
                      key: formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Name",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "Remiola",
                                (val) => name = val,
                                _isEnabled,
                                NameValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.text,
                                null,
                                null,
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Email",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "e.g Remiola2034@gmail.com",
                                (val) => _email = val,
                                _isEnabled,
                                EmailValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.emailAddress,
                                null,
                                null,
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Password",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                null,
                                (val) => _password = val,
                                _isEnabled,
                                PasswordValiditor.validate,
                                _obscureText,
                                _autoValidate,
                                false,
                                TextInputType.text,
                                null,
                                SizedBox(
                                  height: 20.0,
                                  width: 40.0,
                                  child: RawMaterialButton(
                                    onPressed: _toggle,
                                    child: Text(
                                      _obscureText ? "Show" : "Hide",
                                      style: TextStyle(
                                        color: MColors.primaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: Text(
                              "Your password must have 6 or more characters, a capital letter and must contain at least one number.",
                              style: normalFont(MColors.primaryPurple, null),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Phone number",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "e.g +55 (47) 12345 6789",
                                (val) => _phone = val,
                                _isEnabled,
                                PhoneNumberValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.numberWithOptions(),
                                [maskTextInputFormatter],
                                null,
                                0.50,
                              ),
                              SizedBox(height: 10.0),
                              Container(
                                child: Text(
                                  "Your number should contain your country code and state code.",
                                  style:
                                      normalFont(MColors.primaryPurple, null),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Age_Calculator(),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.verified_user,
                                    color: MColors.primaryPurple,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        "By continuing, you agree to our Terms of Service.",
                                        style:
                                            normalFont(MColors.textGrey, null),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              _isButtonDisabled == true
                                  ? primaryButtonPurple(
                                      //if button is loading
                                      progressIndicator(Colors.white),
                                      null,
                                    )
                                  : primaryButtonPurple(
                                      Text(
                                        "Next step",
                                        style: boldFont(
                                          MColors.primaryWhite,
                                          16.0,
                                        ),
                                      ),
                                      _isButtonDisabled ? null : _submit,
                                    ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

/* Widget คำนวณอายุ*/
  Widget Age_Calculator() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (age > -1)
              ? Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(12, 12)),
                          border: Border.all(color: Colors.grey)),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "BirthDate: ",
                            style: textTextStyle,
                          ),
                          Text(
                            "$birthDate",
                            style: valueTextStyle,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(12, 12)),
                          border: Border.all(color: Colors.grey)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Age: ",
                            style: textTextStyle,
                          ),
                          Text(
                            "$age",
                            style: valueTextStyle,
                          )
                        ],
                      ),
                    )
                  ],
                )
              : Text("Press button to see age"),
          SizedBox(
            height: 32,
          ),
          RaisedButton(
            color: Colors.blue,
            splashColor: Colors.blue.shade300,
            onPressed: () async {
              DateTime birthDate = await selectDate(context, DateTime.now(),
                  lastDate: DateTime.now());
              final df = new DateFormat('dd-MMM-yyyy');
              this.birthDate = df.format(birthDate);
              this.age = calculateAge(birthDate);

              setState(() {});
            },
            child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Select birthdate".toUpperCase(),
                  style: buttonTextStyle,
                )),
          )
        ],
      ),
    );
  }

/* Widget showAlert*/
  Widget showAlert() {
    if (_error != null) {
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.error_outline,
                color: Colors.redAccent,
              ),
            ),
            Expanded(
              child: Text(
                _error,
                style: normalFont(Colors.redAccent, 15.0),
              ),
            ),
          ],
        ),
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: MColors.primaryWhiteSmoke,
          border: Border.all(width: 1.0, color: Colors.redAccent),
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
/* _submit*/

  void _submit() async {
    final form = formKey.currentState;

    try {
      final auth = MyProvider.of(context).auth;

      if (form.validate()) {
        form.save();

        if (mounted) {
          setState(() {
            _isButtonDisabled = true;
            _isEnabled = false;
          });
        }
        /* createUserWithEmailAndPassword*/
        String uid = await auth.createUserWithEmailAndPassword(
          _email,
          _password,
        );
        /* เก็บข้อมูลที่สมัครขึ้นไปบนไฟเบส*/
        storeNewUser(name, _phone, _email, _gender, age.toString(), birthDate);
        print("Signed Up with new $uid");
        /* Navigator ไปหน้าInterestScreen*/
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => InterestScreen()),
            (Route<dynamic> route) => false);
      } else {
        setState(() {
          _autoValidate = true;
          _isEnabled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isButtonDisabled = false;
          _isEnabled = true;
        });
      }

      print("ERRORR ==>");
      print(e);
    }
  }
}
