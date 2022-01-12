import 'package:Passenger/models/models.dart';
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
          .orderBy(FirestoreConstants.nickname)
          .startAt([textSearch]).endAt([textSearch + '\uf8ff']).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).snapshots();
    }
  }

  // void getpeersids(
  //   String currentuserid,
  // ) {
  //   List listids = [];
  //   firebaseFirestore
  //       .collection(FirestoreConstants.pathMessageCollection)
  //       .get()
  //       .then((value) => {
  //             value.docs.forEach((doc) {
  //               print(doc.id);
  //             })
  //           });
  // }

  // Stream<QuerySnapshot> getStreamUsersFireStore(String pathCollectionMessages,
  //     String pathCollectionUsers, String currentuserid, String? textSearch) {
  //   if (textSearch != null && textSearch.isNotEmpty == true) {
  //     return firebaseFirestore
  //         .collection(pathCollectionUsers)
  //         .orderBy(FirestoreConstants.nickname)
  //         .startAt([textSearch]).endAt([textSearch + '\uf8ff']).snapshots();
  //   } else {
  //     return firebaseFirestore.collection(pathCollectionUsers).snapshots();
  //   }
  // }
}
