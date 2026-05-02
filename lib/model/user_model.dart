import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String idUser;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role;
  final String? justificatif;
  final bool verified;
  final DateTime? createdAt;

  const UserModel({
    required this.idUser,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    this.justificatif,
    required this.verified,
    this.createdAt,
  });

  // ── Getters ──
  String get fullName => '$prenom $nom';
  bool get isPro => role == 'professionnel';
  bool get isAutre => role == 'autre';

  // ── Depuis Firestore ──
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      idUser: doc.id,
      nom: d['nom'] ?? '',
      prenom: d['prenom'] ?? '',
      email: d['email'] ?? '',
      telephone: d['telephone'] ?? '',
      role: d['role'] ?? 'autre',
      justificatif: d['justificatif'],
      verified: d['verified'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── Depuis Map (pour ClientService) ──
  factory UserModel.fromMap(Map<String, dynamic> d, String id) {
    return UserModel(
      idUser: id,
      nom: d['nom'] ?? '',
      prenom: d['prenom'] ?? '',
      email: d['email'] ?? '',
      telephone: d['telephone'] ?? '',
      role: d['role'] ?? 'autre',
      justificatif: d['justificatif'],
      verified: d['verified'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── Vers Firestore ──
  Map<String, dynamic> toFirestore() => {
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'telephone': telephone,
    'role': role,
    'justificatif': justificatif,
    'verified': verified,
    'createdAt': FieldValue.serverTimestamp(),
  };

  // ── CopyWith ──
  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? role,
    String? justificatif,
    bool? verified,
  }) {
    return UserModel(
      idUser: idUser,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      justificatif: justificatif ?? this.justificatif,
      verified: verified ?? this.verified,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $idUser, email: $email, role: $role, verified: $verified)';
}