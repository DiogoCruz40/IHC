import 'package:passenger/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger/constants/firestore_constants.dart';
import 'package:passenger/models/models.dart';
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

  //TODO remove addTrip, it will be replaced by addDataFirestore
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

  //TODO remove updateTrip, it will be replaced by updateDataFirestore
  Future<void> updateTrip(Trip trip) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathTripCollection)
        .doc(trip.id)
        .update({
      FirestoreConstants.country: trip.country,
      FirestoreConstants.location: trip.location,
      FirestoreConstants.description: trip.description,
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

  void getpeersids(
    String currentuserid,
  ) async {
    List listids = List.empty(growable: true);

    var getids = await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .get()
        .then((values) => values.docs.forEach((value) => print(value.id)));

    //print('passei $listids');
  }

  Stream<QuerySnapshot> getStreamUsersFireStore(String pathCollectionMessages,
      String pathCollectionUsers, String currentuserid, String? textSearch) {
    getpeersids(currentuserid);

    if (textSearch != null && textSearch.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollectionUsers)
          .orderBy(FirestoreConstants.nickname)
          .startAt([textSearch]).endAt([textSearch + '\uf8ff']).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollectionUsers).snapshots();
    }
  }
}
