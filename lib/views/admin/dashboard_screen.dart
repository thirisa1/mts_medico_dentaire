import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/prediction_service.dart';

// ─────────────────────────────────────────────
// DashboardScreen — Tableau de bord Admin
// Données réelles depuis Firestore + ML Predictions
// KPI cards + graphiques + prédictions ML
// ─────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── Couleurs (inline pour éviter dépendances) ──
  static const _primary = Color(0xFF1A3A8F);
  static const _accent = Color(0xFF29ABE2);
  static const _green = Color(0xFF059669);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFDC2626);
  static const _purple = Color(0xFF7C3AED);
  static const _bgPage = Color(0xFFF8FAFF);
  //static const _surface    = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _textDark = Color(0xFF0D1B4B);
  static const _textMuted = Color(0xFF9AAAC4);

  // ── État ──
  bool _loading = true;

  // ── KPIs ──
  int _totalCommandes = 0;
  int _commandesEnAttente = 0;
  int _commandesLivrees = 0;
  double _revenuTotal = 0;
  double _revenuMois = 0;
  int _totalProduits = 0;
  int _produitsEnRupture = 0;
  int _totalClients = 0;
  int _totalProfessionnels = 0;
  int _demandesEnAttente = 0;

  // ── Graphique barres : revenus 6 derniers mois ──
  List<_MoisRevenu> _revenusParMois = [];

  // ── Camembert : répartition catégories produits ──
  List<_CatData> _categoriesProduits = [];

  // ── Top 5 produits les plus commandés ──
  List<_TopProduit> _topProduits = [];

  // ── Prédictions ML ──
  PredictionRevenu? _predictionRevenu;
  List<PredictionProduit> _produitsPredits = [];
  ClientSegmentation? _segmentationClients;
  List<StockPrediction> _predictionsStock = [];
  SeasonalityAnalysis? _seasonalityAnalysis;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadCommandes(),
      _loadProduits(),
      _loadClients(),
      _loadDemandes(),
    ]);
    await _computePredictions();
    if (mounted) setState(() => _loading = false);
  }

  // ── Calcul des prédictions ML ──
  Future<void> _computePredictions() async {
    try {
      // Récupérer les données pour les prédictions
      final commandesSnap =
          await FirebaseFirestore.instance.collection('commandes').get();
      final produitsSnap =
          await FirebaseFirestore.instance.collection('produits').get();

      final commandesList = commandesSnap.docs.map((d) => d.data()).toList();
      final produitsList = produitsSnap.docs.map((d) => d.data()).toList();

      if (mounted) {
        setState(() {
          // Prédiction revenus
          final revenusHistory = _revenusParMois.map((e) => e.revenu).toList();
          _predictionRevenu = MLPredictionService.predictRevenusNextMonth(
            revenusHistory,
          );

          // Prédiction produits
          final allProductNames =
              produitsList
                  .map((p) => p['nom'] as String?)
                  .whereType<String>()
                  .toList();
          _produitsPredits = MLPredictionService.predictTopProducts(
            commandesList,
            allProductNames,
          );

          // Segmentation clients
          _segmentationClients = MLPredictionService.segmentClientsByBehavior(
            commandesList,
          );

          // Prédictions stock
          _predictionsStock = MLPredictionService.predictStockRuptures(
            produitsList,
            commandesList,
          );

          // Analyse saisonnalité
          _seasonalityAnalysis = MLPredictionService.analyzeSeasonality(
            commandesList,
          );
        });
      }
    } catch (e) {
      debugPrint('Erreur calcul prédictions: $e');
    }
  }

  // ── Chargement commandes ──
  Future<void> _loadCommandes() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('commandes').get();
      final docs = snap.docs;

      double revTotal = 0;
      double revMois = 0;
      int enAttente = 0;
      int livrees = 0;

      final now = DateTime.now();
      final debutMois = DateTime(now.year, now.month, 1);

      // Revenus par mois (6 derniers mois)
      final Map<String, double> revenusMap = {};
      for (int i = 5; i >= 0; i--) {
        final m = DateTime(now.year, now.month - i, 1);
        final key = '${m.month.toString().padLeft(2, '0')}/${m.year}';
        revenusMap[key] = 0;
      }

      // Top produits
      final Map<String, _TopProduit> topMap = {};

      for (final doc in docs) {
        final d = doc.data();
        final total = (d['total'] ?? 0).toDouble();
        final statut = d['statut'] ?? '';
        final ts = d['createdAt'] as Timestamp?;
        final date = ts?.toDate() ?? DateTime.now();

        revTotal += total;
        if (statut == 'en_attente') enAttente++;
        if (statut == 'livree') livrees++;
        if (date.isAfter(debutMois)) revMois += total;

        // Revenus par mois
        final key = '${date.month.toString().padLeft(2, '0')}/${date.year}';
        if (revenusMap.containsKey(key)) {
          revenusMap[key] = (revenusMap[key] ?? 0) + total;
        }

        // Top produits
        final lignes = (d['lignes'] as List?) ?? [];
        for (final l in lignes) {
          final nom = l['nom'] as String? ?? '';
          final qty = (l['quantite'] as int?) ?? 1;
          if (topMap.containsKey(nom)) {
            topMap[nom] = _TopProduit(
              nom: nom,
              quantite: topMap[nom]!.quantite + qty,
            );
          } else {
            topMap[nom] = _TopProduit(nom: nom, quantite: qty);
          }
        }
      }

      // Top 5
      final top =
          topMap.values.toList()
            ..sort((a, b) => b.quantite.compareTo(a.quantite));

      _totalCommandes = docs.length;
      _commandesEnAttente = enAttente;
      _commandesLivrees = livrees;
      _revenuTotal = revTotal;
      _revenuMois = revMois;
      _topProduits = top.take(5).toList();

      // Barres revenus
      _revenusParMois =
          revenusMap.entries
              .map((e) => _MoisRevenu(mois: e.key, revenu: e.value))
              .toList();
    } catch (e) {
      debugPrint('Dashboard commandes error: $e');
    }
  }

  // ── Chargement produits ──
  Future<void> _loadProduits() async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('produits')
              .where('deleted', isNotEqualTo: true)
              .get();

      int rupture = 0;
      final Map<String, int> catMap = {};

      for (final doc in snap.docs) {
        final d = doc.data();
        final qty = (d['quantite'] as int?) ?? 0;
        final cat = (d['categorie'] as String?) ?? 'Autre';
        if (qty == 0) rupture++;
        catMap[cat] = (catMap[cat] ?? 0) + 1;
      }

      _totalProduits = snap.docs.length;
      _produitsEnRupture = rupture;

      // Top 5 catégories pour le camembert
      final sorted =
          catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final colors = [_primary, _accent, _green, _orange, _purple, _red];
      _categoriesProduits =
          sorted
              .take(6)
              .toList()
              .asMap()
              .entries
              .map(
                (e) => _CatData(
                  nom: e.value.key,
                  count: e.value.value,
                  color: colors[e.key % colors.length],
                ),
              )
              .toList();
    } catch (e) {
      debugPrint('Dashboard produits error: $e');
    }
  }

  // ── Chargement clients ──
  Future<void> _loadClients() async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'client')
              .get();
      final pro =
          snap.docs.where((d) => d.data()['type'] == 'professionnel').length;
      _totalClients = snap.docs.length;
      _totalProfessionnels = pro;
    } catch (e) {
      debugPrint('Dashboard clients error: $e');
    }
  }

  // ── Chargement demandes ──
  Future<void> _loadDemandes() async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('demandes_produits')
              .where('statut', isEqualTo: 'en_attente')
              .get();
      _demandesEnAttente = snap.docs.length;
    } catch (e) {
      debugPrint('Dashboard demandes error: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: isMobile ? _buildAppBar() : null,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : RefreshIndicator(
                color: _primary,
                onRefresh: _loadAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isMobile ? 16 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile) _buildWebHeader(),
                      const SizedBox(height: 20),
                      // ── KPI Cards ──
                      _buildKpiGrid(isMobile),
                      const SizedBox(height: 28),
                      // ── Prédictions ML ──
                      if (_predictionRevenu != null) ...[
                        _buildMLPredictionsSection(isMobile),
                        const SizedBox(height: 28),
                      ],
                      // ── Graphiques ──
                      isMobile
                          ? Column(
                            children: [
                              _buildRevenusChart(),
                              const SizedBox(height: 20),
                              _buildCategoriesChart(),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildRevenusChart()),
                              const SizedBox(width: 20),
                              Expanded(flex: 2, child: _buildCategoriesChart()),
                            ],
                          ),
                      const SizedBox(height: 28),
                      // ── Top produits + Statuts ──
                      isMobile
                          ? Column(
                            children: [
                              _buildTopProduits(),
                              const SizedBox(height: 20),
                              _buildStatutsCommandes(),
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildTopProduits()),
                              const SizedBox(width: 20),
                              Expanded(child: _buildStatutsCommandes()),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
    );
  }

  // ── Section Prédictions ML ──
  Widget _buildMLPredictionsSection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildPredictionRevenuCard(),
          const SizedBox(height: 16),
          _buildProduitsPreditsCard(),
          const SizedBox(height: 16),
          _buildSegmentationClientsCard(),
          const SizedBox(height: 16),
          _buildRisquesStockCard(),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPredictionRevenuCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildSegmentationClientsCard()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildProduitsPreditsCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildRisquesStockCard()),
            ],
          ),
        ],
      );
    }
  }

  // ── Prédiction Revenu ──
  Widget _buildPredictionRevenuCard() {
    if (_predictionRevenu == null) return const SizedBox();
    final pred = _predictionRevenu!;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prédiction Revenus',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'Mois prochain (confiance: ${pred.confidence.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatMontant(pred.prediction),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  pred.trend == 'hausse'
                      ? _green.withValues(alpha: 0.1)
                      : pred.trend == 'baisse'
                      ? _red.withValues(alpha: 0.1)
                      : _orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              pred.trend == 'hausse'
                  ? '↑ Tendance haussière'
                  : pred.trend == 'baisse'
                  ? '↓ Tendance baissière'
                  : '→ Tendance stable',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    pred.trend == 'hausse'
                        ? _green
                        : pred.trend == 'baisse'
                        ? _red
                        : _orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Produits Prédits ──
  Widget _buildProduitsPreditsCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produits à Potentiel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'ML Insights',
                    style: TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_produitsPredits.isEmpty)
            const Text(
              'Données insuffisantes',
              style: TextStyle(color: _textMuted, fontSize: 12),
            )
          else
            ..._produitsPredits
                .take(3)
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.nom,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Score: ${p.potentiel.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${p.scoreVente}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Segmentation Clients ──
  Widget _buildSegmentationClientsCard() {
    if (_segmentationClients == null) return const SizedBox();
    final seg = _segmentationClients!;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: _purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Segmentation Clients',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'Valeur moyenne: ${_formatMontant(seg.avgClientValue)} DA',
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSegmentBar('Haut potentiel', seg.highValue, _green),
          const SizedBox(height: 8),
          _buildSegmentBar('Moyen potentiel', seg.medium, _orange),
          const SizedBox(height: 8),
          _buildSegmentBar('Faible potentiel', seg.low, _red),
        ],
      ),
    );
  }

  // ── Risques Stock ──
  Widget _buildRisquesStockCard() {
    final critiques =
        _predictionsStock.where((p) => p.riskLevel == 'critique').toList();
    final eleves =
        _predictionsStock.where((p) => p.riskLevel == 'élevé').toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_rounded, color: _red, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alertes Stock',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'Prédictions ruptures',
                    style: TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (critiques.isEmpty && eleves.isEmpty)
            const Text(
              'Aucune alerte',
              style: TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            )
          else ...[
            if (critiques.isNotEmpty) ...[
              Text(
                '🔴 Critique: ${critiques.length}',
                style: const TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (eleves.isNotEmpty) ...[
              Text(
                '🟠 Élevé: ${eleves.length}',
                style: const TextStyle(
                  color: _orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentBar(String label, int count, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: _textMuted),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: count > 0 ? (count / 10).clamp(0, 1) : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '  $count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ── AppBar mobile ──
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A3A8F), Color(0xFF1557B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tableau de bord',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'Vue d\'ensemble',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _loadAll,
            ),
          ],
        ),
      ),
    );
  }

  // ── Header web ──
  Widget _buildWebHeader() {
    final now = DateTime.now();
    final mois = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tableau de bord',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${now.day} ${mois[now.month - 1]} ${now.year}  •  Données en temps réel',
              style: const TextStyle(fontSize: 13, color: _textMuted),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Actualiser'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ── KPI Grid ──
  Widget _buildKpiGrid(bool isMobile) {
    final kpis = [
      _KpiData(
        titre: 'Commandes totales',
        valeur: '$_totalCommandes',
        sous: '$_commandesEnAttente en attente',
        icon: Icons.receipt_long_outlined,
        color: _primary,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        titre: 'Revenu total',
        valeur: '${_formatMontant(_revenuTotal)} DA',
        sous: '+${_formatMontant(_revenuMois)} DA ce mois',
        icon: Icons.account_balance_wallet_outlined,
        color: _green,
        bgColor: const Color(0xFFF0FDF4),
      ),
      _KpiData(
        titre: 'Produits actifs',
        valeur: '$_totalProduits',
        sous: '$_produitsEnRupture en rupture',
        icon: Icons.inventory_2_outlined,
        color: _orange,
        bgColor: const Color(0xFFFFF7ED),
      ),
      _KpiData(
        titre: 'Clients',
        valeur: '$_totalClients',
        sous: '$_totalProfessionnels professionnels',
        icon: Icons.people_outline_rounded,
        color: _accent,
        bgColor: const Color(0xFFEFF9FF),
      ),
      _KpiData(
        titre: 'Commandes livrées',
        valeur: '$_commandesLivrees',
        sous:
            _totalCommandes > 0
                ? '${(_commandesLivrees * 100 / _totalCommandes).toStringAsFixed(0)}% taux livraison'
                : '0% taux livraison',
        icon: Icons.local_shipping_outlined,
        color: _green,
        bgColor: const Color(0xFFF0FDF4),
      ),
      _KpiData(
        titre: 'Demandes vendeurs',
        valeur: '$_demandesEnAttente',
        sous: 'En attente de validation',
        icon: Icons.storefront_outlined,
        color: _purple,
        bgColor: const Color(0xFFF5F3FF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isMobile ? 1.4 : 1.8,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) => _KpiCard(kpi: kpis[i]),
    );
  }

  // ── Graphique revenus (barres maison) ──
  Widget _buildRevenusChart() {
    final maxRevenu =
        _revenusParMois.isEmpty
            ? 1.0
            : _revenusParMois
                .map((e) => e.revenu)
                .reduce((a, b) => a > b ? a : b)
                .clamp(1.0, double.infinity);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenus mensuels',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    '6 derniers mois',
                    style: TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  _revenusParMois.map((m) {
                    final ratio = maxRevenu > 0 ? (m.revenu / maxRevenu) : 0.0;
                    final isMax = m.revenu == maxRevenu && m.revenu > 0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (m.revenu > 0)
                              Text(
                                _formatMontant(m.revenu),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isMax ? _primary : _textMuted,
                                ),
                              ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              height: (ratio * 140).clamp(4, 140),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      isMax
                                          ? [_primary, const Color(0xFF1557B0)]
                                          : [
                                            _accent.withValues(alpha: 0.5),
                                            _accent.withValues(alpha: 0.8),
                                          ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              m.mois.substring(0, 2), // MM
                              style: const TextStyle(
                                fontSize: 10,
                                color: _textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Camembert catégories (barres horizontales) ──
  Widget _buildCategoriesChart() {
    final total =
        _categoriesProduits.isEmpty
            ? 1
            : _categoriesProduits.map((e) => e.count).reduce((a, b) => a + b);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catégories produits',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'Répartition par catégorie',
                    style: TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_categoriesProduits.isEmpty)
            const Center(
              child: Text('Aucune donnée', style: TextStyle(color: _textMuted)),
            )
          else
            ..._categoriesProduits.map((cat) {
              final pct = total > 0 ? cat.count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.nom,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        ),
                        Text(
                          '${cat.count} (${(pct * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: cat.color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(cat.color),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Top 5 produits ──
  Widget _buildTopProduits() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: _orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Top 5 produits commandés',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_topProduits.isEmpty)
            const Center(
              child: Text('Aucune donnée', style: TextStyle(color: _textMuted)),
            )
          else
            ..._topProduits.asMap().entries.map((e) {
              final rank = e.key + 1;
              final p = e.value;
              final medals = ['🥇', '🥈', '🥉'];
              final medal = rank <= 3 ? medals[rank - 1] : '$rank';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      rank == 1
                          ? _orange.withValues(alpha: 0.06)
                          : const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: rank == 1 ? _orange.withValues(alpha: 0.3) : _border,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        medal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: rank <= 3 ? 18 : 13,
                          fontWeight: FontWeight.w800,
                          color: _textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.nom,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '×${p.quantite}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Statuts commandes (donut visuel) ──
  Widget _buildStatutsCommandes() {
    final enAttente = _commandesEnAttente;
    final livrees = _commandesLivrees;
    final annulees = _totalCommandes - enAttente - livrees;
    final total = _totalCommandes.clamp(1, 99999);

    final statuts = [
      _StatutData('En attente', enAttente, _orange, Icons.access_time_rounded),
      _StatutData('Livrées', livrees, _green, Icons.done_all_rounded),
      _StatutData(
        'Annulées',
        annulees.clamp(0, 99999),
        _red,
        Icons.cancel_outlined,
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.donut_large_outlined,
                  color: _green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Statuts des commandes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut simplifié (barres empilées)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 18,
              child: Row(
                children:
                    statuts.map((s) {
                      final ratio = s.count / total;
                      return Flexible(
                        flex: (ratio * 1000).round().clamp(1, 1000),
                        child: Container(color: s.color),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          ...statuts.map((s) {
            final pct = (s.count / total * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          '$pct% des commandes',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${s.count}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: s.color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatMontant(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

// ════════════════════════════════════════════════════════════════
// Widgets helpers
// ════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final _KpiData kpi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kpi.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 20),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: kpi.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            kpi.valeur,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kpi.color,
            ),
          ),
          Text(
            kpi.titre,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B4B),
            ),
          ),
          Text(
            kpi.sous,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9AAAC4)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Data classes
// ════════════════════════════════════════════════════════════════
class _KpiData {
  final String titre, valeur, sous;
  final IconData icon;
  final Color color, bgColor;
  const _KpiData({
    required this.titre,
    required this.valeur,
    required this.sous,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _MoisRevenu {
  final String mois;
  final double revenu;
  const _MoisRevenu({required this.mois, required this.revenu});
}

class _CatData {
  final String nom;
  final int count;
  final Color color;
  const _CatData({required this.nom, required this.count, required this.color});
}

class _TopProduit {
  final String nom;
  final int quantite;
  const _TopProduit({required this.nom, required this.quantite});
}

class _StatutData {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatutData(this.label, this.count, this.color, this.icon);
}
