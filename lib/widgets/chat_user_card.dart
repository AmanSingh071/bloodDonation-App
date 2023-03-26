import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/helper/my_date.dart';
import 'package:flutter_application_1/models/chatuser.dart';
import 'package:flutter_application_1/models/message.dart';

import '../screens/chatscreen.dart';

class chatusercard extends StatefulWidget {
  final Chatuser user;
  const chatusercard({super.key, required this.user});

  @override
  State<chatusercard> createState() => _chatusercardState();
}

class _chatusercardState extends State<chatusercard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            //navigating to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => chatscreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: apis.getlastmessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;

              final _list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (_list.isNotEmpty) {
                _message = _list[0];
              }

              return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      width: 40,
                      height: 40,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _message != null ? _message!.msg : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null
                      : //show nothing when no message is sent
                      _message!.read.isEmpty &&
                              _message!.formid != apis.user.uid
                          ? //show for unread message
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(mydateutil.getlastmessagetime(
                              context: context, time: _message!.sent)));
            },
          )),
    );
  }
}
