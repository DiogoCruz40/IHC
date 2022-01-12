import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger/constants/firestore_constants.dart';
import 'dart:async';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, Object> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Future<void> removeDataFirestore(String collectionPath, String path) {
    return firebaseFirestore.collection(collectionPath).doc(path).delete();
  }

  Future<void> addDataFirestore(
      String collectionPath, Map<String, Object> newData) {
    return firebaseFirestore.collection(collectionPath).add(newData);
  }

  Future<void> addDataByIdFirestore(
      String collectionPath, String path, Map<String, String> newData) {
    return firebaseFirestore.collection(collectionPath).doc(path).set(newData);
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String? textSearch) {
    if (textSearch != null && textSearch.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .orderBy(FirestoreConstants.nickname)
          .startAt([textSearch]).endAt([textSearch + '\uf8ff']).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).snapshots();
    }
  }

  Stream<QuerySnapshot> getStreamMessagesFireStore(String pathCollection) {
    return firebaseFirestore.collection(pathCollection).snapshots();
  }

  Stream<QuerySnapshot> getStreamUsersFireStore(List listofids,
      String pathCollectionUsers, String currentuserid, String? textSearch) {
    // var documentreference = await firebaseFirestore
    //     .collection(FirestoreConstants.pathMessageCollection)
    //     .get();

    // List<String> docsids = List.empty(growable: true);
    // List docsidsto = List.empty(growable: true);
    // documentreference.docs.forEach((doc) => docsids.add(doc.id));

    // for (var i = 0; i < docsids.length; i++) {
    //   if (docsids.elementAt(i).contains(currentuserid)) {
    //     //print(docsids.elementAt(i));
    //     if (docsids.elementAt(i).split("-").first == currentuserid) {
    //       docsidsto.add(docsids.elementAt(i).split("-").last.toString());
    //     } else {
    //       docsidsto.add(docsids.elementAt(i).split("-").first.toString());
    //     }
    //   }
    // }
    //print(docsidsto);
    if (textSearch != null && textSearch.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollectionUsers)
          .orderBy(FirestoreConstants.nickname, descending: false)
          .where(
            FirestoreConstants.nickname,
            isGreaterThanOrEqualTo: textSearch,
            isLessThan: textSearch.substring(0, textSearch.length - 1) +
                String.fromCharCode(
                    textSearch.codeUnitAt(textSearch.length - 1) + 1),
          )
          .where("id", whereIn: listofids)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollectionUsers)
          .orderBy(FirestoreConstants.nickname, descending: false)
          .where('id', whereIn: listofids)
          .snapshots();
    }
  }
}
