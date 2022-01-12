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

  Future<DocumentSnapshot?> getDocumentFireStore(
      String collectionPath, String docId) {
    return firebaseFirestore.collection(collectionPath).doc(docId).get();
  }

  Stream<DocumentSnapshot> getUserFirestore(String pathCollection, String id) {
    return firebaseFirestore.collection(pathCollection).doc(id).snapshots();
  }
}
