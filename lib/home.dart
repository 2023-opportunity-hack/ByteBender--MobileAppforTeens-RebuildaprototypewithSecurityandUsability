import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:safe_space/document_abuse.dart';
import 'package:safe_space/forum.dart';
 import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:safe_space/videos.dart';
import 'package:safe_space/web_view.dart';
 import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'dart:io' as io;
import 'login.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space/stepper.dart';

enum AudioState { recording, stop, play }

const veryDarkBlue = Color(0xff172133);
const kindaDarkBlue = Color(0xff202641);

class Maps extends StatefulWidget {
  LatLng mytarget;
  String uid;
  Maps(
    this.mytarget,
    this.uid,
  );
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> with TickerProviderStateMixin {
  final picker = ImagePicker();
  late File image;
  TextEditingController foodcontroller = TextEditingController();

  late String _value;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late double lat;
  late double long;
  late String url;

  bool isCollapsed = true;
  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation _arrowAnimation;
  late AnimationController _arrowAnimationController;
  bool isRippleSeen = false;
  bool isDrawerOpen = false;

//   _init() async {
//     try {
//       bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;

//       if (hasPermission) {
//         String customPath = '/flutter_audio_recorder_';
//         io.Directory appDocDirectory;
// //        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
//         if (io.Platform.isIOS) {
//           appDocDirectory = await getApplicationDocumentsDirectory();
//         } else {
//           appDocDirectory = (await getExternalStorageDirectory())!;
//         }

//         // can add extension like ".mp4" ".wav" ".m4a" ".aac"
//         customPath = appDocDirectory.path +
//             customPath +
//             DateTime.now().millisecondsSinceEpoch.toString();

//         // .wav <---> AudioFormat.WAV
//         // .mp4 .m4a .aac <---> AudioFormat.AAC
//         // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
//         _recorder =
//             FlutterAudioRecorder2(customPath, audioFormat: AudioFormat.WAV);

//         await _recorder.initialized;
//         // after initialization
//         var current = await _recorder.current(channel: 0);
//         print(current);
//         // should be "Initialized", if all working fine
//         setState(() {
//           _current = current!;
//           _currentStatus = current.status!;
//           print(_currentStatus);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: new Text("You must accept permissions")));
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   _start() async {
//     try {
//       await _recorder.start();
//       var recording = await _recorder.current(channel: 0);
//       setState(() {
//         _current = recording!;
//       });

//       const tick = const Duration(milliseconds: 50);
//       new Timer.periodic(tick, (Timer t) async {
//         if (_currentStatus == RecordingStatus.Stopped) {
//           t.cancel();
//         }

//         var current = await _recorder.current(channel: 0);
//         // print(current.status);
//         setState(() {
//           _current = current!;
//           _currentStatus = _current.status!;
//         });
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   _stop() async {
//     var result = await _recorder.stop();
//     // File file =
//     //     LocalFileSystem()
//     //         .file(result.path);
//     // final audioPlayer = AudioPlayer();
//     // await audioPlayer.play(result.path);
//     print("Stop recording: ${result?.path}");
//     print("Stop recording: ${result?.duration}");
//     File file = LocalFileSystem().file(result?.path);
//     print("File length: ${await file.length()}");
//     setState(() {
//       _current = result!;
//       _currentStatus = _current.status!;
//     });
//   }

  void initMarker(
    position,
    profile_pic,
  ) async {
    setState(() {
      _markers.add(new Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(position[0], position[1]),
          builder: (ctx) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/marker.png")))),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0, right: 0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profile_pic),
                      radius: 10,
                    ),
                  ),
                ],
              )));
    });
  }

    getMarkerData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection("contacts")
        .get()
        .then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
          print("This issick ${value.docs[i].data()["uid"]}");

        var position;
        var profile_pic;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(value.docs[i].data()["uid"])
            .get()
            .then((value) {
          position = value.data()!["location"];
          profile_pic = value.data()!["profile_pic"];
        });

        initMarker(position, profile_pic);
      }
      _markers.add(Marker(
          width: 20,
          height: 20,
          point: LatLng(mylocation[0], mylocation[1]),
          rotate: true,
          builder: (ctx) {
            return Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    border: Border.all(color: Colors.white, width: 3)));
          }));
    });
    setState(() {});
  }

Future<void> getAlertContacts() async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(widget.uid)
      .collection("contacts")
      .get()
      .then((value) {
    alertContacts.clear(); // Clear the list before adding new values.
    for (int i = 0; i < value.docs.length; i++) {
      alertContacts.add(value.docs[i].data()["phone"]);
    }
  });
}
  List<String> alertContacts = [];


 

Future<String> sendSms() async {
  await getAlertContacts(); // Await the completion of this function.

  try {
    String _result = await sendSMS(
      message: "${name} of age ${age} is wanting help right now. Her current location is ${mylocation} and it would be best if you rush to the spot immediately.",
      recipients: alertContacts + [emer],
    );
    print(_result);
    return _result; // Return the result.
  } on PlatformException catch (e) {
    print(e.toString());
    throw e; // Re-throw the exception if needed.
  }
}
  bool map_seen = false;
  TextEditingController _emergency = new TextEditingController();
  TextEditingController _editNameController = new TextEditingController();
  TextEditingController _editAgeController = new TextEditingController();
  TextEditingController _editPhoneController = new TextEditingController();

  String mobile_number="";
  int position = 0;
  int video_duration = 0;
  var length;

  getLength() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("messeages")
        .orderBy("date", descending: true)
        .get()
        .then((value) {
      setState(() {
        length = value.docs.length;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMarkerData();
    // getuid();
    savelocation();
    // _init();
    getLength();
    getAlertContacts();
    location.onLocationChanged.listen((LocationData currentLocation) {
      updateCurrentLocation();
      getMarkerData();
    });
    location = Location();
    location.enableBackgroundMode(enable: true);
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    updateCurrentLocation();

    getuserinfo();

    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _arrowAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _arrowAnimation =
        Tween(begin: 0.0, end: -pi / 30).animate(_arrowAnimationController);
  }

  List<double> mylocation = [12, 21];
  savelocation() async {
    LocationData position = await location.getLocation();
    lat = position.latitude!;
    long = position.longitude!;
    print(position.latitude);
    setState(() {
      mylocation = [lat, long];
      map_seen = true;
    });
  }

  Location location = new Location();

  List<Marker> 
_markers = [Marker(point: LatLng(33.41253 ,-111.83189), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  }),Marker(point: LatLng(33.4150 , -111.8946), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  }),Marker(point: LatLng(33.4229 ,-111.9384), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  }),Marker(point: LatLng(33.4163 ,-111.8455), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  }),Marker(point: LatLng(33.4012 ,-111.9575), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  }),Marker(point: LatLng(33.4492959 ,-111.9677444), builder: (ctx){
    return Container(width: 40,height: 40,child:Icon(Icons.location_on_rounded,size: 45,color: Colors.red.withOpacity(0.6),));
  })];
  // MapboxMapController _mapController;
  late String useruid;

  FirebaseAuth _auth=FirebaseAuth.instance;
  TextEditingController _nameController=TextEditingController();
 TextEditingController _phoneController=TextEditingController();

  getuserinfo() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((value) {
      setState(() {
        name = value["name"];
        age = value["age"];
        no = value["no."];
        phone = value["phone"];
        emer = value["emer"];
        panic_attacks = value["no_of_alerts"];
        profile_pic = value["profile_pic"];
        _editNameController = TextEditingController(text: name);
        _editAgeController = TextEditingController(text: age);

        _emergency = new TextEditingController(text: emer);
      });
    });
  }

  int panic_attacks=0;

  String emer="";
  updateCurrentLocation() {
    FirebaseFirestore.instance.collection("users").doc(widget.uid).set({
      "location": [mylocation[0], mylocation[1]]
    },SetOptions( merge: true));
  }

   String name="";
  String age="";
   String no="";
   String profile_pic="";
   String phone="";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(4281483342),
      body: Stack(
        children: [
          menu(context),
          AnimatedPositioned(
            duration: duration,
            top: 30,
            bottom: isCollapsed ? 0 : -.20 * screenHeight,
            left: isCollapsed ? 0 : 0.5 * screenWidth,
            right: isCollapsed ? 0 : -0.5 * screenWidth,
            child: AnimatedBuilder(
                animation: _arrowAnimationController,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: Material(
                      animationDuration: duration,
                      color: Color(4281483342),
                      child: ClipRRect(
                        borderRadius: isCollapsed != true
                            ? BorderRadius.circular(20)
                            : BorderRadius.circular(0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              map_seen == false
                                  ? Container()
                                  : Theme(
                                      data: ThemeData.dark(),
                                      child: FlutterMap(
                                        // nonRotatedLayers:[TileLayerOptions(
                                        //     urlTemplate:
                                        //         "https://api.mapbox.com/styles/v1/dhanush-17/ckrft6eoe42qs18qyy668ljwk/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZGhhbnVzaC0xNyIsImEiOiJja2JzN3dhOWQwMTBpMnRvZDhuOHpjcmZmIn0.QP0KthFBt-DSqq918As-Gg",
                                        //     additionalOptions: {
                                        //       'accessToken':
                                        //           "pk.eyJ1IjoiZGhhbnVzaC0xNyIsImEiOiJja2JzN3dhOWQwMTBpMnRvZDhuOHpjcmZmIn0.QP0KthFBt-DSqq918As-Gg",
                                        //       'id': 'mapbox.streets',
                                        //     },
                                        //   ),],
                                        options: MapOptions(
                                            onMapReady: () async {
                                              LocationData position =
                                                  await location.getLocation();
                                              lat = position.latitude!;
                                              long = position.longitude!;
                                              print(position.latitude);
                                              setState(() {
                                                mylocation = [lat, long];
                                              });
                                            },
                                            onPositionChanged:
                                                (position, isChanged) {
                                              // Firestore.instances
                                              //     .collection("users")
                                              //     .document(widget.uid)
                                              //     .setData({
                                              //   "location": [
                                              //     position.center.latitude,
                                              //     position.center.latitude
                                              //   ]
                                              // }, merge: true);
                                            },
                                            center: LatLng(
                                                mylocation[0], mylocation[1]),
                                            zoom: 15,
                                            maxZoom: 18),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                "https://api.mapbox.com/styles/v1/dhanush-17/cks1ez7nj5w3118qghbv383lh/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZGhhbnVzaC0xNyIsImEiOiJja2JzN3dhOWQwMTBpMnRvZDhuOHpjcmZmIn0.QP0KthFBt-DSqq918As-Gg",
                                            additionalOptions: {
                                              'accessToken':
                                                  "pk.eyJ1IjoiZGhhbnVzaC0xNyIsImEiOiJja2JzN3dhOWQwMTBpMnRvZDhuOHpjcmZmIn0.QP0KthFBt-DSqq918As-Gg",
                                              'id': 'mapbox.streets',
                                            },
                                          ),
                                          MarkerLayer(
                                            markers: _markers,
                                            rotate: true,
                                          ),
                                          // PolylineLayerOptions(polylines: [
                                          //   Polyline(
                                          //     points: latlngList,
                                          //     // isDotted: true,
                                          //     color: Color(0xFF669DF6),
                                          //     strokeWidth: 3.0,
                                          //     borderColor: Color(0xFF1967D2),
                                          //     borderStrokeWidth: 0.1,
                                          //   )
                                          //])
                                        ],
                                      ),
                                    ),

                              //  MapboxMap(
                              //   onMapCreated: _onMapCreated,
                              //   myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                              //   myLocationEnabled: true,
                              //   styleString:
                              //       "mapbox://styles/dhanush-17/ckrft6eoe42qs18qyy668ljwk",
                              //   initialCameraPosition: CameraPosition(
                              //       target: new LatLng(mylocation[0], mylocation[1]),
                              //       zoom: 0.0,
                              //       bearing: 0.0,
                              //       tilt: 0.0),
                              // )),
                              // IgnorePointer(
                              //     ignoring: true,
                              //     child: Stack(
                              //       children: _markers,
                              //     )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 10, right: 10),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Container(
                                      //     height: 45,
                                      //     width: 118,
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.white,
                                      //       borderRadius: BorderRadius.circular(20),
                                      //     ),
                                      //     child: Row(
                                      //       // mainAxisAlignment:MainAxisAlignment.center,
                                      //       children: [
                                      //         SizedBox(width: 7),
                                      //         Icon(Icons.settings_outlined),
                                      //         SizedBox(width: 6),
                                      //         Text("Settings",
                                      //             style: TextStyle(
                                      //                 fontSize: 16,
                                      //                 color: Colors.black,
                                      //                 fontWeight: FontWeight.w500))
                                      //       ],
                                      //     )),

                                      isCollapsed
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 30, right: 0),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.menu,
                                                  size: 30,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (isCollapsed)
                                                      _controller.forward();
                                                    else
                                                      _controller.reverse();
                                                    _arrowAnimationController
                                                            .isCompleted
                                                        ? _arrowAnimationController
                                                            .reverse()
                                                        : _arrowAnimationController
                                                            .forward();
                                                    isCollapsed = false;
                                                  });
                                                },
                                              ),
                                            )
                                          : Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 0, right: 0),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (isCollapsed)
                                                      _controller.forward();
                                                    else
                                                      _controller.reverse();

                                                    _arrowAnimationController
                                                            .isCompleted
                                                        ? _arrowAnimationController
                                                            .reverse()
                                                        : _arrowAnimationController
                                                            .forward();
                                                    isCollapsed = true;
                                                  });
                                                 },
                                              )),
                                      Column(
                                        children: [
                                          StepperTouch(
                                            initialValue: 0,
                                            direction: Axis.vertical,
                                            withSpring: false,
                                            onChanged: (int value) async {

                                              showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select an option"),
          actions: <Widget>[
            TextButton(
              onPressed: () {                     
                                     launch("tel://911");

                // Implement the action for "Call 911" here
                Navigator.of(context).pop();
                successDialog();
                getuserinfo();
              },
              child: Text("Call 911"),
            ),
            TextButton(
              onPressed: () {
sendSms();

                // Implement the action for "Send Broadcast" here
                Navigator.of(context).pop();
                                successDialog();

              },
              child: Text("Send Broadcast"),
            ),
            TextButton(
              onPressed: () {
                sendSms();
                // Implement the action for "Phone a friend" here
                Navigator.of(context).pop();
                                successDialog();

              },
              child: Text("Phone a friend"),
            ),
          ],
        );
      },
    );
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(widget.uid)
                                                  .set({
                                                "no_of_alerts":
                                                    FieldValue.increment(1)
                                              }, SetOptions(merge: true));
                                              getuserinfo();
                                              
                                            }, key: Key("ederation"), onSlide: (int value) {  },
                                           ),
                              SizedBox(height:10),
                                             
                                             GestureDetector(
onTap:(){
  Navigator.push(context,MaterialPageRoute(builder: (s)=>WebViewScreen()));
}
                                               ,child: Container(
                                                                           
                                                                             width: 50,
                                                                             height: 50,
                                                                             decoration: BoxDecoration(
                                                                                 shape: BoxShape.circle,
                                                                                 color: Colors.green.withOpacity(0.2)),
                                                                             child: Icon(Icons.web,
                                                                                 color: Colors.green.withOpacity(1)),
                                                                           ),
                                             ),
                                        ],
                                      ),

                                    ]),
                              ),

                             
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          30,
                                      height:
                                       220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: hexToColor("#212124"),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 70,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  30,
                                             decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          topLeft:
                                                              Radius.circular(
                                                                  15)),
                                                  color: Color(4278217470)),
                                              child: Row(children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTapDown: (TapDownDetails
                                                      tapDown) async {
                                                    print("downnnn");
                                                    setState(() {
                                                      isRippleSeen = true;
                                                    });
                                                    // _start();
                                                  },
                                                  onTapUp: (tapUp) async {
                                                 Navigator.push(context, MaterialPageRoute(builder:(c)=>VideoScreen()));
                                                  },
                                                  child: Container(
                                                          width: 45,
                                                          height: 45,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .red),
                                                          child: Icon(
                                                            Icons.play_arrow_rounded,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                     
                                                        ),
                                                
                                                SizedBox(width: 10),
                                                Text(
                                                  "Safety Resources to watch",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ])),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                    "Panic Alert Contacts",
                                                    style: TextStyle(
                                                        color:
                                                            Color(4278217470),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19))),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                            child: SingleChildScrollView(
                                              child: Container(
                                                height: 60,
                                                width: double.infinity,
                                                child: StreamBuilder(
                                                  stream: FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(widget.uid)
                                                      .collection("contacts")
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    return snapshot.data == null
                                                        ? Container()
                                                        : ListView.separated(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (ctx, i) {
                                                              return StreamBuilder(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(snapshot
                                                                              .data
                                                                              ?.docs[
                                                                                  i]
                                                                              .data()[
                                                                          "uid"])
                                                                      .snapshots(),
                                                                  builder:
                                                                      (context,
                                                                          snap) {
                                                                    return snap.data ==
                                                                            null
                                                                        ? Container()
                                                                        : Container(
                                                                            width:
                                                                                60,
                                                                            height:
                                                                                60,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              // borderRadius:
                                                                              //     BorderRadius
                                                                              //         .circular(10),
                                                                              color: Colors.blue,
                                                                              image: DecorationImage(image: NetworkImage(snap.data!["profile_pic"]), fit: BoxFit.cover),
                                                                            ),
                                                                          );
                                                                  });
                                                            },
                                                            separatorBuilder:
                                                                (ctx, i) =>
                                                                    SizedBox(
                                                              width: 10,
                                                            ),
                                                            itemCount: snapshot
                                                                .data!
                                                                .docs
                                                                .length,
                                                          );
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                              length == 0
                                  ? Container()
                                  : StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(widget.uid)
                                          .snapshots(),
                                      builder: (context, snap) {
                                        return snap.data == null
                                            ? Container()
                                            : StreamBuilder(
                                                stream: FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(widget.uid)
                                                    .collection("messeages")
                                                    .orderBy("date",
                                                        descending: true)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  getLength();
                                                  var data = snapshot
                                                      .data!.docs[0].data;

                                                  return data == null
                                                      ? Container()
                                                      : 
                                                          snap
                                                              .data?["isseen"]? Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 20,
                                                                    left: 20,
                                                                    right: 20),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 130,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: Colors
                                                                      .blue),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      data()["dp"] !=
                                                                              null
                                                                          ? GestureDetector(
                                                                              onTap: () {
                                                                                FirebaseFirestore.instance.collection("users").doc(widget.uid).set({
                                                                                  "isseen": true
                                                                                }, SetOptions(merge: true));
                                                                              },
                                                                              child: Padding(
                                                                                  padding: EdgeInsets.all(10),
                                                                                  child: Container(
                                                                                    width: 100,
                                                                                    height: 100,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(data()["dp"] ?? ""), fit: BoxFit.cover)),
                                                                                  )),
                                                                            )
                                                                          : Padding(
                                                                              padding: EdgeInsets.all(10),
                                                                              child: Container(
                                                                                width: 100,
                                                                                height: 100,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                ),
                                                                                child: CircularProgressIndicator(),
                                                                              )),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 10.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              data()["name"] ?? "",
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.white),
                                                                            ),
                                                                            //  GoogleFonts.poppins(
                                                                            //       fontWeight: FontWeight.w500,
                                                                            //       fontSize: 20,
                                                                            //       color: Colors.orange),
                                                                            SizedBox(height: 1),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                launch("tel://${data()["phone_now"]}");
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                      width: 20,
                                                                                      height: 20,
                                                                                      decoration: BoxDecoration(
                                                                                        // shape: BoxShape.circle,
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      child: Icon(
                                                                                        Icons.call,




                                                                                        size: 15,
                                                                                        color: Colors.blue,
                                                                                      )),
                                                                                  SizedBox(
                                                                                    width: 7,
                                                                                  ),
                                                                                  Text(
                                                                                    data()["phone_now"] ?? "",
                                                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 5),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                //   Navigator.of(context).push(
                                                                                //       MaterialPageRoute(
                                                                                //           builder: (builder) =>
                                                                                //               Profile(
                                                                                //                   useruid,
                                                                                //                   location,
                                                                                //                   foodphoto)));
                                                                              },
                                                                              child: Container(
                                                                                height: 30,
                                                                                width: 190,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
                                                                                child: GestureDetector(
                                                                                  onTap: () async {
                                                                                    // AudioPlayer audioPlayer = AudioPlayer();

                                                                                    // await audioPlayer.play(data!()['url_audio']).then((value) async {
                                                                                    //   audioPlayer.onDurationChanged.listen((Duration d) {
                                                                                    //     print('Max duration: $d');
                                                                                    //     setState(() {
                                                                                    //       video_duration = d.inSeconds;
                                                                                    //     });
                                                                                    //   });
                                                                                    //   audioPlayer.onAudioPositionChanged.listen((d) => {
                                                                                    //         setState(() {
                                                                                    //           position = d.inSeconds;
                                                                                    //         })
                                                                                    //       });
                                                                                    //   audioPlayer.onPlayerError.listen((msg) {
                                                                                    //     print('audioPlayer error : $msg');
                                                                                    //   });
                                                                                    // });
                                                                                    // print("====>" + "$video_duration");
                                                                                    // print(position);
                                                                                  },
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      SizedBox(width: 0),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: .0, bottom: 4.0),
                                                                                        child: Icon(
                                                                                          Icons.play_arrow_rounded,
                                                                                          color: Colors.blue,
                                                                                          size: 33,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 20.0),
                                                                                        child: Align(
                                                                                          alignment: Alignment.centerRight,
                                                                                          child: SliderTheme(
                                                                                            data: SliderTheme.of(context).copyWith(
                                                                                              activeTrackColor: Colors.blue,
                                                                                              inactiveTrackColor: Colors.blue.withOpacity(0.3),
                                                                                              trackShape: CustomTrackShape(),
                                                                                              trackHeight: 4.0,
                                                                                              thumbColor: Colors.blueAccent,
                                                                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                                                                              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                                                                                            ),
                                                                                            child: Container(
                                                                                              width: 130,
                                                                                              child: Slider(
                                                                                                value: position.toDouble(),
                                                                                                max: video_duration.toDouble(),
                                                                                                onChanged: (double value) {},
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(width: 0),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container();
                                                        
                                                });
                                      })
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: EdgeInsets.only(top: 38, right: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Center(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 10),
                    //     child: CircleAvatar(
                    //       backgroundColor: Color(4278272638),
                    //       backgroundImage: NetworkImage(
                    //         "https://t4.ftcdn.net/jpg/02/14/74/61/360_F_214746128_31JkeaP6rU0NzzzdFC4khGkmqc8noe6h.jpg",
                    //       ),
                    //       radius: 40,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 10),
                    //   child: Text(
                    //     "Dhanush Vardhan",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         fontSize: 20, color: Color(4278228470)),
                    //   ),
                    // )
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            backgroundColor: Color(4278272638),
                            backgroundImage: NetworkImage(
                              profile_pic ==""?"https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg":profile_pic,
                            ),
                            radius: 40,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? "",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${age ?? ""} years",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
              // : Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(left: 190),
              //         child: CircleAvatar(
              //           backgroundColor: Color(4278272638),
              //           backgroundImage:
              //               AssetImage("assets/unknown.png"),
              //           radius: 40,
              //         ),
              //       ),
              //       SizedBox(
              //         height: 10,
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.only(left: 196),
              //         child: Text(
              //           sn.data["name"],
              //           textAlign: TextAlign.center,
              //           style: TextStyle(
              //               fontSize: 20, color: Color(4278228470)),
              //         ),
              //       )
              //     ],
              //   );

              ,
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: GestureDetector(
                        onTap: () {
                          String uid_of_contact="";

                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(
                                    builder: (ctx, setState) {
                                  return Container(
                                    height: 100,
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      title: Text(
                                        'Add Contact',
                                      ),
                                      content: Container(
                                        height: 120,
                                        child: Column(
                                          children: [
                                            TextField(
                                              style:
                                                  TextStyle(color: Colors.blue),
                                              inputFormatters: [],
                                              onSubmitted: (value) {
                                                setState(() {
                                                  _nameController.text = value;
                                                });
                                              },
                                              controller: _nameController,
                                              cursorColor: Colors.blue,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              decoration: InputDecoration(
                                                hintText: "Name",
                                                hintStyle: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.blue)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              style:
                                                  TextStyle(color: Colors.blue),
                                              onChanged: (value) {
                                                setState(() {
                                                  _phoneController.text = value;
                                                  _phoneController.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  _phoneController
                                                                      .text
                                                                      .length));
                                                });
                                              },
                                              controller: _phoneController,
                                                  keyboardType: TextInputType.phone,
                                              cursorColor: Colors.blue,
                                              
                                              decoration: InputDecoration(
                                                hintText: "Mobile Number",
                                                hintStyle: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.blue)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: TextButton.styleFrom(
     shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),),        
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: TextButton(
                                                               style: TextButton.styleFrom(
         primary: Colors.blue.withOpacity(0.3),

     shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),),        
                   
                                            onPressed: () async {
                                              String my_phone="";
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(widget.uid)
                                                  .get()
                                                  .then((value) {
                                                setState(() {
                                                  my_phone = value["phone"];
                                                });
                                              });
                                              print("===>" +
                                                  _phoneController.text);
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .where("phone",
                                                      isEqualTo:
                                                          _phoneController.text)
                                                  .get()
                                                  .then((value) {
                                                setState(() {
                                                  uid_of_contact = value
                                                      .docs[0].id;
                                                });
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(widget.uid)
                                                    .collection("contacts")
                                                    .add({
                                                  "name": _nameController.text,
                                                  "phone":
                                                      _phoneController.text,
                                                  "location": [],
                                                  "uid": uid_of_contact,
                                                });
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(uid_of_contact)
                                                    .collection("contacts")
                                                    .add({
                                                  "phone": my_phone,
                                                  "uid": widget.uid,
                                                  "location": mylocation,
                                                  "name": name
                                                });
                                                getMarkerData();
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text(
                                              'Save',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(0.2)),
                              child: Icon(Icons.add,
                                  color: Colors.green.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Add Contact",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(
                                    builder: (ctx, setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    title: Text(
                                      'Edit Information',
                                    ),
                                    content: Container(
                                      height: 180,
                                      child: Column(
                                        children: [
                                          TextField(
                                            style:
                                                TextStyle(color: Colors.blue),
                                            inputFormatters: [],
                                            onChanged: (value) {},
                                            cursorColor: Colors.blue,
                                            controller: _editNameController,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: InputDecoration(
                                              hintText: "Name",
                                              hintStyle: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.blue)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          TextField(
                                            style:
                                                TextStyle(color: Colors.blue),
                                            inputFormatters: [],
                                            keyboardType: TextInputType.phone,
                                            onChanged: (value) {},
                                            controller: _editPhoneController,
                                            cursorColor: Colors.blue,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: InputDecoration(
                                              hintText: "Mobile Number",
                                              hintStyle: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.blue)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          TextField(
                                            style:
                                                TextStyle(color: Colors.blue),
                                            inputFormatters: [],
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {},
                                            cursorColor: Colors.blue,
                                            controller: _editAgeController,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: InputDecoration(
                                              hintText: "Age",
                                              hintStyle: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.blue)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                 TextButton(
  style: TextButton.styleFrom(
    primary: Colors.white,
    shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  ),
  onPressed: () => Navigator.pop(context),
  child: Text('Cancel'),
)
        ,                              ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: TextButton(
  style: TextButton.styleFrom(
    primary: Colors.blue.withOpacity(0.3),
    shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),),                                          onPressed: () async {
                                           FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(widget.uid)
                                                .set({
                                              "phone":
                                                  _editPhoneController.text,
                                              "name": _editNameController.text,
                                              "age": _editAgeController.text
                                            }, SetOptions(merge: true)).then((value) {
                                              getuserinfo();
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text(
                                            'Save',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.2)),
                              child: Icon(Icons.edit,
                                  size: 20, color: Colors.blue.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Edit Info.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: GestureDetector(
                        onTap: () {
                        showDialog(
  context: context,
  builder: (ctx) {
    return StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          title: Text(
            'Alert Contacts',
          ),
          content: Container(
            height: 200,
            child: Column(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.uid)
                      .collection("contacts")
                      .snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.data==null?Container(): ListView.separated(
  shrinkWrap: true,
  itemBuilder: (ctx, i) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(snapshot.data!.docs[i]["uid"])
          .snapshots(),
      builder: (context, snap) {
        return  snap.data==null?Container():Container(
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              snap.data!["profile_pic"]),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 170,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                snap.data!["name"] ?? "",
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 17),
                              ),
                          
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          snap.data!["phone"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
      },
    );
  },
  separatorBuilder: (ctx, i) {
    return SizedBox(height: 20);
  },
  itemCount: snapshot.data!.docs.length,
);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.blue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        );
      },
    );
  },
);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.indigoAccent.withOpacity(0.2)),
                              child: Icon(Icons.assignment_outlined,
                                  color: Colors.indigoAccent.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Alert Contacts",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return StatefulBuilder(
                                      builder: (ctx, setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      title: Text(
                                        'Alert Contacts',
                                      ),
                                      content: Container(
                                        height: 80,
                                        child: Column(
                                          children: [
                                            TextField(
                                              style:
                                                  TextStyle(color: Colors.blue),
                                              inputFormatters: [],
                                              onChanged: (value) {},
                                              cursorColor: Colors.blue,
                                              controller: _emergency,
                                              
                                                  keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                hintText: "Emergency Number",
                                                hintStyle: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.blue)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                                               style: TextButton.styleFrom(
     shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),),        
                   
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: TextButton(

                      style: TextButton.styleFrom(
     primary: Colors.blue.withOpacity(0.3),
     shape:  RoundedRectangleBorder(


    borderRadius: BorderRadius.circular(10),
  ),),        
                                                               onPressed: () async {
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(widget.uid)
                                                  .set(
                                                      {"emer": _emergency.text},
                                                    SetOptions(  merge: true)).then(
                                                (value) =>
                                                    Navigator.pop(context),
                                              );
                                            },
                                            child: Text(
                                              'Save',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                                });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withOpacity(0.2)),
                                child: Icon(Icons.phone,
                                    color: Colors.red.withOpacity(1)),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Emergency Number",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Forum(phone)));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(0.2)),
                              child: Icon(Icons.content_paste,
                                  color: Colors.green.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Forum",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                     GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AbusePage(phone)));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withOpacity(0.2)),
                              child: Icon(Icons.content_paste,
                                  color: Colors.amber.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Document Abuse",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                       FirebaseAuth.instance.signOut().then((value) =>   Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Signin())));  },
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.2)),
                              child: Icon(Icons.exit_to_app_rounded,
                                  color: Colors.red.withOpacity(1)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Log Out",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Container(
                  width: 215,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: hexToColor("#212124").withOpacity(0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("$panic_attacks",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.red)),
                          Text("  pannic alerts",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(3))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${alertContacts.length} ",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.red)),
                          Text("alert contacts",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white))
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

Future successDialog(){
return showDialog(
                                              context: context,
                                              builder: (ctx) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    height: 200,
                                                    child: Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Container(
                                                            height: 200,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  height: 300,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            60.0),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        child: lottie.Lottie.asset(
                                                                            "assets/tick.json",
                                                                            height:
                                                                                300,
                                                                            repeat:
                                                                                false),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 8.0,
                                                                      right: 8,
                                                                      top: 15),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      "We have alerted 911 and all your alert contacts",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            19,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Colors
                                                                            .blue,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                );
                                              });
}
}


Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox ?parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme?.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox!.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
