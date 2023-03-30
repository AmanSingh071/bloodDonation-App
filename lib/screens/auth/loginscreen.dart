import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/helper/dialogs.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

import '../mainhomescreen.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  onhandlebtngoogleclick() {
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (_) => const homescreen()));
    Dialogs.showprogressbar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context); //for hiding progress bar
      if (user != null) {
        if ((await apis.userexists())) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const mainhomescreen()));
        } else {
          await apis.createuser().then((value) async {
            await apis.setlocation();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const mainhomescreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('signInWithGoogle $e');
      Dialogs.showsnackbar(context, 'something went wrong check internet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Blood Donation APP ',
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              width: 400,
              height: 800,
              bottom: 190,
              child: Image.asset('images/blood_donate.png')),
          Positioned(
              width: 250,
              height: 40,
              top: 400,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 0, 0),
                      shape: StadiumBorder()),
                  onPressed: () {
                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (_) => homescreen()));
                    onhandlebtngoogleclick();
                  },
                  icon: Image.asset(
                    'images/google.png',
                    height: 30,
                  ),
                  label: Text('Login in with google'))),
        ],
      ),
    );
  }
}
// 