import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/loginscreen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

class splahscreen extends StatefulWidget {
  const splahscreen({super.key});

  @override
  State<splahscreen> createState() => _splahscreenState();
}

class _splahscreenState extends State<splahscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => loginscreen()));
    });
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
              width: 200,
              height: 200,
              top: 40,
              child: Image.asset('images/blood.jpeg')),
          Positioned(
              width: 250,
              height: 40,
              top: 400,
              child: Text(
                "Donate Blood",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 255, 0, 0),
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              width: 250,
              height: 40,
              top: 430,
              child: Text(
                "Save Life",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 255, 0, 0),
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              width: 250,
              height: 40,
              top: 480,
              child: Text(
                "Made by AMAN SINGH",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 88, 87, 87),
                    fontWeight: FontWeight.normal),
              )),
        ],
      ),
    );
  }
}
// 