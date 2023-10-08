import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AbusePage extends StatefulWidget {
  final String phone;
  AbusePage(this.phone);

  @override
  _AbusePageState createState() => _AbusePageState();
}

class _AbusePageState extends State<AbusePage> {
  TextEditingController _abuseController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late CameraController _cameraController;
  XFile? _videoFile;

  @override
  void initState() {
    super.initState();
    _abuseController = TextEditingController();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    setState(() {
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
    });

    try {
      await _cameraController.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  final User? currentUser = FirebaseAuth.instance.currentUser;
 XFile? pickedImage=XFile("");
  Future<String?> _pickImage() async {
    try {
pickedImage =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) return null; // User canceled image picking

      // Upload it to Firebase storage
      // You can use Firebase Storage for image uploads and get the download URL
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('abuse_reports/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask =
          storageReference.putFile(File(pickedImage!.path));

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => print('File Uploaded'));

      // Get the download URL
      final String fileURL = await storageReference.getDownloadURL();
      return fileURL;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(4280758332),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
          top: 50.0,
                left: 20,
                right: 20,
          ),
          child: Column(
            children: [
              Text(
                  "Keep record of your abuse !",
                  style: TextStyle(
                      fontSize: 19,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              SizedBox(
                height: 30,
              ),
              Container(
                
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.blue.withOpacity(0.5)),
                child: Column(
                  children: [
                    TextField(
                      controller: _abuseController,
                      decoration: InputDecoration(
                            border: InputBorder.none, // Remove the black underline
                        hintStyle: TextStyle(color:Colors.white),
                        hintText: "Enter your abuse report here...",
                      ),
                    ),
                       SizedBox(height: 10),
             
            pickedImage!.path=="" ? ElevatedButton(
                onPressed: _pickImage,
                child: Text("Select Image"),
              ):Container(
                width: 200,height:200,child:Image.file(File(pickedImage!.path),)),
                  ],
                  
                ),
              ),                    SizedBox(height: 20,),

           
              GestureDetector(
                onTap: () async {
                  // Upload _videoFile and _abuseController.text to Firestore
                  // You can use Firebase Storage for video/image uploads
                  final String? imageUrl = await _pickImage();
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUser!.uid)
                      .collection("abuse_reports")
                      .add({
                    "message": _abuseController.text,
                    "phone": widget.phone,
                    "timestamp": FieldValue.serverTimestamp(),
                    "imageUrl": imageUrl,
                  });
                  _abuseController.clear();
                  setState(() {
                    _videoFile = null;
                      pickedImage!.path=="" ;
                  });
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(currentUser!.uid)
                    .collection("abuse_reports")
                    .snapshots(),
                builder: (context, snapshot) {
                  return snapshot.data == null
                      ? Container()
                      : ListView.separated(
                          separatorBuilder: (ctx, i) => SizedBox(
                                height: 10,
                              ),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, i) {
                            var data = snapshot.data?.docs;
                            return AbuseReportWidget(
                              phone: data![i]["phone"],
                              message: data![i]["message"],
                              imageUrl: data![i]["imageUrl"],
                            );
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AbuseReportWidget extends StatelessWidget {
  final String phone;
  final String message;
  final String? imageUrl;

  AbuseReportWidget(
      {required this.phone, required this.message, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue.withOpacity(0.3),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Align(
          alignment: Alignment.topCenter,
           child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             const SizedBox(
              height: 15,
            ),
            const Text(
              "Abuse Report",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              message,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              // abuse image here
            ),
           ],),
         ),
          if (imageUrl != null)
            ClipRRect(
              borderRadius:BorderRadius.circular(10),
              child: Image.network(imageUrl!,height: 100,)),
            
        ],
      ),
    );
  }
}
