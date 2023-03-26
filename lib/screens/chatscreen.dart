import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_1/api/apis.dart';
import 'package:flutter_application_1/models/chatuser.dart';
import 'package:flutter_application_1/models/message.dart';

import '../widgets/message__card.dart';

class chatscreen extends StatefulWidget {
  final Chatuser user;
  const chatscreen({super.key, required this.user});

  @override
  State<chatscreen> createState() => _chatscreenState();
}

class _chatscreenState extends State<chatscreen> {
  List<Message> _list = [];
  bool emojiopressed = false;
  final textcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            // will make sure app doesnt close when search is enabled
            if (emojiopressed) {
              setState(() {
                emojiopressed = !emojiopressed;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: apis.getallmessages(widget.user),
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
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _list.length,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return messagecard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              return Center(
                                  child: Text('Say Hi to user .......'));
                            }
                        }
                      }),
                ),
                chatinput(),
                if (emojiopressed)
                  SizedBox(
                    height: 300,
                    child: EmojiPicker(
                      textEditingController:
                          textcontroller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]

                      config: Config(
                        columns: 8,
                        initCategory: Category.SMILEYS,
                        bgColor: Color.fromARGB(255, 234, 248, 255),

                        emojiSizeMax: 32 *
                            (Platform.isAndroid
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
          ),
        ),
      ),
    );
  }

  Widget chatinput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        emojiopressed = !emojiopressed;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions),
                    color: Colors.blue,
                  ),
                  Expanded(
                      child: TextField(
                    controller: textcontroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (emojiopressed)
                        setState(() {
                          emojiopressed = !emojiopressed;
                        });
                    },
                    decoration: InputDecoration(
                        hintText: 'Type something...',
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none),
                  )),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image),
                    color: Colors.blue,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
              minWidth: 0,
              padding: EdgeInsets.all(10),
              shape: CircleBorder(),
              color: Colors.green,
              onPressed: () {
                if (textcontroller.text.isNotEmpty) {
                  apis.sendmessage(widget.user, textcontroller.text);
                  textcontroller.text = '';
                }
              },
              child: Icon(Icons.send, color: Colors.white, size: 28))
        ],
      ),
    );
  }

  Widget _appbar() {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)),
        ClipRRect(
          borderRadius: BorderRadius.circular(70),
          child: CachedNetworkImage(
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            imageUrl: widget.user.image,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "last time not available",
              style: TextStyle(
                  fontSize: 12, color: Color.fromARGB(255, 71, 70, 70)),
            )
          ],
        )
      ],
    );
  }
}
