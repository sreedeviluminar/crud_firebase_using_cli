import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newfireproject/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    home: FireBaseCrud(),
  ));
}

class FireBaseCrud extends StatefulWidget {
  @override
  State<FireBaseCrud> createState() => _FireBaseCrudState();
}

class _FireBaseCrudState extends State<FireBaseCrud> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  late CollectionReference _userCollection;

  @override
  void initState() {
    _userCollection = FirebaseFirestore
                .instance.collection("users");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text("Add User Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: "Name", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {
                addUser();
              },
              minWidth: 100,
              color: Colors.pink,
              shape: const StadiumBorder(),
              child: const Text("Add User"),
            )
          ],
        ),
      ),
    );
  }
  Future<void> addUser() {
    return _userCollection
        .add({'name': nameController.text,
              'email': emailController.text}).then((value) {
      print("User Added Successfully");
      nameController.clear();
      emailController.clear();
    }).catchError((error) {
      print("Failed to Add user :$error");
    });
  }
}
