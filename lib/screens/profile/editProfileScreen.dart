import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:we_invited/main.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import 'package:we_invited/utils/datetime_utils.dart';
import 'package:we_invited/widgets/widget.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final UserDataProfile user;
  EditProfileScreen(this.user);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState(user);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  UserDataProfile user;
  File _imageFile;
  String birthDateInString;
  DateTime birthDate;
  bool isDateSelected = false;

  _EditProfileScreenState(this.user);
  Future profileFuture;
  bool loading = false;
  DateTime _date = DateTime.now();
  double _kPickerSheetHeight = 216.0;

  File _image;
  String y;
  String x;
  List<String> _genderType = <String>[
    'Male',
    'Female',
  ];
  var str;
  var phone1;

  var startIndex;
  var endIndex;
  var start = "";
  var end = "(";
  var test;

  int _selectedIndex = 0;

  String name;
  String phone;

  String email;

  String _gender;

  var _selectedGenderType;
  String _error;

  bool _autoValidate = false;
  final format = new DateFormat('dd-MMM-yyyy');
  @override
  void initState() {
    var phone = user.phone;

    str = phone;

    startIndex = str.indexOf(start);
    endIndex = str.indexOf(end, startIndex + start.length);
    phone1 = str.substring(startIndex + start.length, endIndex);
    print('phone1=>>>>>>$phone1');

    // print('=>>>>>>>>>>${str.substring(startIndex + start.length, endIndex)}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhiteSmoke,
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MColors.textGrey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          "Profile",
          style: boldFont(MColors.primaryPurple, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        <Widget>[
          FlatButton(
            onPressed: () {
              _submit();
            },
            child: Text(
              "Save",
              style: boldFont(MColors.primaryPurple, 14.0),
            ),
          )
        ],
      ),
      body: primaryContainer(
        SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Hero(
                    tag: "profileAvatar",
                    child: GestureDetector(
                      onTap: () => imageCapture(),
                      child: Container(
                        child:
                            user.profilePhoto == null || user.profilePhoto == ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(9.0),
                                    child: Image.asset(
                                      "assets/profile1.png",
                                      height: 90.0,
                                      width: 90.0,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(9.0),
                                    child: FadeInImage.assetNetwork(
                                      image: user.profilePhoto,
                                      fit: BoxFit.fill,
                                      height: 90.0,
                                      width: 90.0,
                                      placeholder: "assets/profile1.png",
                                    ),
                                  ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MColors.dashPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () => imageCapture(),
                  child: Text(
                    "Edit photo",
                    style: boldFont(MColors.primaryPurple, 14.0),
                  ),
                ),
                SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Name",
                            style: normalFont(MColors.textGrey, null),
                          ),
                          SizedBox(height: 5.0),
                          primaryTextField(
                            null,
                            user.name,
                            "",
                            (val) => name = val,
                            true,
                            (String value) => value.isEmpty ? null : null,
                            false,
                            _autoValidate,
                            false,
                            TextInputType.text,
                            null,
                            null,
                            0.50,
                          ),
                          Divider(),
                          Text(
                            "Email",
                            style: normalFont(MColors.textGrey, null),
                          ),
                          SizedBox(height: 5.0),
                          primaryTextField(
                            null,
                            user.email,
                            "",
                            (val) => email = val,
                            false,
                            (String value) => value.isEmpty ? null : null,
                            false,
                            _autoValidate,
                            false,
                            TextInputType.text,
                            null,
                            null,
                            0.00,
                          ),
                          Divider(),
                          Text(
                            "Phone",
                            style: normalFont(MColors.textGrey, null),
                          ),
                          SizedBox(height: 5.0),
                          primaryTextField(
                            null,
                            user.phone,
                            "",
                            (val) => phone = val,
                            true,
                            (String value) => value.isEmpty ? null : null,
                            false,
                            _autoValidate,
                            false,
                            TextInputType.text,
                            null,
                            null,
                            0.50,
                          ),
                          Divider(),
                          Text(
                            "Birthday",
                            style: normalFont(MColors.textGrey, null),
                          ),
                          TextFormField(
                              readOnly: true,
                              initialValue: DateTimeUtils.getFullDate(
                                  user.birthday == null
                                      ? Text('กรุณาใส่')
                                      : user.birthday.toDate()),
                              decoration: InputDecoration(
                                  // hintText: (DateTimeUtils.getMonth(
                                  //     user.birthday.toDate())),
                                  ),
                              onChanged: (datePick) {
                                setState(() {
                                  test = datePick;
                                });
                                print('birthDate$test');
                              },
                              // child: new Icon(Icons.calendar_today),
                              onTap: () async {
                                final datePick = await showDatePicker(
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime(1900),
                                    lastDate: new DateTime(2100));
                                if (datePick != null && datePick != birthDate) {
                                  setState(() {
                                    birthDate = datePick;
                                    isDateSelected = true;
                                    print('birthDateInString$birthDate');

                                    // put it here
                                    birthDateInString = DateTimeUtils.getMonth(
                                        user.birthday.toDate()); // 08/14/2019
                                  });
                                }
                              }

                              //  onSaved: ,
                              ),
                        ],
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10.0),
                    // Container(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: <Widget>[
                    //       Text(
                    //         "Email",
                    //         style: normalFont(MColors.textGrey, null),
                    //       ),
                    //       SizedBox(height: 5.0),
                    //       primaryTextField(
                    //         null,
                    //         user.email,
                    //         "",
                    //             (val) => _email = val,
                    //         true,
                    //             (String value) =>
                    //         value.isEmpty ? Strings.fieldReq : null,
                    //         false,
                    //         _autoValidate,
                    //         false,
                    //         TextInputType.text,
                    //         null,
                    //         null,
                    //         0.50,
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Text(
                      "Gender",
                      style: normalFont(MColors.textGrey, null),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: DropdownButtonFormField(
                          // validator: (val) {
                          //   return val == null
                          //       ? 'Please provide a valid Gender'
                          //       : null;
                          // },
                          items: _genderType
                              .map((value) => DropdownMenuItem(
                                    child: Text(
                                      value,
                                      style: normalFont(MColors.textGrey, null),
                                    ),
                                    value: value,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenderType = value;
                              print(_selectedGenderType);
                            });
                          },
                          onSaved: (val) => _gender = val,
                          value: _selectedGenderType,
                          isExpanded: false,
                          decoration: textFieldInputDecoration(user.gender),
                        )),
                      ],
                    ),
                    Divider(),
                    Text(
                      "Hometown",
                      style: normalFont(MColors.textGrey, null),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CountryListPick(
                              appBar: AppBar(
                                backgroundColor: Colors.blue,
                                title: Text('Select Country/Region'),
                              ),

                              // if you need custome picker use this
                              pickerBuilder:
                                  (context, CountryCode countryCode) {
                                return Row(
                                  children: [
                                    Image.asset(
                                      countryCode.flagUri,
                                      package: 'country_list_pick',
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                    Text(countryCode.name),
                                    // Text(countryCode.dialCode),
                                  ],
                                );
                              },

                              // To disable option set to false
                              theme: CountryTheme(
                                isShowFlag: true,
                                isShowTitle: true,
                                isShowCode: true,
                                isDownIcon: true,
                                showEnglishName: true,
                              ),
                              // Set default value
                              initialSelection: '+66',
                              onChanged: (CountryCode code) {
                                print(code.name);
                                print(code.code);
                                print(code.dialCode);
                                print(code.flagUri);
                              },

                              // Whether to allow the widget to set a custom UI overlay
                              useUiOverlay: true,
                              // Whether the country list should be wrapped in a SafeArea
                              useSafeArea: false),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // GestureDetector(
    //       onTap: () => FocusScope.of(context).unfocus(),
    //       child: Scaffold(
    //         key: _scaffoldKey,
    //         appBar: primaryAppBar(
    //           IconButton(
    //             icon: Icon(
    //               Icons.arrow_back_ios,
    //               color: MColors.textGrey,
    //             ),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //           Text(
    //             "Profile",
    //             style: boldFont(MColors.primaryPurple, 16.0),
    //           ),
    //           MColors.primaryWhiteSmoke,
    //           null,
    //           true,
    //           <Widget>[
    //             FlatButton(
    //               onPressed: () {
    //                 _submit();
    //               },
    //               child: Text(
    //                 "Save",
    //                 style: boldFont(MColors.primaryPurple, 14.0),
    //               ),
    //             )
    //           ],
    //         ),
    //         body: primaryContainer(
    //           SingleChildScrollView(
    //             child: Form(
    //               key: formKey,
    //               child: Column(
    //                 children: <Widget>[
    //                   Center(
    //                     child: Hero(
    //                       tag: "profileAvatar",
    //                       child: GestureDetector(
    //                         onTap: () => imageCapture(),
    //                         child: Container(
    //                           child: user.profilePhoto == null ||
    //                                   user.profilePhoto == ""
    //                               ? ClipRRect(
    //                                   borderRadius:
    //                                       BorderRadius.circular(9.0),
    //                                   child: Image.asset(
    //                                     "assets/profile1.png",
    //                                     height: 90.0,
    //                                     width: 90.0,
    //                                   ),
    //                                 )
    //                               : ClipRRect(
    //                                   borderRadius:
    //                                       BorderRadius.circular(9.0),
    //                                   child: FadeInImage.assetNetwork(
    //                                     image: user.profilePhoto,
    //                                     fit: BoxFit.fill,
    //                                     height: 90.0,
    //                                     width: 90.0,
    //                                     placeholder: "assets/profile1.png",
    //                                   ),
    //                                 ),
    //                           decoration: BoxDecoration(
    //                             shape: BoxShape.circle,
    //                             color: MColors.dashPurple,
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(height: 10.0),
    //                   GestureDetector(
    //                     onTap: () => imageCapture(),
    //                     child: Text(
    //                       "Edit photo",
    //                       style: boldFont(MColors.primaryPurple, 14.0),
    //                     ),
    //                   ),
    //                   SizedBox(height: 30.0),
    //                   Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       Container(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: <Widget>[
    //                             Text(
    //                               "Name",
    //                               style: normalFont(MColors.textGrey, null),
    //                             ),
    //                             SizedBox(height: 5.0),
    //                             primaryTextField(
    //                               null,
    //                               user.name,
    //                               "",
    //                               (val) => _name = val,
    //                               true,
    //                               (String value) =>
    //                                   value.isEmpty ? Strings.fieldReq : null,
    //                               false,
    //                               _autoValidate,
    //                               false,
    //                               TextInputType.text,
    //                               null,
    //                               null,
    //                               0.50,
    //                             ),
    //                             Text(
    //                               "Email",
    //                               style: normalFont(MColors.textGrey, null),
    //                             ),
    //                             SizedBox(height: 10.0),
    //                             Container(
    //                               child: Column(
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: <Widget>[
    //                                   Text(
    //                                     "Email",
    //                                     style: normalFont(MColors.textGrey, null),
    //                                   ),
    //                                   SizedBox(height: 5.0),
    //                                   primaryTextField(
    //                                     null,
    //                                     user.email,
    //                                     "",
    //                                         (val) => _email = val,
    //                                     true,
    //                                         (String value) =>
    //                                     value.isEmpty ? Strings.fieldReq : null,
    //                                     false,
    //                                     _autoValidate,
    //                                     false,
    //                                     TextInputType.text,
    //                                     null,
    //                                     null,
    //                                     0.50,
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             Row(
    //                               children: <Widget>[
    //                                 // CupertinoButton(
    //                                 //     child: Text("Select Gender :"),
    //                                 //     onPressed: () {
    //                                 //       showModalBottomSheet(
    //                                 //           context: context,
    //                                 //           builder: (BuildContext context) {
    //                                 //             return Container(
    //                                 //               height: 200.0,
    //                                 //               color: Colors.white,
    //                                 //               child: Row(
    //                                 //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 //                 children: <Widget>[
    //                                 //                   CupertinoButton(
    //                                 //                     child: Text("Cancel"),
    //                                 //                     onPressed: () {
    //                                 //                       Navigator.pop(context);
    //                                 //                     },
    //                                 //                   ),
    //                                 //                   Expanded(
    //                                 //                     child: CupertinoPicker(
    //                                 //                         scrollController:
    //                                 //                         new FixedExtentScrollController(
    //                                 //                           initialItem: _blockType.length,
    //                                 //                         ),
    //                                 //                         itemExtent: 32.0,
    //                                 //                         backgroundColor: Colors.white,
    //                                 //                         onSelectedItemChanged: (int index) {
    //                                 //                           // _changedNumber = index;
    //                                 //                         },
    //                                 //                         children: new List<Widget>.generate(100,
    //                                 //                                 (int index) {
    //                                 //                               return new Center(
    //                                 //                                 child: new Text('${index+1}'),
    //                                 //                               );
    //                                 //                             })),
    //                                 //                   ),
    //                                 //                   CupertinoButton(
    //                                 //                     child: Text("Ok"),
    //                                 //                     onPressed: () {
    //                                 //                       setState(() {
    //                                 //                         // _selectedNumber = _changedNumber;
    //                                 //                       });
    //                                 //                       Navigator.pop(context);
    //                                 //                     },
    //                                 //                   ),
    //                                 //                 ],
    //                                 //               ),
    //                                 //             );
    //                                 //           });
    //                                 //     }),
    //                                 // Text(
    //                                 //   '',
    //                                 //   style: TextStyle(fontSize: 18.0),
    //                                 // ),
    //                                 // SizedBox(
    //                                 //   height: 20.0,
    //                                 // ),
    //
    //                                 // Expanded(
    //                                 //     child: DropdownButtonFormField(
    //                                 //   validator: (val) {
    //                                 //     return val == null
    //                                 //         ? 'Please provide a valid Gender'
    //                                 //         : null;
    //                                 //   },
    //                                 //   items: _genderType
    //                                 //       .map((value) => DropdownMenuItem(
    //                                 //             child: Text(
    //                                 //               value,
    //                                 //               style: TextStyle(
    //                                 //                   color: Colors.black),
    //                                 //             ),
    //                                 //             value: value,
    //                                 //           ))
    //                                 //       .toList(),
    //                                 //   onChanged: (selectedGender) {
    //                                 //     setState(() {
    //                                 //       _selectedGenderType =
    //                                 //           selectedGender;
    //                                 //     });
    //                                 //   },
    //                                 //   value: _selectedGenderType,
    //                                 //   isExpanded: false,
    //                                 //   decoration: textFieldInputDecoration(
    //                                 //       'Choose Gender'),
    //                                 // )),
    //                               ],
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
  }

  void _submit() async {
    final form = formKey.currentState;
    try {
      if (form.validate()) {
        form.save();
        updateProfile(name, _gender);
        Navigator.pop(context);
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.message;
      });
      print(_error);
    }
  }

  // Profile Image---------------------------------------

  //select imge via gallery or camera

  Future<void> _pickImage(ImageSource source) async {
    // ignore: deprecated_member_use
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
  }

  //cropper plugin
  Future<void> _cropImage(_imageFileForCrop) async {
    File _cropped = await ImageCropper.cropImage(
      sourcePath: _imageFileForCrop.path,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: MColors.primaryPurple,
        toolbarWidgetColor: MColors.primaryWhiteSmoke,
        toolbarTitle: "Crop image",
      ),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
    );
    // ignore: unnecessary_statements
    _cropped == null ? null : saveImage(_cropped);
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  // image capture

  imageCapture() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          bottom: 25.0,
          left: 10.0,
          right: 10.0,
          top: 10.0,
        ),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: MColors.primaryWhite,
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        height: 150.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Change profile photo",
                style: boldFont(MColors.textDark, 18.0),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.camera)
                      .then((v) => _cropImage(_imageFile));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15.0),
                  height: 30.0,
                  width: double.infinity,
                  child: Text(
                    "Capture with camera",
                    style: normalFont(MColors.textDark, 14.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery)
                      .then((v) => _cropImage(_imageFile));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15.0),
                  height: 30.0,
                  width: double.infinity,
                  child: Text(
                    "Choose from photo gallery",
                    style: normalFont(MColors.textDark, 14.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  saveImage(imageFile) {
    print('saveImage');
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.8,
          decoration: BoxDecoration(
            color: MColors.primaryWhiteSmoke,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.0),
              primaryAppBar(
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: MColors.textGrey,
                  ),
                  onPressed: () {
                    _clear();
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  "Save Photo",
                  style: boldFont(MColors.primaryPurple, 16.0),
                ),
                MColors.primaryWhiteSmoke,
                null,
                true,
                <Widget>[
                  FlatButton(
                    onPressed: () async {
                      print('กด');
                      _showLoadingDialog();

                      await checkInternetConnectivity().then((value) {
                        value == true
                            ? () async {
                                await updateProfilePhoto(imageFile)
                                    .then((value) {
                                  // Navigator.pop(context);

                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(true);
                                });
                              }()
                            : () {
                                showNoInternetSnack(_scaffoldKey);
                                Navigator.of(context).pushAndRemoveUntil(
                                  CupertinoPageRoute(
                                    builder: (_) => MyApp(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              }();
                      });
                      // Navigator.of(context).pop();
                    },
                    child: Text(
                      "Save",
                      style: boldFont(MColors.primaryPurple, 14.0),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.0),
              primaryContainer(
                Container(
                  height: MediaQuery.of(context).size.height * .50,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2.3,
                        child: Image.file(imageFile),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _showLoadingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return;
          },
          child: AlertDialog(
            backgroundColor: MColors.primaryWhiteSmoke,
            content: Container(
              height: 20.0,
              child: Row(
                children: <Widget>[
                  Text(
                    "Saving...",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                  Spacer(),
                  progressIndicator(MColors.primaryPurple),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
