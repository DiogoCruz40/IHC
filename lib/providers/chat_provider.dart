import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final FirebaseMessaging firebaseMessaging;
  ChatProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage,
      required this.firebaseMessaging});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String userid) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userid)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) async {
    await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .set({"id": groupChatId});

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );

      // await firebaseMessaging
      //     .sendMessage(
      //         to: 'cy1k9rH9Sjm2Uil-deHwFO:APA91bHXdoLKXWsTb4_2kIgN76olkL1iw7FUpfw_giangG0TkFKQHJCuJTLu8v3QCQWIqyJwpWx1vynh9uH378vtlYjDEoPNqn--L04yRQOFx0CpDhy3Cv-cmTqq7dYsNveDYclUbkKe@fcm.googleapis.com',
      //         data: {
      //           'title': 'You have a message from $currentUserId',
      //           'body': content,
      //           'badge': '1',
      //           'sound': 'default'
      //         },
      //         messageId: 'm-123',
      //         messageType: '1',
      //         ttl: 1,
      //         collapseKey: '123')
      //     .then((value) => print('message sucess'))
      //     .catchError((e) => print(e));
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
