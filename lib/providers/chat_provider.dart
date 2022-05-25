import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/models/models.dart';
import 'package:passenger/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({
    required this.firebaseFirestore,
    required this.prefs,
    required this.firebaseStorage,
  });

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
    var docuserto = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(peerId)
        .get();

    var docuserfrom = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(currentUserId)
        .get();

    if (docuserto.get('chattingWith').toString() != currentUserId) {
      sendNotificationToDriver(
          docuserto.get('pushToken'), content, docuserfrom);
    }
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}

sendNotificationToDriver(
    String token, String content, DocumentSnapshot docfrom) async {
  if (token == null) {
    print('Unable to send FCM message, no token exists.');
    return;
  }

  try {
    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAA4OMxGBI:APA91bEkUa2-ce9MIslQsKsChiQl6kOXsyUo3BfwFRUWvq0PswpBEPhFHdnBAszF_oBAm17NDicXEv-PpgjAddnsCTaKiSiO5AxYz9Xax6iTxv311M80a90OXByUX7eLBxNZIN7ghZ9a',
      },
      body: constructFCMPayload(token, content, docfrom),
    );
    // print('FCM request for device sent!');
    // print(response.statusCode);
  } catch (e) {
    print(e);
  }
}

String constructFCMPayload(
    String token, String content, DocumentSnapshot docfrom) {
  var res = jsonEncode({
    'notification': {
      "body": "${docfrom.get('nickname')} disse: $content",
      "title": "${docfrom.get('nickname')}",
      "sound": "default",
      "badge": 1
    },
    "priority": "high",
    'data': {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "name": "${docfrom.get('nickname')}",
      "user_id": docfrom.id,
      "user_photo": "${docfrom.get('photoUrl')}",
      "screen": "open",
      // "screen": "ChatPage(peerAvatar: , peerNickname: ,peerId: )",
      // "ride_request_id": rideRequestId,
    },
    'to': token,
  });

  // print(res.toString());
  return res;
}
