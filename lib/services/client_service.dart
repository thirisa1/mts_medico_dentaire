import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/client.dart';

class ClientService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'users';

  // Récupère tous les clients pro en attente + tous les autres
  static Future<List<Client>> fetchClients() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Client.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[ClientService] Erreur: ${e.message}');
      return [];
    }
  }

  // Valider un compte professionnel
  static Future<void> verifyClient(String clientId) async {
    await _db.collection(_collection).doc(clientId).update({
      'verified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }

  // Rejeter/supprimer une demande
  static Future<void> rejectClient(String clientId) async {
    await _db.collection(_collection).doc(clientId).update({
      'rejected': true,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}