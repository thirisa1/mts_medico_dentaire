import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'cart_service.dart';

// ─────────────────────────────────────────────
// Modèle commande Firestore
// ─────────────────────────────────────────────
class OrderModel {
  final String id;
  final String userId;
  final String clientName;
  final String clientEmail;
  final String telephone;
  final String adresse;
  final String ville;
  final String wilaya;
  final String codePostal;
  final List<CartItem> lignes;
  final double sousTotal;
  final double fraisExpedition;
  final double total;
  final String statut; // 'en_attente' | 'livree' | 'annulee'
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.clientEmail,
    required this.telephone,
    required this.adresse,
    required this.ville,
    required this.wilaya,
    required this.codePostal,
    required this.lignes,
    required this.sousTotal,
    required this.fraisExpedition,
    required this.total,
    required this.statut,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id:             doc.id,
      userId:         d['userId']         ?? '',
      clientName:     d['clientName']     ?? '',
      clientEmail:    d['clientEmail']    ?? '',
      telephone:      d['telephone']      ?? '',
      adresse:        d['adresse']        ?? '',
      ville:          d['ville']          ?? '',
      wilaya:         d['wilaya']         ?? '',
      codePostal:     d['codePostal']     ?? '',
      sousTotal:      (d['sousTotal']     ?? 0).toDouble(),
      fraisExpedition:(d['fraisExpedition']?? 0).toDouble(),
      total:          (d['total']         ?? 0).toDouble(),
      statut:         d['statut']         ?? 'en_attente',
      createdAt:      (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lignes: ((d['lignes'] as List?) ?? []).map((l) {
        return CartItem(
          productId: l['productId'] ?? '',
          nom:       l['nom']       ?? '',
          prix:      (l['prix']     ?? 0).toDouble(),
          imgProd:   l['imgProd'],
          quantite:  (l['quantite'] ?? 1) as int,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':          userId,
    'clientName':      clientName,
    'clientEmail':     clientEmail,
    'telephone':       telephone,
    'adresse':         adresse,
    'ville':           ville,
    'wilaya':          wilaya,
    'codePostal':      codePostal,
    'sousTotal':       sousTotal,
    'fraisExpedition': fraisExpedition,
    'total':           total,
    'statut':          statut,
    'createdAt':       FieldValue.serverTimestamp(),
    'lignes': lignes.map((l) => {
      'productId': l.productId,
      'nom':       l.nom,
      'prix':      l.prix,
      'imgProd':   l.imgProd ?? '',
      'quantite':  l.quantite,
    }).toList(),
  };
}

// ─────────────────────────────────────────────
// OrderService
// ─────────────────────────────────────────────
class OrderService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static const _col  = 'commandes';

  // ── Créer une commande ──────────────────────
  static Future<String> createOrder({
    required String prenom,
    required String nom,
    required String telephone,
    required String adresse,
    required String ville,
    required String wilaya,
    required String codePostal,
    required List<CartItem> lignes,
    required double sousTotal,
    required double fraisExpedition,
  }) async {
    final user = _auth.currentUser;
    final docRef = _db.collection(_col).doc();

    final order = OrderModel(
      id:             docRef.id,
      userId:         user?.uid         ?? 'anonyme',
      clientName:     '$prenom $nom'.trim(),
      clientEmail:    user?.email       ?? '',
      telephone:      telephone,
      adresse:        adresse,
      ville:          ville,
      wilaya:         wilaya,
      codePostal:     codePostal,
      lignes:         lignes,
      sousTotal:      sousTotal,
      fraisExpedition:fraisExpedition,
      total:          sousTotal + fraisExpedition,
      statut:         'en_attente',
      createdAt:      DateTime.now(),
    );

    await docRef.set(order.toMap());
    debugPrint('[OrderService] ✅ Commande créée: ${docRef.id}');
    return docRef.id;
  }

  // ── Stream toutes les commandes (admin) ─────
  static Stream<List<OrderModel>> allOrdersStream() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  // ── Stream commandes d'un client ────────────
  static Stream<List<OrderModel>> myOrdersStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection(_col)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  // ── Mettre à jour le statut (admin) ─────────
  static Future<void> updateStatut(String orderId, String statut) async {
    await _db.collection(_col).doc(orderId).update({
      'statut':    statut,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[OrderService]  Statut mis à jour: $orderId → $statut');
  }
}