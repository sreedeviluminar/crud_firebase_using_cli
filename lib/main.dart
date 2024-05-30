import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newfireproject/firebase_options.dart';

import 'firbaseCrud.dart';
import 'firebase_image_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
  //home: FireBaseCrud(),
    home: ImgStorage(),
  ));
}