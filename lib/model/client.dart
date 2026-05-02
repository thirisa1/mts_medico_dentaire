import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role; // 'professionnel' ou 'autre'
  final String justificatif; // URL du fichier
  final bool verified;
  final DateTime? createdAt;

  const Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.justificatif,
    required this.verified,
    this.createdAt,
  });

  String get fullName => '$prenom $nom';
  bool get isPro => role == 'professionnel';

  factory Client.fromFirestore(Map<String, dynamic> d, String id) {
    return Client(
      id: id,
      nom: d['nom'] ?? '',
      prenom: d['prenom'] ?? '',
      email: d['email'] ?? '',
      telephone: d['telephone'] ?? '',
      role: d['role'] ?? 'autre',
      justificatif: d['justificatif'] ?? '',
      verified: d['verified'] ?? false,
      createdAt:
          d['createdAt'] != null
              ? (d['createdAt'] as Timestamp).toDate()
              : null,
    );
  }
}

List<Client> kClients = [];
