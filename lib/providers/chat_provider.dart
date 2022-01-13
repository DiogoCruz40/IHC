import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

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
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
