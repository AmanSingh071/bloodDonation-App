import 'package:flutter/material.dart';

class Dialogs {
  static void showsnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue,
      elevation: 1,
    ));
  }

  static void showprogressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => Center(child: CircularProgressIndicator()));
  }
}
