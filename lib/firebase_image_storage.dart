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
  Future<List<Map<String, dynamic>>>? _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = fetchImages();
  }

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
                  onPressed: () async {
                    if (await Permission.storage.request().isGranted) {
                      open("gallery");
                    } else {
                      print("Gallery access denied");
                    }
                  },
                  icon: const Icon(Icons.photo_camera_back_outlined),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
            const Divider(thickness: 3, color: Colors.black),
            Expanded(
              child: FutureBuilder(
                future: _imagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      //type casting future list of map to list of map
                      final images =
                          snapshot.data as List<Map<String, dynamic>>;
                      return GridView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                    child: Image.network(image['imageUrl'])),
                                Text(image['uploaded_by']),
                                Text("time: ${image['time']}"),
                                MaterialButton(
                                  onPressed: () => deleteImage(image['path']),
                                  minWidth: 100,
                                  color: Colors.red,
                                  shape: const StadiumBorder(),
                                  child: const Text('Delete'),
                                )
                              ],
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                      );
                    } else {
                      return const Center(child: Text('No images found'));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
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
      final String imgFileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        await storage.ref(imgFileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              "uploadedby": "xxxxxx",
              "time":
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n${DateTime.now().hour}:${DateTime.now().minute}"
            }));
        setState(() {
          _imagesFuture = fetchImages();
        });
      } on FirebaseException catch (error) {
        print("Exception occurred while uploading picture $error");
      }
    } catch (error) {
      print("Exception during file fetching $error");
    }
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    List<Map<String, dynamic>> images = [];
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach(allFiles, (singleFile) async {
      final String fileUrl = await singleFile.getDownloadURL();
      final FullMetadata metadata = await singleFile.getMetadata();

      images.add({
        'imageUrl': fileUrl,
        'path': singleFile.fullPath,
        'uploaded_by': metadata.customMetadata?['uploadedby'] ?? "NoData",
        'time': metadata.customMetadata?['time'] ?? "No Time"
      });
    });

    return images;
  }

  Future<void> deleteImage(String imagePath) async {
    await storage.ref(imagePath).delete();
    setState(() {
      _imagesFuture = fetchImages();
    });
  }
}
