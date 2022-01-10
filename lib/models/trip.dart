import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Passenger/constants/constants.dart';

class Trip {
  String id; // Id da Viagem
  String user; // Viajante
  String country; // País
  String location; // Localização
  String description; // Descrição
  DateTime creationDate; // Data de Criação
  DateTime startDate; // Data de Início
  DateTime endDate; // Data de Fim
  //List<Favourite> users;

  Trip({
    required this.id,
    required this.user,
    required this.country,
    required this.location,
    required this.description,
    required this.creationDate,
    required this.startDate,
    required this.endDate,
    //required this.users,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.user: user,
      FirestoreConstants.country: country,
      FirestoreConstants.location: location,
      FirestoreConstants.description: description,
      FirestoreConstants.creationDate: creationDate,
      FirestoreConstants.startDate: startDate,
      FirestoreConstants.endDate: endDate,
      //FirestoreConstants.users: users,
    };
  }

  factory Trip.fromDocument(DocumentSnapshot doc) {
    String id = doc.get(FirestoreConstants.id);
    String user = doc.get(FirestoreConstants.user);
    String country = doc.get(FirestoreConstants.country);
    String location = doc.get(FirestoreConstants.location);
    String description = doc.get(FirestoreConstants.description);
    DateTime creationDate = doc.get(FirestoreConstants.creationDate);
    DateTime startDate = doc.get(FirestoreConstants.startDate);
    DateTime endDate = doc.get(FirestoreConstants.endDate);
    return Trip(
        id: id,
        user: user,
        country: country,
        location: location,
        description: description,
        creationDate: creationDate,
        startDate: startDate,
        endDate: endDate);
  }
}
