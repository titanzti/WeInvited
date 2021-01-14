import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:we_invited/models/widget.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/shared/loading.dart';
import 'package:we_invited/utils/cardStrings.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';
import '../../../main.dart';

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

  // ignore: unused_field
  List<String> _blockType = <String>['A', 'B', 'C', 'D', 'E'];

  int _selectedIndex = 0;

  String _name;
  String _gender;

  var _selectedGenderType;
  String _error;

  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    user.gender != null ? print("มีค่า") : print("ไม่มีค่า");
    return loading
        ? Loading()
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
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
                        Center(
                          child: Hero(
                            tag: "profileAvatar",
                            child: GestureDetector(
                              onTap: () => imageCapture(),
                              child: Container(
                                child: user.profilePhoto == null ||
                                        user.profilePhoto == ""
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(9.0),
                                        child: Image.asset(
                                          "assets/profile1.png",
                                          height: 90.0,
                                          width: 90.0,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(9.0),
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
                                    "name",
                                    style: normalFont(MColors.textGrey, null),
                                  ),
                                  SizedBox(height: 5.0),
                                  primaryTextField(
                                    null,
                                    user.name,
                                    "",
                                    (val) => _name = val,
                                    true,
                                    (String value) =>
                                        value.isEmpty ? Strings.fieldReq : null,
                                    false,
                                    _autoValidate,
                                    false,
                                    TextInputType.text,
                                    null,
                                    null,
                                    0.50,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      // CupertinoButton(
                                      //     child: Text("Select Gender :"),
                                      //     onPressed: () {
                                      //       showModalBottomSheet(
                                      //           context: context,
                                      //           builder: (BuildContext context) {
                                      //             return Container(
                                      //               height: 200.0,
                                      //               color: Colors.white,
                                      //               child: Row(
                                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                                      //                 children: <Widget>[
                                      //                   CupertinoButton(
                                      //                     child: Text("Cancel"),
                                      //                     onPressed: () {
                                      //                       Navigator.pop(context);
                                      //                     },
                                      //                   ),
                                      //                   Expanded(
                                      //                     child: CupertinoPicker(
                                      //                         scrollController:
                                      //                         new FixedExtentScrollController(
                                      //                           initialItem: _blockType.length,
                                      //                         ),
                                      //                         itemExtent: 32.0,
                                      //                         backgroundColor: Colors.white,
                                      //                         onSelectedItemChanged: (int index) {
                                      //                           // _changedNumber = index;
                                      //                         },
                                      //                         children: new List<Widget>.generate(100,
                                      //                                 (int index) {
                                      //                               return new Center(
                                      //                                 child: new Text('${index+1}'),
                                      //                               );
                                      //                             })),
                                      //                   ),
                                      //                   CupertinoButton(
                                      //                     child: Text("Ok"),
                                      //                     onPressed: () {
                                      //                       setState(() {
                                      //                         // _selectedNumber = _changedNumber;
                                      //                       });
                                      //                       Navigator.pop(context);
                                      //                     },
                                      //                   ),
                                      //                 ],
                                      //               ),
                                      //             );
                                      //           });
                                      //     }),
                                      // Text(
                                      //   '',
                                      //   style: TextStyle(fontSize: 18.0),
                                      // ),
                                      // SizedBox(
                                      //   height: 20.0,
                                      // ),

                                      Expanded(
                                          child: DropdownButtonFormField(
                                        validator: (val) {
                                          return val == null
                                              ? 'Please provide a valid Gender'
                                              : null;
                                        },
                                        items: _genderType
                                            .map((value) => DropdownMenuItem(
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  value: value,
                                                ))
                                            .toList(),
                                        onChanged: (selectedGender) {
                                          setState(() {
                                            _selectedGenderType =
                                                selectedGender;
                                          });
                                        },
                                        value: _selectedGenderType,
                                        isExpanded: false,
                                        decoration: textFieldInputDecoration(
                                            'Choose Gender'),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void _submit() async {
    final form = formKey.currentState;

    try {
      if (form.validate()) {
        form.save();
        updateProfile(_name, _gender);
        Navigator.pop(context, true);
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
          bottom: 10.0,
          left: 10.0,
          right: 10.0,
          top: 5.0,
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
              SizedBox(height: 30.0),
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
                      await checkInternetConnectivity().then((value) {
                        value == true
                            ? () async {
                                _showLoadingDialog();
                                await updateProfilePhoto(imageFile)
                                    .then((value) {
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
