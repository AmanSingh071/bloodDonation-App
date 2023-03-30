import 'dart:async';
import 'dart:convert';

import 'dart:developer';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/helper/dialogs.dart';
import 'package:flutter_application_1/models/chatuser.dart';
import 'package:flutter_application_1/screens/auth/loginscreen.dart';
import 'package:flutter_application_1/screens/profile%20screen.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';
import 'package:flutter_application_1/widgets/chat_user_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class mainhomescreen extends StatefulWidget {
  const mainhomescreen({super.key});

  @override
  State<mainhomescreen> createState() => _mainhomescreenState();
}

class _mainhomescreenState extends State<mainhomescreen> {
  String imgurl = '';
  bool isloading = false;
  List<Chatuser> _list = [];
  List<Chatuser> _searchlist = [];
  Timer? _timer;
  String? mtoken = "";
  bool _issearching = false;

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    apis.getselfinfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // hide keyboard on tap on screen
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          // will make sure app doesnt close when search is enabled
          if (_issearching) {
            setState(() {
              _issearching = !_issearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _issearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name,Email....'),
                    autofocus: true,
                    style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchlist.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchlist.add(i);
                          setState(() {
                            _searchlist;
                          });
                        }
                      }
                    },
                  )
                : Text(
                    'Food Game ',
                  ),
            leading: Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _issearching = !_issearching;
                    });
                  },
                  icon: Icon(_issearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => profilescreen(user: apis.me)));
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(),
            child: FloatingActionButton(
              onPressed: () async {
                Dialogs.showprogressbar(context);
                await apis.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const loginscreen()));
                  });
                });
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
          body: StreamBuilder(
              stream: apis.getallusers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => Chatuser.fromJson(e.data()))
                            .toList() ??
                        [];

                    return ListView.builder(
                        itemCount:
                            _issearching ? _searchlist.length : _list.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return chatusercard(
                              user: _issearching
                                  ? _searchlist[index]
                                  : _list[index]);
                        });
                }
              }),
        ),
      ),
    );
  }
}
