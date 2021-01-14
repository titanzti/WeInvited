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
import 'package:we_invited/screens/home/hotel_app_theme.dart';
import 'package:we_invited/screens/home/slider_view.dart';
import 'package:we_invited/services/Posts_service.dart';
import 'package:we_invited/notifier/post_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:we_invited/services/auth_service.dart';
import 'package:we_invited/services/user_management.dart';
import 'package:we_invited/utils/colors.dart';
import 'package:we_invited/utils/internetConnectivity.dart';
import 'package:we_invited/widgets/allWidgets.dart';

// ignore: must_be_immutable
class PostActivity extends StatefulWidget {
  // PostNotifier  postNotifier =PostNotifier() ;
  // final Iterable<Post> posts;
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
  static double _lowerValue = 12.0;
  static double _upperValue = 60.0;

  RangeValues _currentRangeValues =  RangeValues(_lowerValue, _upperValue);

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
    'กีฬา',
    'การเรียนรู้',
    'อาหารและเครื่องดื่ม',
    'เกม',
    'ธรรมชาติและอุทยาน',
    'กิจกรรมยามค่ำคืน',
    'กิจกรรมกลางแจ้ง',
    'แหล่งช้อปปิ้ง',
    'สุขภาพ',
    'สวนสนุก',
    'ธุรกิจ',
    'อื่นๆ',
  ];
  final List<String> _genderType = <String>[
    'ผู้ชาย',
    'ผู้หญิง',
    'ผู้ชาย & ผู้หญิง',
  ];


  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
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
    return TextFormField(
      decoration: InputDecoration(labelText: 'ชื่อหัวข้อ'),
      // initialValue: _currentPost.name,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 15),
      validator: (String value) {
        if (value.isEmpty) {
          return 'กรุณาใส่ชื่อกิจกรรม';
        }

        // if (value.length < 3 || value.length > 10) {
        //   return 'Name must be more than 3 and less than 20';
        // }

        return null;
      },
      onSaved: (String value) {
        _currentPost.name = value;
      },
    );
  }

  Widget _buildcatField() {
    return SizedBox(
      child: Expanded(
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
            return 'กรุณา เลือกหมวดหมู่กิจกรรม';
          }
          return null;
        },
        isExpanded: false,
        hint: Text(
          'เลือก หมวดหมู่กิจกรรม',
          // style:
          // TextStyle(color: Colors.white),
          style: TextStyle(fontSize: 15),

        ),
      )),
    );
  }

  Widget _buildgenderField() {
    return SizedBox(
      child: Expanded(
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
                return 'กรุณา เลือกหมวดหมู่กิจกรรม';
              }
              return null;
            },
            isExpanded: false,
            hint: Text(
              'เลือก เพศที่คุณต้องการเจอ',
              style: TextStyle(fontSize: 15),

              // style:
              // TextStyle(color: Colors.white),
            ),
          )),
    );
  }

  Widget _builddesField() {
    return SizedBox(
      child: TextFormField(
        maxLines: 5,
        // onChanged: (val) {
        //   setState(() => bio = val);
        // },
        validator: (String value) {
          if (value.isEmpty) {
            return 'กรุณาใส่รายละเอียดกิจกรรม';
          }
          return null;
        },
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
            labelText: ('รายละเอียดกิจกรรม'),
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
    return Column(children: <Widget>[
      // Text('วันเวลาที่เริ่มกิจกรรม '),
      DateTimeField(
        validator: (DateTime value) {
          if (value == null) {
            return 'กรุณาใส่เวลาเริ่มกิจกรรม';
          }

          return null;
        },

        decoration: InputDecoration(
          hintText: (_date.toString()),
          labelText: 'วันเวลาที่เริ่มกิจกรรม',
        ),
         initialValue: _date,
        format: format,
        onShowPicker: (context, currentValue) async {
          await showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return DatetimePick(
                  CupertinoDatePicker(
                    initialDateTime: _date,
                    use24hFormat: true,
                    onDateTimeChanged: (dateTime) {
                      _date = dateTime;
                      print(dateTime);
                      setState(() {
                        // _date = dateTime;
                        Text('$_date').toString();
                      });
                    },
                  ),
                );
              });

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
    ]);
  }

  Widget _buildDateTimeEntField() {
    final format = DateFormat("dd-MM-yyyy HH:mm");
    return Column(children: <Widget>[
      // Text('วันเวลาที่เริ่มกิจกรรม '),
      DateTimeField(
        validator: (DateTime value) {
          if (value == null) {
            return 'กรุณาใส่เวลาจบกิจกรรม';
          }

          return null;
        },
        decoration: InputDecoration(
          hintText: (_dateEnt.toString()),
          labelText: 'วันเวลาที่จบกิจกรรม',

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
    ]);
  }
  Widget distanceViewUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'จำนวนคนที่เข้าร่วม',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 15 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        SliderView(
          peopleValue: peopleValue,
          onChangedistValue: ( double value) {
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
  Widget distanceViewUI1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'ระหว่างอายุ${_currentRangeValues.start.round().toString()}-${_currentRangeValues.end.round()==60?"${_currentRangeValues.end.round()}+":_currentRangeValues.end.round().toString()}',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 15 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),

          RangeSlider(
          values: _currentRangeValues,
    min: _lowerValue,
    max: _upperValue,
    // divisions: 5,
    // labels: RangeLabels(
    // _currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    // ),

    onChanged: (values) {


      _currentPost.agerange = values.toString();

      setState(() {
    _currentRangeValues = values;
    // print(_currentRangeValues);
    });
    },
    ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildLocField() {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border(bottom:BorderSide(),
      //   ),
      // ),
      child: ListTile(
          title: TextFormField(
              style: TextStyle(fontSize: 15),
              controller: _textlocController,

              decoration: InputDecoration(
                labelText: 'Add location',
                hintText: (address.toString()),
                hintStyle: TextStyle(color: Colors.black,
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
                // _currentPost.name = value;
              },
              onTap: () {
                _askPermission();
                _getCurrentLocation();
                // _getCurrenLocation();
                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context)=> SearchPlace(value: address),
                // ));
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
    );
  }

  _onPostUploaded(Post post) {
    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);
    postNotifier.addPost(post);
    Navigator.pop(context);
  }

  _saveFood() {
    print('savePost Called');
    if (!_formKey.currentState.validate()) {
       return ;
    }
    _imageFile==null ? print('ไม่มีค่า') : print("มีค่า");

    if (_imageFile==null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('กรุณาใส่รูป'),
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
    }else{
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



  _uploadFood(Post post, bool isUpdating, Function foodUploaded, {String imageUrl}) async {
    final uEmail = await AuthService().getCurrentEmail();
    final uid = await AuthService().getCurrentUID();

    CollectionReference foodRef = await FirebaseFirestore.instance.collection('Posts');
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
      DocumentReference documentRef = await foodRef.add(post.toMap());

      post.postid = documentRef.id;

      print('uploaded food successfully: ${post.toString()}');

      await documentRef.set(post.toMap());

      foodUploaded(post);
    }
  }


  String _locationMessage = "";

  // void _getCurrenLocation() async {
  //   final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   print(position);
  //
  //   setState(() {
  //
  //     _lan = position.latitude.toString();
  //      _long = position.longitude.toString();
  //     _locationMessage = "lat${position.latitude}, lon${position.longitude}";
  //       Text('$_locationMessage');
  //     Text('lat$_lan');
  //     Text('lon$_long');
  //
  //   });
  // }

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

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        // _currentAddress =
        // "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

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
  


    //
    // print(widget.userData.email);
    // print(widget.userData.profilePhoto);

    // print(user);
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
        <Widget>[],
      ),
      body: Column(
        children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                  children: <Widget>[
                    _showImage(),
                    SizedBox(height: 16),
                    // Text(
                    //   widget.isUpdating ? "Edit Post" : "Create Activity",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(fontSize: 30),
                    // ),
                    SizedBox(height: 16),
                    _imageFile == null && _imageUrl == null
                        ? ButtonTheme(
                      child: RaisedButton(
                        onPressed: () => _getLocalImage(),
                        child: Text(
                          'Add Image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                        : SizedBox(height: 0),
                    _buildNameField(),
                    SizedBox(
                      height: 10,
                    ),
                    _builddesField(),
                    distanceViewUI(),
                    distanceViewUI1(),
                    _buildcatField(),
                    _buildDateTimeStartField(),

                    // _buildPlaceField(),
                    SizedBox(height: 10.0),
                    _buildLocField(),
                    // _buildDateTimeField(),
                    _buildDateTimeEntField(),
                    _buildgenderField(),

                    Text(
                        '${_date.day}/${_date.month}/${_date.year}/${_date.hour}:${_date.minute}'),
                    if (_currentPosition != null) Text(address),
                    // Text('lan$_lan'),
                    // Text('lon$_long'),
                    Text('$_status'),
                    SizedBox(height: 16),
                  ]
              ),
            ),
          ),
        ),
          const Divider(
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 16, bottom: 16, top: 8),
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
                    _saveFood();

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
