// lib/services/product_service.dart
// Adapté pour Flutter Web — File remplacé par Uint8List

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/product.dart';
import 'storage_service.dart';

class ProductService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'produits';

  // ─────────────────────────────────────────────
  // Ajouter un produit
  // ─────────────────────────────────────────────
  static Future<Product> addProduct(
    Product newProduct, {
    required String nom,
    required String marque,
    required ProductCategory category,
    required double prix,
    required int quantite,
    required String description,
    required List<BuyerType> acheteurs,
    Uint8List? imageBytes, // ← web: bytes au lieu de File
    String? imageFileName, // ← nom du fichier ex: 'photo.jpg'
  }) async {
    final docRef = _db.collection(_collection).doc();
    final productId = docRef.id;
    final existing =
        await _db
            .collection(_collection)
            .where('nom', isEqualTo: nom.trim())
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ce produit existe déjà dans le catalogue.');
    }

    String? imageUrl;
    if (imageBytes != null && imageFileName != null) {
      imageUrl = await StorageService.uploadProductImage(
        bytes: imageBytes,
        fileName: imageFileName,
      );
    }

    final data = {
      'nom': nom,
      'marque': marque,
      'categorie': category.label,
      'prix': prix,
      'quantite': quantite,
      'descreption': description,
      'imgProd': imageUrl ?? '',
      'achteurAutoris': acheteurs.map((b) => b.label).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'deleted': false,
    };

    await docRef.set(data);
    debugPrint('[ProductService]  Produit ajouté: $productId');

    return Product(
      id: productId,
      name: nom,
      brand: marque,
      category: category,
      quantity: quantite,
      price: prix,
      description: description,
      allowedBuyers: acheteurs,
      imagePath: imageUrl,
    );
  }

  // ─────────────────────────────────────────────
  // Mettre à jour un produit
  // ─────────────────────────────────────────────
  static Future<Product> updateProduct({
    required String productId,
    required String nom,
    required String marque,
    required ProductCategory category,
    required double prix,
    required int quantite,
    required String description,
    required List<BuyerType> acheteurs,
    Uint8List? newImageBytes, // null = garder l'ancienne image
    String? newImageFileName,
    String? existingImageUrl, // URL Cloudinary actuelle
  }) async {
    final existing =
        await _db
            .collection(_collection)
            .where('nom', isEqualTo: nom.trim())
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty && existing.docs.first.id != productId) {
      throw Exception('Un produit avec ce nom existe déjà dans le catalogue.');
    }

    String? imageUrl = existingImageUrl;
    if (newImageBytes != null && newImageFileName != null) {
      imageUrl = await StorageService.uploadProductImage(
        bytes: newImageBytes,
        fileName: newImageFileName,
      );
    }

    final data = {
      'nom': nom,
      'marque': marque,
      'categorie': category.label,
      'prix': prix,
      'quantite': quantite,
      'descreption': description,
      'imgProd': imageUrl ?? '',
      'achteurAutoris': acheteurs.map((b) => b.label).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _db.collection(_collection).doc(productId).update(data);
    debugPrint('[ProductService]  Produit mis à jour: $productId');

    return Product(
      id: productId,
      name: nom,
      brand: marque,
      category: category,
      quantity: quantite,
      price: prix,
      description: description,
      allowedBuyers: acheteurs,
      imagePath: imageUrl,
    );
  }

  // ─────────────────────────────────────────────
  // Supprimer un produit
  // ─────────────────────────────────────────────
  // Soft delete — garde la trace dans Firestore
  static Future<void> deleteProduct(String productId) async {
    await _db.collection(_collection).doc(productId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[ProductService]  Produit archivé: $productId');
  }

  // ─────────────────────────────────────────────
  // Récupérer tous les produits
  // ─────────────────────────────────────────────

  static Future<List<Product>> fetchProducts() async {
    try {
      final snapshot =
          await _db
              .collection(_collection)
              .where('deleted', isNotEqualTo: true) // ← exclure les supprimés
              .orderBy('deleted') // ← requis par Firestore
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Product(
          id: doc.id,
          name: d['nom'] ?? '',
          brand: d['marque'] ?? '',
          category: _categoryFromLabel(d['categorie'] ?? ''),
          quantity: (d['quantite'] ?? 0) as int,
          price: (d['prix'] ?? 0).toDouble(),
          description: d['descreption'] ?? '',
          allowedBuyers: _buyersFromList(d['achteurAutoris']),
          imagePath: d['imgProd'],
        );
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('[ProductService]  Erreur fetch: ${e.message}');
      return [];
    }
  }

  // static Future<List<Product>> fetchProducts() async {
  //   try {
  //     final snapshot =
  //         await _db
  //             .collection(_collection)
  //             .get(); // ← simple, sans where ni orderBy

  //     debugPrint('[ProductService] Total docs: ${snapshot.docs.length}');

  //     final products =
  //         snapshot.docs
  //             .where((doc) {
  //               final data = doc.data();
  //               final deleted = data['deleted'];
  //               debugPrint('[ProductService] ${doc.id} → deleted=$deleted');
  //               return deleted != true; // garde tout sauf deleted=true
  //             })
  //             .map((doc) {
  //               final d = doc.data();
  //               return Product(
  //                 id: doc.id,
  //                 name: d['nom'] ?? '',
  //                 brand: d['marque'] ?? '',
  //                 category: _categoryFromLabel(d['categorie'] ?? ''),
  //                 quantity: (d['quantite'] ?? 0) as int,
  //                 price: (d['prix'] ?? 0).toDouble(),
  //                 description: d['descreption'] ?? '',
  //                 allowedBuyers: _buyersFromList(d['achteurAutoris']),
  //                 imagePath: d['imgProd'],
  //               );
  //             })
  //             .toList();

  //     // Tri local par date décroissante
  //     products.sort((a, b) => b.id.compareTo(a.id));

  //     debugPrint('[ProductService] Produits après filtre: ${products.length}');
  //     return products;
  //   } on FirebaseException catch (e) {
  //     debugPrint('[ProductService] Erreur fetch: ${e.message}');
  //     return [];
  //   }
  // }

  // ── Helpers ──
  static ProductCategory _categoryFromLabel(String label) {
    return ProductCategory.values.firstWhere(
      (c) => c.label == label,
      orElse: () => ProductCategory.medical,
    );
  }

  static List<BuyerType> _buyersFromList(dynamic list) {
    if (list == null || list is! List) return [];
    return (list as List)
        .map(
          (e) => BuyerType.values.firstWhere(
            (b) => b.label == e,
            orElse: () => BuyerType.autre,
          ),
        )
        .toList();
  }
}
