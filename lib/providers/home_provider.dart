import 'package:passenger/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger/constants/firestore_constants.dart';
import 'package:passenger/models/models.dart';
import 'dart:async';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Future<void> removeDataFirestore(String collectionPath, String path) {
    return firebaseFirestore.collection(collectionPath).doc(path).delete();
  }

  Future<void> addTrip(Trip trip) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathTripCollection)
        .add({
      FirestoreConstants.user: trip.user,
      FirestoreConstants.country: trip.country,
      FirestoreConstants.location: trip.location,
      FirestoreConstants.description: trip.description,
      FirestoreConstants.creationDate: trip.creationDate,
      FirestoreConstants.startDate: trip.startDate,
      FirestoreConstants.endDate: trip.endDate,
    });
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
      // return firebaseFirestore
      //     .collection(pathCollectionUsers)
      //     .orderBy(FirestoreConstants.nickname)
      //     .startAt([textSearch]).endAt([textSearch + '\uf8ff']).snapshots();
      return firebaseFirestore
          .collection(pathCollectionUsers)
          .where("id", whereIn: listofids)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollectionUsers)
          .where('id', whereIn: listofids)
          .snapshots();
    }
  }
}
