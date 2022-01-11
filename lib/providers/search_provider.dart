import 'package:Passenger/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Passenger/constants/firestore_constants.dart';
import 'package:flutter/material.dart';

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
      String pathCollection, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      textSearch = textSearch?.toTitleCase();
      return firebaseFirestore
          .collection(pathCollection)
          .orderBy(FirestoreConstants.location)
          .startAt([textSearch]).endAt([textSearch! + '\uf8ff']).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).snapshots();
    }
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}