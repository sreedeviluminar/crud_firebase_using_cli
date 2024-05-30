import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImgStorage extends StatefulWidget {
  @override
  State<ImgStorage> createState() => _ImgStorageState();
}

class _ImgStorageState extends State<ImgStorage> {
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("Store and Retrieve your Images"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (await Permission.camera.request().isGranted) {
                      open("camera");
                    } else {
                      print("Camera access denied");
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Camera"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: () async{
                    if(await Permission.storage.request().isGranted) {
                      open("gallery");
                    }else{
                      print("Gallery access denied");
                    }
                  },
                  icon: const Icon(Icons.photo_camera_back_outlined),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> open(String imgSource) async {
    final imgPicker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await imgPicker.pickImage(
          source:
              imgSource == "camera" ? ImageSource.camera : ImageSource.gallery);
      // path.basename  - extract only the image name from entire path
      final String imgFileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path); //actual path of image file

      try {
        await storage.ref(imgFileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              "uploadedby": "xxxxxx",
              "time": "${DateTime.now().isUtc}"
            }));
      } on FirebaseException catch (error) {
        print("Exception occured while uploading picture $error");
      }
    } catch (error) {
      print("Exception during File fetching $error");
    }
  }
}
