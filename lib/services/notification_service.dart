import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// Modèle Notification
// ─────────────────────────────────────────────
class AppNotification {
  final String id;
  final String userId;
  final String orderId;
  final String orderRef;      // ex: #A1B2C3D4
  final String type;          // 'commande_livree' | 'commande_annulee'
  final String titre;
  final String message;
  final bool lu;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.orderRef,
    required this.type,
    required this.titre,
    required this.message,
    required this.lu,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id:        doc.id,
      userId:    d['userId']    ?? '',
      orderId:   d['orderId']   ?? '',
      orderRef:  d['orderRef']  ?? '',
      type:      d['type']      ?? '',
      titre:     d['titre']     ?? '',
      message:   d['message']   ?? '',
      lu:        d['lu']        ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// NotificationService
// ─────────────────────────────────────────────
class NotificationService {
  static final _db   = FirebaseFirestore.instance;
  static const _col  = 'notifications';

  // ── Créer une notification (appelé par l'admin) ──
  static Future<void> createLivraisonNotification({
    required String userId,
    required String orderId,
    required String clientName,
    required double total,
    required List<Map<String, dynamic>> lignes,
  }) async {
    final orderRef = '#${orderId.substring(0, 8).toUpperCase()}';
    final produitsStr = lignes
        .map((l) => '${l['nom']} ×${l['quantite']}')
        .join(', ');

    await _db.collection(_col).add({
      'userId':   userId,
      'orderId':  orderId,
      'orderRef': orderRef,
      'type':     'commande_livree',
      'titre':    'Votre commande est en route ! 🚚',
      'message':
          'Votre commande $orderRef a été confirmée et est en cours de livraison.\n\n'
          '📦 Produits : $produitsStr\n'
          '💰 Total : ${total.toStringAsFixed(0)} DA\n\n'
          '⏱ Vous recevrez votre commande dans les 24 à 48 heures.\n'
          'Merci pour votre confiance !',
      'lu':       false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[NotificationService] ✅ Notification créée pour $userId');
  }

  // ── Stream notifications non lues (pour le badge) ──
  static Stream<int> unreadCountStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return _db
        .collection(_col)
        .where('userId', isEqualTo: uid)
        .where('lu', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── Stream toutes les notifications du client ──
  static Stream<List<AppNotification>> myNotificationsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection(_col)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppNotification.fromFirestore(d)).toList());
  }

  // ── Marquer une notification comme lue ──
  static Future<void> markAsRead(String notifId) async {
    await _db.collection(_col).doc(notifId).update({'lu': true});
  }

  // ── Marquer toutes comme lues ──
  static Future<void> markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await _db
        .collection(_col)
        .where('userId', isEqualTo: uid)
        .where('lu', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'lu': true});
    }
    await batch.commit();
  }

  // ── Créer une notification pour l'admin (nouveau commentaire) ──
static Future<void> createCommentaireNotification({
  required String productId,
  required String productNom,
  required String auteur,
  required int note,
  required String message,
}) async {
  // Récupère l'UID admin depuis Firestore
  final adminSnap = await _db
      .collection('users')
      .where('role', isEqualTo: 'admin')
      .limit(1)
      .get();

  if (adminSnap.docs.isEmpty) return;
  final adminUid = adminSnap.docs.first.id;

  final stars = '⭐' * note;

  await _db.collection(_col).add({
    'userId':    adminUid,
    'orderId':   productId,
    'orderRef':  productNom,
    'type':      'nouveau_commentaire',
    'titre':     'Nouvel avis sur "$productNom"',
    'message':
        '$auteur a laissé un avis $stars\n\n'
        '"$message"',
    'lu':        false,
    'createdAt': FieldValue.serverTimestamp(),
  });

  debugPrint('[NotificationService] ✅ Notif admin commentaire créée');
}
}