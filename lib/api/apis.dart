import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/chatuser.dart';
import 'package:flutter_application_1/models/message.dart';

class apis {
  static late Chatuser me;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;

  static Future<bool> userexists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getselfinfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = Chatuser.fromJson(user.data()!);
      } else {
        await createuser().then((value) => getselfinfo());
      }
    });
  }

  static Future<void> createuser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = Chatuser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "hey hellllo",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getallusers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateuserinfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateprofilepic(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profileimg/${user.uid}');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

//chat (collection)-->conversation_id(doc)-->messages(collection)-->message(doc)

  static String getconversationid(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

//get all messges
  static Stream<QuerySnapshot<Map<String, dynamic>>> getallmessages(
      Chatuser user) {
    return firestore
        .collection('chats/${getconversationid(user.id)}/messages/')
        .snapshots();
    //for sending messages
  }

  static Future<void> sendmessage(Chatuser chatuser, String msg) async {
    final time = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); //message sending time (also used as id)
//message to send
    final Message message = Message(
        msg: msg,
        formid: user.uid,
        read: '',
        told: chatuser.id,
        type: Type.text,
        sent: time);
    final ref = firestore
        .collection('chats/${getconversationid(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updatemessagereadstatus(Message message) async {
    firestore
        .collection('chats/${getconversationid(message.formid)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

//get last message only one
  static Stream<QuerySnapshot<Map<String, dynamic>>> getlastmessages(
      Chatuser user) {
    return firestore
        .collection('chats/${getconversationid(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
    //for sending messages
  }
}
