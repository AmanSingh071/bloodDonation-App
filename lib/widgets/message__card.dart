import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/helper/my_date.dart';
import 'package:flutter_application_1/models/message.dart';

class messagecard extends StatefulWidget {
  final Message message;
  const messagecard({super.key, required this.message});

  @override
  State<messagecard> createState() => _messagecardState();
}

class _messagecardState extends State<messagecard> {
  @override
  Widget build(BuildContext context) {
    return apis.user.uid == widget.message.formid
        ? greenmessage()
        : bluemssage();
  }

  Widget greenmessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                mydateutil.getformatedtime(
                    context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: Color.fromARGB(255, 171, 231, 169),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget bluemssage() {
    if (widget.message.read.isNotEmpty) {
      apis.updatemessagereadstatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                color: Color.fromARGB(255, 221, 245, 255),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            mydateutil.getformatedtime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }
}
