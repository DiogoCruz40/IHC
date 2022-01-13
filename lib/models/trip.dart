import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passenger/constants/constants.dart';

class Trip {
  String id; // Id da Viagem
  String user; // Viajante
  String country; // País
  String location; // Localização
  String description; // Descrição
  String photoUrl; // foto
  Timestamp creationDate; // Data de Criação
  Timestamp startDate; // Data de Início
  Timestamp endDate; // Data de Fim

  Trip({
    required this.id,
    required this.user,
    required this.country,
    required this.location,
    required this.description,
    required this.photoUrl,
    required this.creationDate,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.user: user,
      FirestoreConstants.country: country,
      FirestoreConstants.location: location,
      FirestoreConstants.description: description,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.creationDate: creationDate,
      FirestoreConstants.startDate: startDate,
      FirestoreConstants.endDate: endDate,
    };
  }

  factory Trip.fromDocument(DocumentSnapshot doc) {
    String id = doc.id;
    String user = doc.get(FirestoreConstants.user);
    String country = doc.get(FirestoreConstants.country);
    String location = doc.get(FirestoreConstants.location);
    String description = doc.get(FirestoreConstants.description);
    String photoUrl = "";
    Timestamp creationDate = doc.get(FirestoreConstants.creationDate);
    Timestamp startDate = doc.get(FirestoreConstants.startDate);
    Timestamp endDate = doc.get(FirestoreConstants.endDate);

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}

    return Trip(
        id: id,
        user: user,
        country: country,
        location: location,
        description: description,
        photoUrl: photoUrl,
        creationDate: creationDate,
        startDate: startDate,
        endDate: endDate);
  }
}
