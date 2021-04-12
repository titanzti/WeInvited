import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:we_invited/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:we_invited/models/user.dart';
import 'package:we_invited/notifier/userData_notifier.dart';
import 'package:we_invited/screens/Place/address_search.dart';
import 'package:we_invited/screens/Place/place_service.dart';
import 'package:we_invited/screens/create_event/slider_view.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/AppTheme.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

// ignore: must_be_immutable
class PostActivity extends StatefulWidget {
  final UserDataProfile userData;
  final bool isUpdating;
  File file;
  PostActivity({@required this.isUpdating, this.userData});
  @override
  _PostActivityState createState() => _PostActivityState();
}

class _PostActivityState extends State<PostActivity> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _textlocController = new TextEditingController();
  String selectDateTime;

  Post _currentPost = Post();
  // static double _lowerValue = 12.0;
  // static double _upperValue = 60.0;

  // RangeValues _currentRangeValues = RangeValues(double.parse(_lowerValue.toStringAsFixed(0)), double.parse(_upperValue.toStringAsFixed(0)));

  double peopleValue = 0;

  String selectedcategoryType;

  String selectedgenderType;
  String _imageUrl;
  File _imageFile;
  double _kPickerSheetHeight = 216.0;
  PermissionStatus _status;
  String value;
  File file;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  bool uploading = false;

  String postId = Uuid().v4();
  bool isLoading = false;

  DateTime _date = DateTime.now();
  DateTime _dateEnt = DateTime.now();

  Position _currentPosition;
  Geolocator _geolocator = Geolocator();
  String latitude = "";
  String longitude = "";
  String address = "";

  final List<String> _categoryType = <String>[
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
  final List<String> _genderType = <String>[
    'ผู้ชาย',
    'ผู้หญิง',
    'ผู้ชาย & ผู้หญิง',
  ];
  RangeValues _currentRangeValues = const RangeValues(12, 60);

  double _lowerValue = 20.0;
  double _upperValue = 80.0;
  double _lowerValueFormatter = 20.0;
  double _upperValueFormatter = 20.0;

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  static String _valueToString(double value) {
    return value.toStringAsFixed(0);
  }

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  PostNotifier postNotifier =
                      Provider.of<PostNotifier>(context, listen: false);
                  getPosts(postNotifier);
                  file = widget.file;
                  if (postNotifier.currentPost != null) {
                    _currentPost = postNotifier.currentPost;
                  } else {
                    _currentPost = new Post();
                  }
                  _imageUrl = _currentPost.image;

                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  getProfile(profileNotifier);

                  file = widget.file;
                  if (postNotifier.currentPost != null) {
                    _currentPost = postNotifier.currentPost;
                  } else {
                    _currentPost = new Post();
                  }
                  _imageUrl = _currentPost.image;
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    super.initState();
  }

  @override
  void dispose() {
    descriptionTextEditingController.dispose();
    _textlocController.dispose();
    super.dispose();
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("");
    } else if (_imageFile != null) {
      print('showing image from local file');
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
              padding: EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                'Change Image',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                _getLocalImage();
              })
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    }
  }

  _clear() {
    setState(() => _imageFile = null);
  }

  _getLocalImage() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);

    if (imageFile != null && await imageFile.exists()) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Widget _buildPlaceField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'สถานที่'),
      // initialValue: _currentPost.place,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Tital is required';
        }

        if (value != null) {
          // SizedBox(
          //   height: 100,
          //   child: ListView.separated(
          //     itemCount: 10,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Text("Hello $index ");
          //     },
          //     separatorBuilder: (BuildContext context, int index) =>
          //         Divider(),
          //   ),
          // );
          print(value);
        }

        return null;
      },
      onSaved: (String value) {
        _currentPost.place = value;
      },
      onTap: () {
        print("กด");
      },
    );
  }

  Widget _buildNameField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Title'),
          // initialValue: _currentPost.name,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 15),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
          onSaved: (String value) {
            _currentPost.name = value;
          },
        ),
      ],
    );
  }

  Widget _buildcatField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: DropdownButtonFormField(
            // value: userData.gender,
            items: _categoryType
                .map((value) => DropdownMenuItem(
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                      value: value,
                    ))
                .toList(),
            onChanged: (selectedCategory) {
              setState(() {
                selectedcategoryType = selectedCategory;
              });
            },
            onSaved: (String value) {
              _currentPost.category = value;
            },
            validator: (String value) {
              if (value == null) {
                return 'Please select an event category.';
              }
              return null;
            },
            isExpanded: false,
            hint: Text(
              'Select category',
              // style:
              // TextStyle(color: Colors.white),
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildgenderField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: DropdownButtonFormField(
            // value: userData.gender,
            items: _genderType
                .map((value) => DropdownMenuItem(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 15),
                      ),
                      value: value,
                    ))
                .toList(),
            onChanged: (selectedGender) {
              setState(() {
                selectedgenderType = selectedGender;
              });
            },
            onSaved: (String value) {
              _currentPost.gender = value;
            },
            validator: (String value) {
              if (value == null) {
                return 'Please select a gender category';
              }
              return null;
            },
            isExpanded: false,
            hint: Text(
              'Select the gender you want to meet',
              style: TextStyle(fontSize: 15),

              // style:
              // TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _builddesField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: TextFormField(
            maxLines: 5,
            // onChanged: (val) {
            //   setState(() => bio = val);
            // },
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter event details.';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 15),
            decoration: InputDecoration(
                labelText: ('Event details'),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                // hintText: ' Bio',
                filled: true,
                fillColor: Colors.white70,
                border: InputBorder.none),

            onSaved: (String value) {
              _currentPost.description = value;
            },
          ),
        ),
      ],
    );
  }

  Widget DatetimePick(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeStartField() {
    final format = DateFormat("dd-MM-yyyy HH:mm");
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text('วันเวลาที่เริ่มกิจกรรม '),
          Container(
            child: DateTimeField(
              validator: (DateTime value) {
                if (value == null) {
                  return 'Please enter the start time of the Event';
                }

                return null;
              },
              decoration: InputDecoration(
                enabled: false,
                hintText: (_date.toString()),
                labelText: 'Date and time of start event',
              ),
              initialValue: _date,
              format: format,
              onShowPicker: (context, currentValue) async {
                // await showCupertinoModalPopup(
                //     context: context,
                //     builder: (context) {
                //       return DatetimePick(
                //         CupertinoDatePicker(
                //           initialDateTime: _date,
                //           use24hFormat: true,
                //           minimumDate: _date,
                //           minimumYear: 2010,
                //           maximumYear: 2021,
                //           onDateTimeChanged: (dateTime) {
                //             _date = dateTime;
                //             print(dateTime);
                //             setState(() {
                //               // _date = dateTime;
                //               Text('$_date').toString();
                //             });
                //           },
                //         ),
                //       );
                //     });

                setState(() {
                  InputDecoration(
                    hintText: (_date.toString()),
                  );
                });
                return _date;
              },
              onSaved: (_date) => setState(() {
                _currentPost.startdateTime = Timestamp.fromDate(_date);
              }),
            ),
          ),
        ]);
  }

  Widget _buildDateTimeEntField() {
    final format = DateFormat("dd-MM-yyyy HH:mm");
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text('วันเวลาที่เริ่มกิจกรรม '),
          Container(
            child: DateTimeField(
              validator: (DateTime value) {
                if (value == null) {
                  return 'Please enter a time for the end of the event.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: (_dateEnt.toString()),
                labelText: 'Date and time of end event',
              ),
              style: TextStyle(fontSize: 15),
              // initialValue: _currentPost.entdateTime,
              format: format,
              onShowPicker: (context, currentValue) async {
                await showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return DatetimePick(
                        CupertinoDatePicker(
                          initialDateTime: _dateEnt,
                          use24hFormat: true,
                          minimumDate: _date,
                          minimumYear: 2010,
                          maximumYear: 2021,
                          onDateTimeChanged: (dateTime) {
                            _dateEnt = dateTime;
                            print(dateTime);
                            setState(() {
                              // _date = dateTime;
                              Text('$_dateEnt').toString();
                            });
                          },
                        ),
                      );
                    });

                setState(() {});
                return _dateEnt;
              },
              onSaved: (_dateEnt) => setState(() {
                _currentPost.entdateTime = Timestamp.fromDate(_dateEnt);
              }),
            ),
          ),
        ]);
  }

  Widget _buildNumpeople() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'Number of people participating in the event',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 15 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        SliderView(
          peopleValue: peopleValue,
          onChangedistValue: (double value) {
            peopleValue = value;
            int a = peopleValue.toInt();
            _currentPost.Numpeople = a.toString();
          },
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildAgeUI() {
    // RangeValues _currentRangeValues = const RangeValues(1, 60);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'Age${_currentRangeValues.start.round().toString()}-${_currentRangeValues.end.round() == 60 ? "${_currentRangeValues.end.round()}+" : _currentRangeValues.end.round().toString()}',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 15 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),

        RangeSlider(
          values: _currentRangeValues,
          min: 12,
          max: 60,

          // divisions: 1,
          labels: RangeLabels(
            _currentRangeValues.start.round().toStringAsFixed(0),
            _currentRangeValues.end.round().toStringAsFixed(0),
          ),
          onChanged: (RangeValues value) {
            setState(() {
              _currentPost.agerange = value.toString();
              _currentRangeValues = value;
              print(_currentRangeValues);
              // print(RangeValues.parse(_currentRangeValues.toString()));
              // _valueToString(double.parse(_currentRangeValues.toString()));
            });
          },
        ),
        //  SizedBox(
        //   height: 8,
        // ),
      ],
    );
  }

  Widget _buildLocField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // decoration: BoxDecoration(
          //   border: Border(bottom:BorderSide(),
          //   ),
          // ),
          child: ListTile(
              title: TextFormField(
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter event location.';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 15),
                  controller: _textlocController,
                  decoration: InputDecoration(
                    labelText: 'Add location',
                    hintText: (address.toString()),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  // initialValue: _currentPost.name,
                  readOnly: true,
                  onChanged: (val) {
                    value = val;
                    setState(() {
                      if (_currentPosition != null) Text('$address').toString();
                    });
                  },
                  onSaved: (String value) {
                    _currentPost.place = value;
                  },
                  onTap: () async {
                    final sessionToken = Uuid().v4();
                    final Suggestion result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken),
                    );
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      final placeDetails = await PlaceApiProvider(sessionToken)
                          .getPlaceDetailFromId(result.placeId);
                      setState(() {
                        _textlocController.text = result.description;
                        // _streetNumber = placeDetails.streetNumber;
                        // _street = placeDetails.street;
                        // _city = placeDetails.city;
                        // _zipCode = placeDetails.zipCode;
                      });
                    }
                  }),
              trailing:
                  Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade400),
              onTap: () {
                // _askPermission();
                _getCurrentLocation();
                // Navigator.of(context).push(MaterialPageRoute(
                //    builder: (context)=> SearchPlace(value: address),
                // ));
              }),
        ),
      ],
    );
  }

  _onPostUploaded(Post post) {
    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    postNotifier.addPost(post);
    Navigator.pop(context);
  }

  _saveEven() {
    print('savePost Called');
    if (!_formKey.currentState.validate()) {
      return;
    }
/*ถ้ารูปเท่ากับค่าว่างจะโชว์ว่า กรุณาใส่รูป */
    if (_imageFile == null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Please put a picture'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      /*ถ้าไม่ จะอัพโหลด */
    } else {
      uploadFoodAndImage(
          _currentPost, widget.isUpdating, _imageFile, _onPostUploaded);
    }

    _formKey.currentState.save();

    setState(() {
      uploading = true;
    });

    print('form saved');

    print("name: ${_currentPost.name}");
    print("category: ${_currentPost.place}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
    print("uid: ${_currentPost.uid.toString()}");
    print(
        "datetime: ${_date.day}/${_date.month}/${_date.year}/${_date.hour}:${_date.minute}");
    print("วดป: ${_currentPost.startdateTime}");
    print('เวลา${selectDateTime.toString()}');

    setState(() {
      // file = null;
      uploading = false;
    });

    Navigator.pop(context);
  }

  uploadFoodAndImage(
      Post post, bool isUpdating, File localFile, Function foodUploaded) async {
    if (localFile != null) {
      print("uploading image");

      var fileExtension = path.extension(localFile.path);
      print(fileExtension);

      var uuid = Uuid().v4();

      final StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('posts/images/$uuid$fileExtension');

      await firebaseStorageRef
          .putFile(localFile)
          .onComplete
          .catchError((onError) {
        print(onError);
        return false;
      });

      String url = await firebaseStorageRef.getDownloadURL();
      print("download url: $url");
      _uploadFood(post, isUpdating, foodUploaded, imageUrl: url);
    } else {
      print('...skipping image upload');
      // _uploadFood(post, isUpdating, foodUploaded);
    }
  }

  _uploadFood(Post post, bool isUpdating, Function foodUploaded,
      {String imageUrl}) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();

    CollectionReference foodRef =
        await FirebaseFirestore.instance.collection('Posts');
    // .doc(uid)
    // .collection("PostsList");
    final name = await AuthService().getCurrentUser();
    final User user = await auth.currentUser;
    final username = user.displayName;

    if (imageUrl != null) {
      post.image = imageUrl;
    }

    if (isUpdating) {
      post.updatedAt = Timestamp.now();

      await foodRef.doc(post.postid).update(post.toMap());

      foodUploaded(post);
      print('updated food with id: ${post.postid}');
    } else {
      post.createdAt = Timestamp.now();
      post.emailuser = uEmail;
      post.uid = uid;
      post.postbyname = widget.userData.name;
      post.postbyimage = widget.userData.profilePhoto;
      post.likes = 0;
      DocumentReference documentRef = await foodRef.add(post.toMap());

      post.postid = documentRef.id;

      // await FirebaseFirestore.instance
      //     .collection("Posts")
      //     .doc(post.postid)
      //     .collection('likes')
      //     .doc(uEmail)
      //     .set({'likes': 0});

      print('uploaded food successfully: ${post.toString()}');

      await documentRef.set(post.toMap());

      foodUploaded(post);
    }
  }

  String _locationMessage = "";

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _locationMessage = "lat${position.latitude}, lon${position.longitude}";
      });

      _fetchLocation();
    }).catchError((e) {
      print(e);
    });
  }

  // _getAddressFromLatLng() async {
  //   try {
  //     List<Placemark> p = await geolocator.placemarkFromCoordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);

  //     Placemark place = p[0];

  //     setState(() {
  //       // _currentAddress =
  //       // "${place.locality}, ${place.postalCode}, ${place.country}";
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  ///Call this function
  _fetchLocation() async {
    Position position = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    ///Here you have choose level of distance
    latitude = position.latitude.toString() ?? '';
    longitude = position.longitude.toString() ?? '';
    var placemarks = await _geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);
    setState(() {
      address =
          '${placemarks.first.name.isNotEmpty ? placemarks.first.name + ', ' : ''}${placemarks.first.thoroughfare.isNotEmpty ? placemarks.first.thoroughfare + ', ' : ''}${placemarks.first.subLocality.isNotEmpty ? placemarks.first.subLocality + ', ' : ''}${placemarks.first.locality.isNotEmpty ? placemarks.first.locality + ', ' : ''}${placemarks.first.subAdministrativeArea.isNotEmpty ? placemarks.first.subAdministrativeArea + ', ' : ''}${placemarks.first.postalCode.isNotEmpty ? placemarks.first.postalCode + ', ' : ''}${placemarks.first.administrativeArea.isNotEmpty ? placemarks.first.administrativeArea : ''}';
    });
    print("latitude" + latitude);
    print("longitude" + longitude);
    print("adreess" + address);
  }

  void _updateStatus(PermissionStatus status) {
    if (status != _status) {
      setState(() {
        _status = status;
      });
    }
  }

  void _askPermission() {
    PermissionHandler().requestPermissions(
        [PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != PermissionStatus.granted) {
      PermissionHandler().openAppSettings();
    } else {
      _updateStatus(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.close,
            color: MColors.textGrey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          "Create Activity",
          style: boldFont(MColors.primaryPurple, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_a_photo,
              color: MColors.textGrey,
            ),
            onPressed: () async {
              _getLocalImage();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: Column(children: <Widget>[
                  _showImage(),
                  SizedBox(height: 16),
                  // Text(
                  //   widget.isUpdating ? "Edit Post" : "Create Activity",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 30),
                  // ),
                  SizedBox(height: 16),
                  // _imageFile == null && _imageUrl == null
                  //     ? ButtonTheme(
                  //         child: RaisedButton(
                  //           onPressed: () => _getLocalImage(),
                  //           child: Text(
                  //             'Add Image',
                  //             style: TextStyle(color: Colors.white),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(height: 0),

                  _buildNameField(),
                  SizedBox(
                    height: 10,
                  ),
                  _builddesField(),
                  Divider(
                    height: 2,
                  ),
                  _buildNumpeople(),
                  Divider(
                    height: 2,
                  ),
                  _buildAgeUI(),
                  Divider(
                    height: 2,
                  ),

                  _buildcatField(),
                  Divider(
                    height: 2,
                  ),
                  _buildDateTimeStartField(),
                  Divider(
                    height: 2,
                  ),
                  SizedBox(height: 10.0),
                  _buildLocField(),
                  Divider(
                    height: 2,
                  ),
                  _buildDateTimeEntField(),
                  Divider(
                    height: 2,
                  ),
                  _buildgenderField(),
                  Divider(
                    height: 2,
                  ),
                ]),
              ),
            ),
          ),
          const Divider(
            height: 1,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: HotelAppTheme.buildLightTheme().primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  // highlightColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _saveEven();
                  },
                  child: Center(
                    child: Text(
                      'Post',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     FocusScope.of(context).requestFocus(new FocusNode());
      //     _saveFood();
      //     // Navigator.of(context).pop();
      //   },
      //   child: Icon(Icons.save),
      //   foregroundColor: Colors.white,
      // ),
    );
  }
}
