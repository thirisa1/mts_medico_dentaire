import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// Résultat de la vérification de paiement
// ─────────────────────────────────────────────
enum PaymentStatus {
  success,           // Paiement validé
  cardNotFound,      // Carte introuvable dans la BDD
  wrongCvv,          // CVV incorrect
  cardExpired,       // Carte expirée
  insufficientFunds, // Solde insuffisant
  error,             // Erreur technique
}

class PaymentResult {
  final PaymentStatus status;
  final String? message;
  final double? soldeActuel;

  const PaymentResult({
    required this.status,
    this.message,
    this.soldeActuel,
  });

  bool get isSuccess => status == PaymentStatus.success;
}

// ─────────────────────────────────────────────
// PaymentService
// Collection Firestore : comptesBancaires
// Document structure :
//   numeroCarte     : String (16 chiffres)
//   cvv             : String (3-4 chiffres)
//   dateExpiration  : String (MM/AA)
//   solde           : double
//   proprietaire    : String (optionnel)
//   createdAt       : Timestamp
// ─────────────────────────────────────────────
class PaymentService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'comptesBancaires';

  /// Vérifie la carte et effectue le paiement si tout est valide.
  /// Retourne un [PaymentResult] avec le statut et un message.
  static Future<PaymentResult> processPayment({
    required String numeroCarte,    // sans espaces
    required String cvv,
    required String dateExpiration, // format MM/AA
    required double montant,
  }) async {
    try {
      // 1. Chercher le compte par numéro de carte
      final snap = await _db
          .collection(_collection)
          .where('numeroCarte', isEqualTo: numeroCarte)
          .limit(1)
          .get();

      // Carte introuvable
      if (snap.docs.isEmpty) {
        debugPrint('[PaymentService] ❌ Carte introuvable: $numeroCarte');
        return const PaymentResult(
          status: PaymentStatus.cardNotFound,
          message: 'Ce numéro de carte bancaire n\'existe pas dans notre système.',
        );
      }

      final doc = snap.docs.first;
      final data = doc.data();

      // 2. Vérifier CVV
      final cvvBdd = (data['cvv'] as String? ?? '').trim();
      if (cvv.trim() != cvvBdd) {
        debugPrint('[PaymentService] ❌ CVV incorrect');
        return const PaymentResult(
          status: PaymentStatus.wrongCvv,
          message: 'Le code CVV est incorrect.',
        );
      }

      // 3. Vérifier date d'expiration
      final expiryBdd = (data['dateExpiration'] as String? ?? '').trim();
      if (!_isCardValid(expiryBdd)) {
        debugPrint('[PaymentService] ❌ Carte expirée: $expiryBdd');
        return const PaymentResult(
          status: PaymentStatus.cardExpired,
          message: 'Cette carte bancaire est expirée.',
        );
      }

      // 4. Vérifier solde
      final solde = (data['solde'] ?? 0).toDouble();
      if (solde < montant) {
        debugPrint(
            '[PaymentService] ❌ Solde insuffisant: $solde DA < $montant DA');
        return PaymentResult(
          status: PaymentStatus.insufficientFunds,
          message:
              'Solde insuffisant. Solde disponible : ${solde.toStringAsFixed(0)} DA, '
              'montant requis : ${montant.toStringAsFixed(0)} DA.',
          soldeActuel: solde,
        );
      }

      // 5. Déduire le montant du solde
      final nouveauSolde = solde - montant;
      await _db.collection(_collection).doc(doc.id).update({
        'solde': nouveauSolde,
        'dernierPaiement': FieldValue.serverTimestamp(),
        'dernierMontantDebite': montant,
      });

      debugPrint(
          '[PaymentService] ✅ Paiement réussi. '
          'Solde: $solde → $nouveauSolde DA');

      return PaymentResult(
        status: PaymentStatus.success,
        message: 'Paiement effectué avec succès.',
        soldeActuel: nouveauSolde,
      );
    } on FirebaseException catch (e) {
      debugPrint('[PaymentService] ❌ Erreur Firebase: ${e.message}');
      return PaymentResult(
        status: PaymentStatus.error,
        message: 'Erreur technique : ${e.message}',
      );
    } catch (e) {
      debugPrint('[PaymentService] ❌ Erreur inattendue: $e');
      return PaymentResult(
        status: PaymentStatus.error,
        message: 'Une erreur inattendue s\'est produite.',
      );
    }
  }

  /// Vérifie si une carte est encore valide selon sa date d'expiration (MM/AA)
  static bool _isCardValid(String dateExpiration) {
    try {
      final parts = dateExpiration.split('/');
      if (parts.length != 2) return false;
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      final now = DateTime.now();
      // La carte est valide jusqu'à la fin du mois d'expiration
      final expiry = DateTime(2000 + year, month + 1);
      return expiry.isAfter(now);
    } catch (_) {
      return false;
    }
  }

  /// Créer un compte bancaire de test (utile pour les tests en dev)
  static Future<void> createTestAccount({
    required String numeroCarte,
    required String cvv,
    required String dateExpiration,
    required double solde,
    String proprietaire = 'Compte Test',
  }) async {
    await _db.collection(_collection).add({
      'numeroCarte': numeroCarte,
      'cvv': cvv,
      'dateExpiration': dateExpiration,
      'solde': solde,
      'proprietaire': proprietaire,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[PaymentService] ✅ Compte test créé: $numeroCarte');
  }
}