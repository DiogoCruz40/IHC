import 'package:passenger/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger/constants/firestore_constants.dart';
import 'package:passenger/utils/utils.dart';

class SearchProvider {
  final FirebaseFirestore firebaseFirestore;

  SearchProvider({required this.firebaseFirestore});

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

  Future<void> addDataFirestore(
      String collectionPath, Map<String, Object> newData) {
    return firebaseFirestore.collection(collectionPath).add(newData);
  }

  Future<void> addDataByIdFirestore(
      String collectionPath, String path, Map<String, String> newData) {
    return firebaseFirestore.collection(collectionPath).doc(path).set(newData);
  }

  Future<void> removeFavourite(String tripId, String userId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathTripCollection)
        .doc(tripId)
        .collection(FirestoreConstants.users)
        .doc(userId)
        .delete();
  }

  Future<void> addFavourite(String tripId, String userId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathTripCollection)
        .doc(tripId)
        .collection(FirestoreConstants.users)
        .doc(userId)
        .set({FirestoreConstants.id: userId});
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int? limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true && limit != null) {
      textSearch = textSearch?.toTitleCase();
      return firebaseFirestore
          .collection(pathCollection)
          .orderBy(FirestoreConstants.location)
          .startAt([textSearch]).endAt([textSearch! + '\uf8ff']).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).snapshots();
    }
  }

  Stream<DocumentSnapshot> getFavourite(String tripId, String userId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathTripCollection)
        .doc(tripId)
        .collection(FirestoreConstants.users)
        .doc(userId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getDocumentFireStore(
      String collectionPath, String docId) {
    return firebaseFirestore.collection(collectionPath).doc(docId).snapshots();
  }

  Stream<DocumentSnapshot> getUserFirestore(String pathCollection, String id) {
    return firebaseFirestore.collection(pathCollection).doc(id).snapshots();
  }
}
