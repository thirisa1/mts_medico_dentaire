import 'dart:math';

// ─────────────────────────────────────────────
// Service de prédiction ML - Machine Learning
// Régression linéaire + Analyse de tendances
// ─────────────────────────────────────────────

class MLPredictionService {
  // ── Prédiction des revenus futurs (Régression linéaire) ──
  static PredictionRevenu predictRevenusNextMonth(List<double> revenusHistory) {
    if (revenusHistory.length < 2) {
      return PredictionRevenu(prediction: 0, confidence: 0, trend: 'stable');
    }

    // Régression linéaire simple
    final n = revenusHistory.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += revenusHistory[i];
      sumXY += i * revenusHistory[i];
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    final nextPrediction = slope * n + intercept;

    // Calcul du coefficient de corrélation (R²) pour la confiance
    double sumYMean = 0, sumResidual = 0;
    final yMean = sumY / n;

    for (int i = 0; i < n; i++) {
      final predicted = slope * i + intercept;
      sumYMean += pow((revenusHistory[i] - yMean), 2).toDouble();
      sumResidual += pow((revenusHistory[i] - predicted), 2).toDouble();
    }

    final r2 = 1 - (sumResidual / sumYMean);
    final confidence = (r2 * 100).clamp(0, 100).toDouble();

    // Déterminer la tendance
    String trend = 'stable';
    if (slope > revenusHistory.average * 0.1) {
      trend = 'hausse';
    } else if (slope < -revenusHistory.average * 0.1) {
      trend = 'baisse';
    }

    return PredictionRevenu(
      prediction: max(0, nextPrediction),
      confidence: confidence,
      trend: trend,
      slope: slope,
    );
  }

  // ── Prédiction des produits à fort potentiel ──
  static List<PredictionProduit> predictTopProducts(
    List<Map<String, dynamic>> commandes,
    List<String> allProducts,
  ) {
    final predictions = <PredictionProduit>[];

    // Analyser les commandes par produit
    final productStats = <String, _ProductStats>{};

    for (final cmd in commandes) {
      final lignes = cmd['lignes'] as List? ?? [];
      for (final ligne in lignes) {
        final nom = ligne['nom'] as String?;
        if (nom != null) {
          productStats.putIfAbsent(nom, () => _ProductStats());
          productStats[nom]!.addQuantity((ligne['quantite'] as int?) ?? 1);
        }
      }
    }

    // Calculer les scores de potentiel
    for (final product in allProducts) {
      final stats = productStats[product];
      if (stats != null) {
        final potential = stats.calculatePotentialScore();
        predictions.add(
          PredictionProduit(
            nom: product,
            scoreVente: stats.totalQuantity,
            tendance: stats.calculateTrend(),
            potentiel: potential,
            frequence: stats.orderCount,
          ),
        );
      }
    }

    // Trier par potentiel
    predictions.sort((a, b) => b.potentiel.compareTo(a.potentiel));
    return predictions.take(5).toList();
  }

  // ── Segmentation des clients ──
  static ClientSegmentation segmentClientsByBehavior(
    List<Map<String, dynamic>> commandes,
  ) {
    double totalRevenu = 0;
    int totalClients = 0;
    int highValue = 0;
    int medium = 0;
    int low = 0;

    final clientRevenue = <String, double>{};

    // Calculer le revenu par client
    for (final cmd in commandes) {
      final clientId = cmd['clientId'] as String? ?? 'unknown';
      final total = (cmd['total'] as num? ?? 0).toDouble();
      clientRevenue[clientId] = (clientRevenue[clientId] ?? 0) + total;
      totalRevenu += total;
    }

    totalClients = clientRevenue.length;
    if (totalClients == 0) {
      return ClientSegmentation(
        highValue: 0,
        medium: 0,
        low: 0,
        avgClientValue: 0,
      );
    }

    final avgValue = totalRevenu / totalClients;
    final threshold1 = avgValue * 1.5;
    final threshold2 = avgValue * 0.75;

    for (final revenue in clientRevenue.values) {
      if (revenue >= threshold1) {
        highValue++;
      } else if (revenue >= threshold2) {
        medium++;
      } else {
        low++;
      }
    }

    return ClientSegmentation(
      highValue: highValue,
      medium: medium,
      low: low,
      avgClientValue: avgValue,
    );
  }

  // ── Prédiction des ruptures de stock ──
  static List<StockPrediction> predictStockRuptures(
    List<Map<String, dynamic>> produits,
    List<Map<String, dynamic>> commandes,
  ) {
    final predictions = <StockPrediction>[];

    for (final prod in produits) {
      final nom = prod['nom'] as String?;
      final quantite = (prod['quantite'] as int?) ?? 0;

      if (nom == null) continue;

      // Calculer la vélocité (ventes par période)
      int totalVentes = 0;
      int ordersCount = 0;

      for (final cmd in commandes) {
        final lignes = cmd['lignes'] as List? ?? [];
        for (final ligne in lignes) {
          if (ligne['nom'] == nom) {
            totalVentes += (ligne['quantite'] as int?) ?? 0;
            ordersCount++;
          }
        }
      }

      if (ordersCount > 0) {
        final velocite = totalVentes / ordersCount;
        final daysBeforeRupture =
            (quantite / velocite).clamp(0, 365).toDouble();

        predictions.add(
          StockPrediction(
            nom: nom,
            stockActuel: quantite,
            velocite: velocite.toDouble(),
            joursAvantRupture: daysBeforeRupture,
            riskLevel: _calculateRiskLevel(daysBeforeRupture),
          ),
        );
      }
    }

    return predictions;
  }

  // ── Analyser les tendances saisonnières ──
  static SeasonalityAnalysis analyzeSeasonality(
    List<Map<String, dynamic>> commandes,
  ) {
    final monthlyRevenue = <int, double>{};

    for (final cmd in commandes) {
      final ts = cmd['createdAt'];
      final total = (cmd['total'] as num? ?? 0).toDouble();
      final month = (ts is DateTime) ? ts.month : DateTime.now().month;
      monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + total;
    }

    double avgMonthly = 0;
    if (monthlyRevenue.isNotEmpty) {
      avgMonthly =
          monthlyRevenue.values.reduce((a, b) => a + b) / monthlyRevenue.length;
    }

    final peaks =
        monthlyRevenue.entries
            .where((e) => e.value > avgMonthly * 1.2)
            .map((e) => e.key)
            .toList();

    return SeasonalityAnalysis(
      monthlyData: monthlyRevenue,
      averageMonthly: avgMonthly,
      peakMonths: peaks,
      pattern: _detectPattern(monthlyRevenue),
    );
  }
}

// ── Classes de données ──
class PredictionRevenu {
  final double prediction;
  final double confidence;
  final String trend;
  final double? slope;

  PredictionRevenu({
    required this.prediction,
    required this.confidence,
    required this.trend,
    this.slope,
  });
}

class PredictionProduit {
  final String nom;
  final int scoreVente;
  final String tendance;
  final double potentiel;
  final int frequence;

  PredictionProduit({
    required this.nom,
    required this.scoreVente,
    required this.tendance,
    required this.potentiel,
    required this.frequence,
  });
}

class ClientSegmentation {
  final int highValue;
  final int medium;
  final int low;
  final double avgClientValue;

  ClientSegmentation({
    required this.highValue,
    required this.medium,
    required this.low,
    required this.avgClientValue,
  });
}

class StockPrediction {
  final String nom;
  final int stockActuel;
  final double velocite;
  final double joursAvantRupture;
  final String riskLevel;

  StockPrediction({
    required this.nom,
    required this.stockActuel,
    required this.velocite,
    required this.joursAvantRupture,
    required this.riskLevel,
  });
}

class SeasonalityAnalysis {
  final Map<int, double> monthlyData;
  final double averageMonthly;
  final List<int> peakMonths;
  final String pattern;

  SeasonalityAnalysis({
    required this.monthlyData,
    required this.averageMonthly,
    required this.peakMonths,
    required this.pattern,
  });
}

// ── Classes utilitaires privées ──
class _ProductStats {
  int totalQuantity = 0;
  int orderCount = 0;
  final List<int> quantities = [];

  void addQuantity(int qty) {
    totalQuantity += qty;
    quantities.add(qty);
    orderCount++;
  }

  double calculatePotentialScore() {
    if (quantities.isEmpty) return 0;
    final avg = totalQuantity / quantities.length;
    final variance =
        quantities.map((q) => (q - avg) * (q - avg)).reduce((a, b) => a + b) /
        quantities.length;
    return sqrt(variance) * (totalQuantity / 100);
  }

  String calculateTrend() {
    if (quantities.length < 2) return 'stable';
    final recent = quantities.sublist(max(0, quantities.length - 3));
    final older = quantities.sublist(max(0, quantities.length - 6));
    if (older.isEmpty || recent.isEmpty) return 'stable';

    final avgRecent = recent.reduce((a, b) => a + b) / recent.length;
    final avgOlder = older.reduce((a, b) => a + b) / older.length;

    if (avgRecent > avgOlder * 1.2) {
      return 'hausse';
    } else if (avgRecent < avgOlder * 0.8) {
      return 'baisse';
    }
    return 'stable';
  }
}

String _calculateRiskLevel(double daysBeforeRupture) {
  if (daysBeforeRupture < 7) return 'critique';
  if (daysBeforeRupture < 30) return 'élevé';
  if (daysBeforeRupture < 90) return 'modéré';
  return 'faible';
}

String _detectPattern(Map<int, double> monthlyData) {
  if (monthlyData.length < 3) return 'données insuffisantes';
  final values = monthlyData.values.toList();
  final maxVal = values.reduce((a, b) => a > b ? a : b);
  final minVal = values.reduce((a, b) => a < b ? a : b);
  final variance =
      (maxVal - minVal) / (values.reduce((a, b) => a + b) / values.length);

  if (variance > 0.5) return 'fortement saisonnier';
  if (variance > 0.2) return 'modérément saisonnier';
  return 'régulier';
}

extension on List<double> {
  double get average => isEmpty ? 0 : reduce((a, b) => a + b) / length;
}
