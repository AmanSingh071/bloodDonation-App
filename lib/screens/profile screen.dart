import 'dart:async';
import 'dart:convert';

import 'dart:developer';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/helper/dialogs.dart';
import 'package:flutter_application_1/models/chatuser.dart';
import 'package:flutter_application_1/screens/auth/loginscreen.dart';
import 'package:flutter_application_1/widgets/chat_user_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class profilescreen extends StatefulWidget {
  final Chatuser user;
  const profilescreen({super.key, required this.user});

  @override
  State<profilescreen> createState() => _profilescreenState();
}

class _profilescreenState extends State<profilescreen> {
  String? _image;
  final formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Game ',
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            await apis.auth.signOut();
            await GoogleSignIn().signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const loginscreen()));
          },
          icon: Icon(Icons.logout),
          label: Text('Logout'),
        ),
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 170),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.file(
                                  File(_image!),
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: CachedNetworkImage(
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            //chaneg image button
                            elevation: 1,
                            shape: CircleBorder(),
                            color: Colors.white,
                            onPressed: () {
                              bottomsheet();
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Text(
                      widget.user.email,
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ),
                  Container(
                    width: 370,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 60,
                      ),
                      child: TextFormField(
                        initialValue: widget.user.name,
                        onSaved: (newValue) => apis.me.name = newValue ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'eg: Aman Singh',
                            label: Text('Name')),
                      ),
                    ),
                  ),
                  Container(
                    width: 370,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 27,
                      ),
                      child: TextFormField(
                        initialValue: widget.user.about,
                        onSaved: (newValue) => apis.me.about = newValue ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'eg:Feeling good',
                            label: Text('About')),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(), minimumSize: Size(150, 50)),
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            formkey.currentState!.save();
                            Dialogs.showprogressbar(context);
                            apis.updateuserinfo().then((value) => {
                                  Navigator.pop(context),
                                  Dialogs.showsnackbar(
                                      context, 'profile updated successfully')
                                });
                            log('inside validator');
                          }
                        },
                        icon: Icon(Icons.edit),
                        label: Text(
                          'UPDATE',
                          style: TextStyle(fontSize: 16),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // bottom sheet for showing picking image
  void bottomsheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 30, bottom: 30),
            children: [
              Text(
                'Pick profile image',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(100, 100)),
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();

                        final image = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (image == null) return;

                        setState(() {
                          this._image = image.path;
                        });
                        apis.updateprofilepic(File(_image!)).then((value) {
                          Dialogs.showsnackbar(
                              context, 'Profile Image Updated');
                        });
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      },
                      child: Image.asset('images/image.png')),
                  //gallery
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(100, 100)),
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();

                        final XFile? image = await imagePicker.pickImage(
                            source: ImageSource.camera);
                        if (image == null) return;

                        setState(() {
                          _image = image.path;
                          Dialogs.showprogressbar(context);
                        });

                        apis.updateprofilepic(File(_image!)).then((value) {
                          Dialogs.showsnackbar(
                              context, 'Profile Image Updated');
                        });
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      },
                      child: Image.asset('images/camera.png'))
                  //camera
                ],
              )
            ],
          );
        });
  }
}
// 