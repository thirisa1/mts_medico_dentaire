import 'package:flutter/foundation.dart';

/// Classes de données pour les prédictions client
class RecommendedProduct {
  final String id;
  final String nom;
  final double prix;
  final double scoreRecommandation; // 0-100
  final String raison; // Pourquoi recommandé
  final String categorie;

  RecommendedProduct({
    required this.id,
    required this.nom,
    required this.prix,
    required this.scoreRecommandation,
    required this.raison,
    required this.categorie,
  });
}

class ClientProfile {
  final String id;
  final int totalAchats;
  final double depenseTotale;
  final double depenseMoyenne;
  final String categoriePrincipale;
  final int joursActif; // Jours depuis 1er achat
  final double frequenceAchat; // Achats par mois
  final String niveauFidelite; // Or, Silver, Bronze

  ClientProfile({
    required this.id,
    required this.totalAchats,
    required this.depenseTotale,
    required this.depenseMoyenne,
    required this.categoriePrincipale,
    required this.joursActif,
    required this.frequenceAchat,
    required this.niveauFidelite,
  });
}

class PricePredictor {
  final String produitNom;
  final double prixActuel;
  final double prixPredit; // Pour 30 jours
  final String tendance; // hausse, baisse, stable
  final double pourcentageChangement;

  PricePredictor({
    required this.produitNom,
    required this.prixActuel,
    required this.prixPredit,
    required this.tendance,
    required this.pourcentageChangement,
  });
}

class FavoriAlert {
  final String produitNom;
  final String etat; // en_stock, rupture_prevue, new_variant
  final String message;
  final String icone;

  FavoriAlert({
    required this.produitNom,
    required this.etat,
    required this.message,
    required this.icone,
  });
}

class ClientPredictionService {
  /// Recommande des produits basés sur l'historique d'achat
  static List<RecommendedProduct> recommendProducts(
    List<Map<String, dynamic>> purchaseHistory,
    List<Map<String, dynamic>> allProducts,
  ) {
    final recommendations = <RecommendedProduct>[];

    // 1. Analyser les catégories achetées
    final categorieFavori = <String, int>{};
    for (var purchase in purchaseHistory) {
      final categorie = purchase['categorie'] as String?;
      if (categorie != null) {
        categorieFavori[categorie] = (categorieFavori[categorie] ?? 0) + 1;
      }
    }

    // 2. Prendre les top 2 catégories
    final topCategories =
        categorieFavori.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final favoriteCategories = topCategories.take(2).map((e) => e.key).toList();

    // 3. Recommander des produits des mêmes catégories
    final idsAchetes =
        purchaseHistory
            .map((p) => p['produitId'] as String?)
            .whereType<String>()
            .toSet();

    for (var product in allProducts) {
      final categorie = product['categorie'] as String?;
      final produitId = product['id'] as String?;

      if (produitId != null &&
          categorie != null &&
          !idsAchetes.contains(produitId)) {
        if (favoriteCategories.contains(categorie)) {
          final score = _calculateRecommendationScore(product, categorieFavori);

          if (score > 40) {
            recommendations.add(
              RecommendedProduct(
                id: produitId,
                nom: product['nom'] as String? ?? 'Produit',
                prix: (product['prix'] as num?)?.toDouble() ?? 0,
                scoreRecommandation: score,
                raison: 'Basé sur vos achats en $categorie',
                categorie: categorie,
              ),
            );
          }
        }
      }
    }

    // Trier par score et retourner top 5
    recommendations.sort(
      (a, b) => b.scoreRecommandation.compareTo(a.scoreRecommandation),
    );
    return recommendations.take(5).toList();
  }

  /// Crée le profil du client avec ML analytics
  static ClientProfile createClientProfile(
    String clientId,
    List<Map<String, dynamic>> purchases,
  ) {
    if (purchases.isEmpty) {
      return ClientProfile(
        id: clientId,
        totalAchats: 0,
        depenseTotale: 0,
        depenseMoyenne: 0,
        categoriePrincipale: 'Aucune',
        joursActif: 0,
        frequenceAchat: 0,
        niveauFidelite: 'Bronze',
      );
    }

    // Calculer les statistiques
    final totalAchats = purchases.length;
    final depenseTotale = purchases.fold<double>(
      0,
      (sum, p) => sum + ((p['montant'] as num?)?.toDouble() ?? 0),
    );
    final depenseMoyenne = depenseTotale / totalAchats;

    // Catégorie principale
    final categories = <String, int>{};
    for (var p in purchases) {
      final cat = p['categorie'] as String?;
      if (cat != null) {
        categories[cat] = (categories[cat] ?? 0) + 1;
      }
    }
    final categoriePrincipale =
        categories.entries.reduce((a, b) => a.value > b.value ? a : b).key ??
        'Général';

    // Jours actifs (entre premier et dernier achat)
    int joursActif = 0;
    try {
      final firstDate = _parseDate(purchases.first['date']);
      final lastDate = _parseDate(purchases.last['date']);
      joursActif = lastDate.difference(firstDate).inDays;
    } catch (e) {
      joursActif = 30;
    }

    // Fréquence d'achat (achats par mois)
    final frequenceAchat =
        joursActif > 0 ? ((totalAchats * 30) / joursActif).toDouble() : 0.0;

    // Niveau de fidélité basé sur dépense totale
    final niveauFidelite = _calculateLoyaltyLevel(depenseTotale);

    return ClientProfile(
      id: clientId,
      totalAchats: totalAchats,
      depenseTotale: depenseTotale,
      depenseMoyenne: depenseMoyenne,
      categoriePrincipale: categoriePrincipale,
      joursActif: joursActif.clamp(0, joursActif),
      frequenceAchat: frequenceAchat,
      niveauFidelite: niveauFidelite,
    );
  }

  /// Prédit les prix futurs basés sur l'historique
  static List<PricePredictor> predictPrices(
    List<Map<String, dynamic>> allProducts,
    List<Map<String, dynamic>> priceHistory,
  ) {
    final predictions = <PricePredictor>[];

    for (var product in allProducts) {
      final produitNom = product['nom'] as String?;
      final prixActuel = (product['prix'] as num?)?.toDouble() ?? 0;

      if (produitNom != null) {
        // Trouver l'historique des prix pour ce produit
        final pricePoints =
            priceHistory.where((ph) => ph['nom'] == produitNom).toList()..sort(
              (a, b) => _parseDate(a['date']).compareTo(_parseDate(b['date'])),
            );

        if (pricePoints.isEmpty) {
          // Pas d'historique, prédire stable
          predictions.add(
            PricePredictor(
              produitNom: produitNom,
              prixActuel: prixActuel,
              prixPredit: prixActuel,
              tendance: 'stable',
              pourcentageChangement: 0,
            ),
          );
        } else {
          // Calculer la tendance (régression linéaire simple)
          final prices =
              pricePoints
                  .map((p) => (p['prix'] as num?)?.toDouble() ?? 0)
                  .toList();

          final slope = _calculateSlope(prices);
          final changement = slope * 30; // Prédiction 30 jours
          final prixPredit =
              (prixActuel + changement).clamp(0, double.infinity).toDouble();
          final pourcentage =
              (((changement / prixActuel) * 100).clamp(-100, 100)).toDouble();

          final tendance =
              changement > 5
                  ? 'hausse'
                  : changement < -5
                  ? 'baisse'
                  : 'stable';

          predictions.add(
            PricePredictor(
              produitNom: produitNom,
              prixActuel: prixActuel,
              prixPredit: prixPredit,
              tendance: tendance,
              pourcentageChangement: pourcentage,
            ),
          );
        }
      }
    }

    return predictions.take(5).toList();
  }

  /// Génère des alertes pour les produits favoris
  static List<FavoriAlert> generateFavoriAlerts(
    List<Map<String, dynamic>> favoris,
    List<Map<String, dynamic>> allProducts,
  ) {
    final alerts = <FavoriAlert>[];

    for (var favori in favoris) {
      final produitId = favori['produitId'] as String?;
      final produitNom = favori['nom'] as String? ?? 'Produit';

      final product = allProducts.firstWhere(
        (p) => p['id'] == produitId,
        orElse: () => {},
      );

      if (product.isEmpty) continue;

      final stock = (product['quantite'] as num?)?.toInt() ?? 0;
      final prix = (product['prix'] as num?)?.toDouble() ?? 0;

      // 1. Alerte rupture imminente
      if (stock < 5 && stock > 0) {
        alerts.add(
          FavoriAlert(
            produitNom: produitNom,
            etat: 'rupture_prevue',
            message: 'Seulement $stock en stock - Rupture prévue',
            icone: '⚠️',
          ),
        );
      }

      // 2. Alerte rupture
      if (stock == 0) {
        alerts.add(
          FavoriAlert(
            produitNom: produitNom,
            etat: 'rupture_prevue',
            message: 'Actuellement indisponible',
            icone: '🔴',
          ),
        );
      }

      // 3. Alerte prix baisse
      final prixPrecedent = (favori['prixPrec'] as num?)?.toDouble();
      if (prixPrecedent != null && prix < prixPrecedent) {
        final reduction = (((prixPrecedent - prix) / prixPrecedent) * 100)
            .toStringAsFixed(1);
        alerts.add(
          FavoriAlert(
            produitNom: produitNom,
            etat: 'new_variant',
            message: 'Prix baissé de $reduction% !',
            icone: '💰',
          ),
        );
      }

      // 4. Alerte réapprovisionnement
      if (stock > 10) {
        alerts.add(
          FavoriAlert(
            produitNom: produitNom,
            etat: 'en_stock',
            message: 'Réapprovisionné - $stock en stock',
            icone: '✅',
          ),
        );
      }
    }

    return alerts;
  }

  // ─────────────────────────────────────────
  // Fonctions helper
  // ─────────────────────────────────────────

  static double _calculateRecommendationScore(
    Map<String, dynamic> product,
    Map<String, int> categoryFrequency,
  ) {
    double score = 50; // Base

    // Bonus pour catégorie favorite
    final categorie = product['categorie'] as String?;
    if (categorie != null && categoryFrequency.containsKey(categorie)) {
      score += (categoryFrequency[categorie]! * 10).clamp(0, 30).toDouble();
    }

    // Bonus pour popularité (nombre d'avis)
    final avis = (product['avis'] as num?)?.toInt() ?? 0;
    score += (avis / 10).clamp(0, 20).toDouble();

    // Bonus pour rating élevé
    final rating = (product['rating'] as num?)?.toDouble() ?? 0;
    score += (rating * 10).clamp(0, 20);

    return score.clamp(0, 100);
  }

  static String _calculateLoyaltyLevel(double totalSpent) {
    if (totalSpent > 10000) return 'Platine';
    if (totalSpent > 5000) return 'Or';
    if (totalSpent > 2000) return 'Argent';
    return 'Bronze';
  }

  static double _calculateSlope(List<double> prices) {
    if (prices.length < 2) return 0;

    final n = prices.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += prices[i];
      sumXY += i * prices[i];
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope.isNaN || slope.isInfinite ? 0 : slope;
  }

  static DateTime _parseDate(dynamic dateObj) {
    if (dateObj is DateTime) return dateObj;
    if (dateObj is String) return DateTime.parse(dateObj);
    return DateTime.now();
  }
}
