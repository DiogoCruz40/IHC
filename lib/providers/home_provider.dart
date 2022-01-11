import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Passenger/constants/firestore_constants.dart';

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
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(path)
        .delete();
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String? textSearch) {
    if (textSearch != null && textSearch.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(
            FirestoreConstants.nickname,
            isGreaterThanOrEqualTo: textSearch,
            isLessThan: textSearch.substring(0, textSearch.length - 1) +
                String.fromCharCode(
                    textSearch.codeUnitAt(textSearch.length - 1) + 1),
          )
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .snapshots();
    }
  }
}
