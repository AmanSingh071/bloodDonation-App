import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/dialogs.dart';
import 'package:flutter_application_1/screens/auth/loginscreen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  String imgurl = '';
  bool isloading = false;
  Timer? _timer;
  String? mtoken = "";
  File? image;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    requestpermission();
    gettoken();

    // EasyLoading.removeCallbacks();
  }

  void requestpermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void gettoken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
      savetoken(token!);
    });
  }

  void savetoken(String token) async {
    await FirebaseFirestore.instance.collection("usertokens").doc("user2").set({
      'token': token,
    });
  }

  Future sendpushmessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAxvEI1bM:APA91bFbKCNQBTjWnTjltpcDMS50qZuRUimrn5cmBK9pdvB1kqwxduS1GzERu8rL3s2KjaDBKw2qbwNQWwKn6BhlwZEvhx36E6TjOKLNr_RtvytzO4AjyfvWDGIV9FT_43vOnyZWuvp4'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "dbfood"
            },
            "to": token,
          }));
      print('sucess ');
    } catch (e) {
      print('error caught: $e');
    }
  }

  Future pickimg() async {
    ImagePicker imagePicker = ImagePicker();

    final image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imagetemp = File(image.path);
    setState(() {
      this.image = imagetemp;
    });
  }

  Future mm() async {
    String name = "user2";
    String body = "this is notification title";
    String title = "text";

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("usertokens")
        .doc(name)
        .get();
    String token = snapshot['token'];
    sendpushmessage(token, body, title);
  }

  Future storeimage() async {
    Dialogs.showprogressbar(context);
    String filename = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referencRoot = FirebaseStorage.instance.ref();
    Reference referencedirimg = referencRoot.child('images');

    Reference refimgupload = referencedirimg.child(filename);

    await refimgupload.putFile(File(image!.path));
    imgurl = await refimgupload.getDownloadURL();
    EasyLoading.showSuccess('Uploaded');
    EasyLoading.dismiss();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Game ',
        ),
        leading: Icon(CupertinoIcons.home),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            Image.asset(
              'images/animal.png',
              height: 150,
            ),
            Container(
              width: 500,
              height: 520,
              child: Card(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(50)),
                color: Color.fromARGB(255, 212, 211, 211),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 240, left: 180),
                      child: FloatingActionButton(
                        heroTag: "btn1",
                        onPressed: () {
                          pickimg();
                        },
                        child: Icon(Icons.camera_alt_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 310, left: 140),
                      child: Title(
                          color: Colors.black,
                          child: Text(
                            'Click your meal',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 430, left: 180),
                      child: FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: () async {
                          storeimage();
                          mm();
                        },
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 100),
                      child: Container(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(210),
                              child: image != null
                                  ? Image.file(
                                      image!,
                                      width: 210,
                                      height: 210,
                                      fit: BoxFit.cover,
                                    )
                                  : FlutterLogo(
                                      size: 160,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.amber,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 640, right: 310),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const loginscreen()));
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
// 