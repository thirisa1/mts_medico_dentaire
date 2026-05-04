import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';
import '../../style/theme/colors.dart';

// ════════════════════════════════════════════════════════════════
// Page Admin — Demandes de produits des professionnels
// ════════════════════════════════════════════════════════════════

class DemandesPage extends StatefulWidget {
  const DemandesPage({super.key});

  @override
  State<DemandesPage> createState() => _DemandesPageState();
}

class _DemandesPageState extends State<DemandesPage> {
  String _filterStatut = 'en_attente'; // filtre actif

  static const _filtres = ['en_attente', 'approuvé', 'refusé'];

  String _filterLabel(String s) {
    switch (s) {
      case 'en_attente': return 'En attente';
      case 'approuvé':   return 'Approuvés';
      case 'refusé':     return 'Refusés';
      default:           return s;
    }
  }

  Color _filterColor(String s) {
    switch (s) {
      case 'en_attente': return const Color(0xFFF59E0B);
      case 'approuvé':   return const Color(0xFF059669);
      case 'refusé':     return const Color(0xFFDC2626);
      default:           return AppColors.primary;
    }
  }

  // ── Approuver ──────────────────────────────────────────────────

  Future<void> _approuver(
      String demandeId, Map<String, dynamic> data) async {
    final confirm = await _showConfirmDialog(
      title: 'Approuver ce produit ?',
      message:
          '« ${data['nom']} » sera ajouté au catalogue et visible par tous les clients.',
      confirmLabel: 'Approuver',
      confirmColor: const Color(0xFF059669),
      icon: Icons.check_circle_outline,
    );
    if (confirm != true) return;

    try {
      final adminUid = FirebaseAuth.instance.currentUser!.uid;
      final now      = FieldValue.serverTimestamp();

      // 1. Ajouter dans la collection produits
      await FirebaseFirestore.instance.collection('produits').add({
        'nom':         data['nom'],
        'marque':      data['marque'],
        'categorie':   data['categorie'],
        'prix':        data['prix'],
        'quantite':    data['quantite'],
        'descreption': data['descreption'],
        'imgProd':     data['imgProd'],
        'deleted':     false,
        // ── Traçabilité vendeur ──
        'vendeurId':   data['userId'],
        'vendeurNom':  data['auteur'],
        'source':      'vendeur',
        'demandeId':   demandeId,
        'approuvéPar': adminUid,
        'approuvéAt':  now,
        'createdAt':   now,
      });

      // 2. Mettre à jour la demande
      await FirebaseFirestore.instance
          .collection('demandes_produits')
          .doc(demandeId)
          .update({
        'statut':      'approuvé',
        'traitéAt':    now,
        'approuvéPar': adminUid,
        'approuvéAt':  now,
      });

      // 3. Notifier le professionnel
      await NotificationService.createReponseDemandeNotification(
        userId:     data['userId'],
        productNom: data['nom'],
        approuve:   true,
        motif:      '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Flexible(child: Text(
                '« ${data['nom']} » approuvé et publié dans le catalogue.',
                style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    }
  }

  // ── Refuser ────────────────────────────────────────────────────

  Future<void> _refuser(
      String demandeId, Map<String, dynamic> data) async {
    // Dialog avec motif
    final motif = await _showMotifDialog(data['nom']);
    if (motif == null) return; // annulé

    try {
      final now = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('demandes_produits')
          .doc(demandeId)
          .update({
        'statut':     'refusé',
        'traitéAt':   now,
        'motifRefus': motif,
      });

      await NotificationService.createReponseDemandeNotification(
        userId:     data['userId'],
        productNom: data['nom'],
        approuve:   false,
        motif:      motif,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Demande refusée — ${data['nom']}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: confirmColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: confirmColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700))),
        ]),
        content: Text(message,
            style: TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<String?> _showMotifDialog(String productNom) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cancel_outlined,
                color: Color(0xFFDC2626), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Refuser « $productNom » ?',
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Le professionnel sera notifié avec votre motif.',
              style: TextStyle(fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Motif du refus (optionnel)...',
              hintStyle: TextStyle(
                  fontSize: 13, color: AppColors.textHint),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFDC2626), width: 1.5)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirmer le refus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFDC2626),
    ));
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? _buildAppBar() : null,
      body: Column(children: [
        if (!isMobile) _buildWebHeader(),
        _buildFilterBar(),
        const SizedBox(height: 4),
        Expanded(child: _buildListe()),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [BoxShadow(color: AppColors.shadowDeep,
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Demandes Produits',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 17)),
            Text('Validation des produits professionnels',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10)),
          ]),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Demandes Produits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Validation des produits soumis par les professionnels',
              style: TextStyle(color: AppColors.textHint, fontSize: 13)),
        ]),
        const Spacer(),
        // Badge compteur en attente
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('demandes_produits')
              .where('statut', isEqualTo: 'en_attente')
              .snapshots(),
          builder: (_, snap) {
            final count = snap.data?.docs.length ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.pending_outlined,
                    color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 6),
                Text('$count en attente',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B))),
              ]),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: _filtres.map((f) {
          final active = _filterStatut == f;
          final color  = _filterColor(f);
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: GestureDetector(
              onTap: () => setState(() => _filterStatut = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? color : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? color
                        : AppColors.textHint.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(_filterLabel(f),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active
                          ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white
                          : AppColors.textSecondary,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListe() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('demandes_produits')
          .where('statut', isEqualTo: _filterStatut)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.primary));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return _buildEmpty();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc  = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _DemandeAdminCard(
              id:        doc.id,
              data:      data,
              onApprouver: () => _approuver(doc.id, data),
              onRefuser:   () => _refuser(doc.id, data),
              statut:    _filterStatut,
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty() {
    final labels = {
      'en_attente': 'Aucune demande en attente.',
      'approuvé':   'Aucune demande approuvée.',
      'refusé':     'Aucune demande refusée.',
    };
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint),
        const SizedBox(height: 14),
        Text(labels[_filterStatut] ?? '',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Carte demande côté admin
// ════════════════════════════════════════════════════════════════

class _DemandeAdminCard extends StatelessWidget {
  const _DemandeAdminCard({
    required this.id,
    required this.data,
    required this.onApprouver,
    required this.onRefuser,
    required this.statut,
  });

  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onApprouver;
  final VoidCallback onRefuser;
  final String statut;

  @override
  Widget build(BuildContext context) {
    final imgUrl = data['imgProd'] as String? ?? '';
    final motif  = data['motifRefus'] as String? ?? '';
    final date   = data['createdAt'];
    String dateStr = '';
    if (date is Timestamp) {
      final d = date.toDate();
      dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow,
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imgUrl.isNotEmpty
              ? Image.network(imgUrl, width: 52, height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgFallback())
              : _imgFallback(),
        ),
        title: Text(data['nom'] ?? '—',
            style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        subtitle: Text('${data['auteur']} • ${data['categorie']}',
            style: TextStyle(fontSize: 12,
                color: AppColors.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${data['prix'] ?? 0} DA',
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(dateStr, style: TextStyle(
                fontSize: 10, color: AppColors.textHint)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                // Infos
                _infoRow(Icons.person_outline,
                    'Vendeur : ${data['auteur']}'),
                _infoRow(Icons.category_outlined,
                    'Catégorie : ${data['categorie']}'),
                _infoRow(Icons.branding_watermark_outlined,
                    'Marque : ${data['marque']}'),
                _infoRow(Icons.layers_outlined,
                    'Quantité : ${data['quantite']}'),
                if ((data['descreption'] ?? '').isNotEmpty)
                  _infoRow(Icons.description_outlined,
                      'Description : ${data['descreption']}'),
                if (statut == 'refusé' && motif.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Motif refus : $motif',
                        style: const TextStyle(fontSize: 12,
                            color: Color(0xFFDC2626))),
                  ),
                ],
                // Boutons action (seulement si en_attente)
                if (statut == 'en_attente') ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    // Refuser
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRefuser,
                        icon: const Icon(Icons.cancel_outlined,
                            size: 16),
                        label: const Text('Refuser'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(
                              color: Color(0xFFDC2626), width: 1.5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Approuver
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprouver,
                        icon: const Icon(Icons.check_circle_outline,
                            size: 16),
                        label: const Text('Approuver',
                            style: TextStyle(
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 14, color: AppColors.accent),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(
          fontSize: 12, color: AppColors.textSecondary))),
    ]),
  );

  Widget _imgFallback() => Container(
    width: 52, height: 52,
    decoration: BoxDecoration(
      gradient: AppColors.appBarGradient,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.medical_services_outlined,
        color: Colors.white, size: 26),
  );
}