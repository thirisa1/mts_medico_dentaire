import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// Modèle ligne de panier
// ─────────────────────────────────────────────
class CartItem {
  final String productId;
  final String nom;
  final double prix;
  final String? imgProd;
  int quantite;

  CartItem({
    required this.productId,
    required this.nom,
    required this.prix,
    this.imgProd,
    required this.quantite,
  });

  double get total => prix * quantite;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'nom': nom,
        'prix': prix,
        'imgProd': imgProd ?? '',
        'quantite': quantite,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory CartItem.fromMap(String id, Map<String, dynamic> d) => CartItem(
        productId: id,
        nom: d['nom'] ?? '',
        prix: (d['prix'] ?? 0).toDouble(),
        imgProd: d['imgProd'],
        quantite: (d['quantite'] ?? 1) as int,
      );
}

// ─────────────────────────────────────────────
// CartService — CRUD panier Firestore
// Collection : paniers/{userId}/lignes/{productId}
// ─────────────────────────────────────────────
class CartService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>>? get _lignes {
    if (_uid == null) return null;
    return _db.collection('paniers').doc(_uid).collection('lignes');
  }

  // ── Stream temps réel du panier ──
  static Stream<List<CartItem>> cartStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('paniers')
        .doc(_uid)
        .collection('lignes')
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CartItem.fromMap(d.id, d.data()))
            .toList());
  }

  // ── Stream juste le nombre d'articles ──
  static Stream<int> cartCountStream() {
    if (_uid == null) return Stream.value(0);
    return _db
        .collection('paniers')
        .doc(_uid)
        .collection('lignes')
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        total += (doc.data()['quantite'] as int? ?? 1);
      }
      return total;
    });
  }

  // ── Ajouter ou incrémenter ──
  static Future<void> addToCart({
    required String productId,
    required String nom,
    required double prix,
    String? imgProd,
    int quantite = 1,
  }) async {
    if (_uid == null) return;
    final ref = _lignes!.doc(productId);
    final snap = await ref.get();

    if (snap.exists) {
      // Produit déjà dans le panier → incrémenter
      final current = (snap.data()?['quantite'] as int? ?? 1);
      await ref.update({
        'quantite': current + quantite,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Nouveau produit
      await ref.set(CartItem(
        productId: productId,
        nom: nom,
        prix: prix,
        imgProd: imgProd,
        quantite: quantite,
      ).toMap());
    }
    debugPrint('[CartService] ✅ Ajouté: $nom (x$quantite)');
  }

  // ── Mettre à jour la quantité ──
  static Future<void> updateQuantity(String productId, int newQty) async {
    if (_uid == null || newQty < 1) return;
    await _lignes!.doc(productId).update({
      'quantite': newQty,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Supprimer une ligne ──
  static Future<void> removeItem(String productId) async {
    if (_uid == null) return;
    await _lignes!.doc(productId).delete();
    debugPrint('[CartService]  Supprimé: $productId');
  }

  // ── Vider le panier ──
  static Future<void> clearCart() async {
    if (_uid == null) return;
    final snap = await _lignes!.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    debugPrint('[CartService] 🗑️ Panier vidé');
  }

  // ── Récupérer toutes les lignes (one-shot) ──
  static Future<List<CartItem>> fetchCart() async {
    if (_uid == null) return [];
    final snap = await _lignes!.orderBy('updatedAt').get();
    return snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList();
  }
}