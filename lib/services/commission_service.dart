import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CommissionService {
  static final _db  = FirebaseFirestore.instance;
  static const _col = 'commissions';

  static const double tauxAdmin = 0.15; // 15%
  static const double tauxVendeur = 0.85; // 85%

  /// Appelé après chaque commande confirmée.
  /// Calcule et enregistre les commissions pour chaque
  /// ligne produit qui a un vendeurId (produit pro).
  static Future<void> traiterCommissions({
    required String orderId,
    required String clientId,
    required List<Map<String, dynamic>> lignes,
  }) async {
    for (final ligne in lignes) {
      final productId = ligne['productId'] as String? ?? '';
      if (productId.isEmpty) continue;

      // Récupère le produit pour voir s'il a un vendeurId
      final prodDoc = await _db.collection('produits').doc(productId).get();
      if (!prodDoc.exists) continue;

      final prodData = prodDoc.data()!;
      final vendeurId = prodData['vendeurId'] as String?;
      if (vendeurId == null || vendeurId.isEmpty) continue;

      // C'est un produit vendeur → calculer commission
      final prix     = (ligne['prix']     ?? 0).toDouble();
      final quantite = (ligne['quantite'] ?? 1) as int;
      final total    = prix * quantite;

      final partAdmin   = double.parse((total * tauxAdmin).toStringAsFixed(2));
      final partVendeur = double.parse((total * tauxVendeur).toStringAsFixed(2));

      // Enregistrer la commission
      final commRef = await _db.collection(_col).add({
        'orderId':       orderId,
        'productId':     productId,
        'productNom':    prodData['nom'] ?? '',
        'vendeurId':     vendeurId,
        'vendeurNom':    prodData['vendeurNom'] ?? '',
        'clientId':      clientId,
        'prixUnitaire':  prix,
        'quantite':      quantite,
        'totalVente':    total,
        'partAdmin':     partAdmin,
        'partVendeur':   partVendeur,
        'statut':        'en_attente', // → 'versé' quand payé
        'createdAt':     FieldValue.serverTimestamp(),
      });

      debugPrint('[CommissionService] ✅ Commission créée: '
          '${commRef.id} — Admin: $partAdmin DA | Vendeur: $partVendeur DA');

      // Créditer le solde du vendeur dans Firestore
      await _crediterVendeur(vendeurId, partVendeur, commRef.id);

      // Notifier le vendeur
      await _notifierVendeur(
        vendeurId:    vendeurId,
        productNom:   prodData['nom'] ?? '',
        totalVente:   total,
        partVendeur:  partVendeur,
        partAdmin:    partAdmin,
        orderId:      orderId,
      );

      // Notifier l'admin
      await _notifierAdmin(
        vendeurNom:  prodData['vendeurNom'] ?? '',
        productNom:  prodData['nom'] ?? '',
        totalVente:  total,
        partAdmin:   partAdmin,
        partVendeur: partVendeur,
        orderId:     orderId,
      );
    }
  }

  // ── Créditer le solde du vendeur ──────────────────────────────
  static Future<void> _crediterVendeur(
    String vendeurId,
    double montant,
    String commissionId,
  ) async {
    final userRef = _db.collection('users').doc(vendeurId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final soldeActuel = (snap.data()?['soldeGains'] ?? 0.0).toDouble();
      tx.update(userRef, {
        'soldeGains':          soldeActuel + montant,
        'totalGagné':          FieldValue.increment(montant),
        'dernièreCommission':  FieldValue.serverTimestamp(),
      });
    });

    // Marquer la commission comme versée
    await _db.collection(_col).doc(commissionId).update({
      'statut':   'versé',
      'verséAt':  FieldValue.serverTimestamp(),
    });

    debugPrint('[CommissionService] 💰 Vendeur $vendeurId crédité: $montant DA');
  }

  // ── Notifier le vendeur ───────────────────────────────────────
  static Future<void> _notifierVendeur({
    required String vendeurId,
    required String productNom,
    required double totalVente,
    required double partVendeur,
    required double partAdmin,
    required String orderId,
  }) async {
    final orderRef = '#${orderId.substring(0, 8).toUpperCase()}';

    await _db.collection('notifications').add({
      'userId':    vendeurId,
      'orderId':   orderId,
      'orderRef':  orderRef,
      'type':      'commission_vendeur',
      'titre':     '💰 Vente confirmée — Gains reçus !',
      'message':
          'Votre produit « $productNom » a été vendu avec succès !\n\n'
          '📦 Commande : $orderRef\n'
          '💵 Total de la vente : ${totalVente.toStringAsFixed(0)} DA\n'
          '✅ Votre part (85%) : ${partVendeur.toStringAsFixed(0)} DA\n'
          '🏦 Commission MTS (15%) : ${partAdmin.toStringAsFixed(0)} DA\n\n'
          'Votre solde a été mis à jour. Merci pour votre confiance !',
      'lu':        false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Notifier l'admin ──────────────────────────────────────────
  static Future<void> _notifierAdmin({
    required String vendeurNom,
    required String productNom,
    required double totalVente,
    required double partAdmin,
    required double partVendeur,
    required String orderId,
  }) async {
    // Récupère UID admin
    final adminSnap = await _db
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();
    if (adminSnap.docs.isEmpty) return;
    final adminUid = adminSnap.docs.first.id;

    final orderRef = '#${orderId.substring(0, 8).toUpperCase()}';

    await _db.collection('notifications').add({
      'userId':    adminUid,
      'orderId':   orderId,
      'orderRef':  orderRef,
      'type':      'commission_admin',
      'titre':     '💼 Commission reçue — $productNom',
      'message':
          'Une vente a été effectuée par $vendeurNom.\n\n'
          '📦 Commande : $orderRef\n'
          '🏷️ Produit : $productNom\n'
          '💵 Total vente : ${totalVente.toStringAsFixed(0)} DA\n'
          '✅ Votre commission (15%) : ${partAdmin.toStringAsFixed(0)} DA\n'
          '💸 Part vendeur (85%) : ${partVendeur.toStringAsFixed(0)} DA',
      'lu':        false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Créditer aussi le solde admin
    final adminRef = _db.collection('users').doc(adminUid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(adminRef);
      final solde = (snap.data()?['soldeCommissions'] ?? 0.0).toDouble();
      tx.update(adminRef, {
        'soldeCommissions':     solde + partAdmin,
        'totalCommissionsGagnées': FieldValue.increment(partAdmin),
      });
    });

    debugPrint('[CommissionService] 💼 Admin notifié — commission: $partAdmin DA');
  }
}