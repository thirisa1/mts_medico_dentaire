import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';       // ← StorageService directement
import '../../services/notification_service.dart';
import '../../style/constants/app_colors.dart';

class VendrePage extends StatefulWidget {
  const VendrePage({super.key});

  @override
  State<VendrePage> createState() => _VendrePageState();
}

class _VendrePageState extends State<VendrePage> {
  final _nomCtrl         = TextEditingController();
  final _marqueCtrl      = TextEditingController();
  final _prixCtrl        = TextEditingController();
  final _quantiteCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _selectedCategorie;
  XFile?  _pickedImage;
  bool    _isLoading = false;

  final _picker = ImagePicker();

  static const List<String> _categories = [
    'Anesthésie dentaire',
    'Blanchiment',
    'Bouche (prothèse)',
    'Chirurgie',
    'Détartrage & Polissage',
    'Endodontie',
    'Fraises',
    'Hygiène & Désinfection',
    'Instruments',
    'Matériel',
    'Orthodontie',
    'Parapharmacie',
    'Prothèse',
    'Restauration',
    'Scellement',
    'Tenon',
    'Usage unique',
    'Médical',
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _marqueCtrl.dispose();
    _prixCtrl.dispose();
    _quantiteCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────
  String? _validate() {
    if (_nomCtrl.text.trim().isEmpty)    return 'Le nom du produit est requis.';
    if (_marqueCtrl.text.trim().isEmpty) return 'La marque est requise.';
    if (_selectedCategorie == null)      return 'Veuillez sélectionner une catégorie.';
    final prix = double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.'));
    if (prix == null || prix <= 0)       return 'Prix invalide.';
    final qty = int.tryParse(_quantiteCtrl.text.trim());
    if (qty == null || qty <= 0)         return 'Quantité invalide.';
    return null;
  }

  // ── Soumission ─────────────────────────────────────────────────
  Future<void> _submit() async {
    final error = _validate();
    if (error != null) { _showError(error); return; }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Upload image si présente via StorageService
      String imgUrl = '';
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        // Utilise StorageService.uploadProductImage directement
        final url = await StorageService.uploadProductImage(
          bytes: bytes,
          fileName: _pickedImage!.name,
        );
        imgUrl = url ?? '';
      }

      // 2. Récupérer le nom du professionnel depuis Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final prenom = userDoc.data()?['prenom'] ?? '';
      final nom    = userDoc.data()?['nom']    ?? '';
      final auteur = '$prenom $nom'.trim().isEmpty
          ? (user.email?.split('@').first ?? 'Professionnel')
          : '$prenom $nom'.trim();

      // 3. Créer la demande dans Firestore
      final ref = await FirebaseFirestore.instance
          .collection('demandes_produits')
          .add({
        'userId':      user.uid,
        'auteur':      auteur,
        'nom':         _nomCtrl.text.trim().toUpperCase(),
        'marque':      _marqueCtrl.text.trim(),
        'categorie':   _selectedCategorie,
        'prix':        double.parse(
            _prixCtrl.text.trim().replaceAll(',', '.')),
        'quantite':    int.parse(_quantiteCtrl.text.trim()),
        'descreption': _descriptionCtrl.text.trim(),
        'imgProd':     imgUrl,
        'statut':      'en_attente',
        'createdAt':   FieldValue.serverTimestamp(),
        'traitéAt':    null,
        'motifRefus':  '',
        'approuvéPar': '',
        'approuvéAt':  null,
      });

      // 4. Notifier l'admin
      await NotificationService.createDemandeNotification(
        demandeId:  ref.id,
        auteur:     auteur,
        productNom: _nomCtrl.text.trim().toUpperCase(),
      );

      if (mounted) {
        _showSuccess();
        _reset();
      }
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _reset() {
    _nomCtrl.clear();
    _marqueCtrl.clear();
    _prixCtrl.clear();
    _quantiteCtrl.clear();
    _descriptionCtrl.clear();
    setState(() {
      _selectedCategorie = null;
      _pickedImage = null;
    });
  }

  // ── Image picker ───────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _pickedImage = picked);
  }

  // ── Helpers UI ─────────────────────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF059669), size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Demande envoyée !',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark)),
            const SizedBox(height: 12),
            const Text(
              'Votre demande a été transmise à l\'administrateur.\n'
              'Vous serez notifié dès qu\'elle sera traitée.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  color: AppColors.textMuted, height: 1.6),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Fermer',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          _buildMesDemandes(),
          const SizedBox(height: 32),
          _buildForm(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Espace Vendeur',
                    style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 6),
                Text(
                  'Proposez vos produits à la vente sur MTS.\n'
                  'L\'administrateur validera votre demande avant publication.',
                  style: TextStyle(fontSize: 13,
                      color: AppColors.bannerDesc, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sell_outlined,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildMesDemandes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Mes demandes', Icons.history_outlined),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('demandes_produits')
              .where('userId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(
                  color: AppColors.primary));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.1)),
                ),
                child: const Column(children: [
                  Icon(Icons.inbox_outlined, size: 36,
                      color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text('Aucune demande pour l\'instant.',
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textMuted)),
                ]),
              );
            }
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return _DemandeCard(data: d, id: doc.id);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              'Nouveau produit à vendre', Icons.add_box_outlined),
          const SizedBox(height: 24),
          _buildImagePicker(),
          const SizedBox(height: 20),
          _buildField('Nom du produit *', _nomCtrl,
              Icons.inventory_2_outlined,
              formatters: [
                TextInputFormatter.withFunction((o, n) =>
                    n.copyWith(text: n.text.toUpperCase()))
              ]),
          const SizedBox(height: 14),
          _buildField('Marque *', _marqueCtrl,
              Icons.branding_watermark_outlined),
          const SizedBox(height: 14),
          _buildCategoryDropdown(),
          const SizedBox(height: 14),
          isMobile
              ? Column(children: [
                  _buildField('Prix (DA) *', _prixCtrl,
                      Icons.sell_outlined,
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true)),
                  const SizedBox(height: 14),
                  _buildField('Quantité *', _quantiteCtrl,
                      Icons.layers_outlined,
                      keyboard: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                ])
              : Row(children: [
                  Expanded(
                      child: _buildField('Prix (DA) *', _prixCtrl,
                          Icons.sell_outlined,
                          keyboard:
                              const TextInputType.numberWithOptions(
                                  decimal: true))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _buildField('Quantité *', _quantiteCtrl,
                          Icons.layers_outlined,
                          keyboard: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ])),
                ]),
          const SizedBox(height: 14),
          _buildDescription(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined, size: 20),
              label: Text(
                  _isLoading
                      ? 'Envoi en cours...'
                      : 'Envoyer la demande',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline,
                  color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Votre produit sera examiné par l\'admin '
                  'avant d\'apparaître dans le catalogue.',
                  style: TextStyle(fontSize: 12,
                      color: Color(0xFF92400E), height: 1.5),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark)),
    ]);
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity, height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pickedImage != null
                ? AppColors.primary
                : const Color(0xFFE2E8F0),
            width: _pickedImage != null ? 2 : 1,
          ),
        ),
        child: _pickedImage != null
            ? Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(_pickedImage!.path,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _pickedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ])
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppColors.primary.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  const Text('Ajouter une photo (optionnel)',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ]),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboard,
            inputFormatters: formatters,
            style: const TextStyle(
                fontSize: 14, color: AppColors.primaryDark),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(icon, color: AppColors.primary, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
            ),
          ),
        ]);
  }

  Widget _buildCategoryDropdown() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catégorie *',
              style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedCategorie != null
                    ? AppColors.primary
                    : const Color(0xFFE2E8F0),
                width: _selectedCategorie != null ? 1.5 : 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategorie,
                isExpanded: true,
                hint: const Text('Sélectionner une catégorie',
                    style: TextStyle(
                        color: AppColors.textHint, fontSize: 14)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.primaryDark),
                onChanged: (v) =>
                    setState(() => _selectedCategorie = v),
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),
            ),
          ),
        ]);
  }

  Widget _buildDescription() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
              style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 3,
            maxLength: 400,
            style: const TextStyle(
                fontSize: 14, color: AppColors.primaryDark),
            decoration: InputDecoration(
              hintText: 'Décrivez votre produit...',
              hintStyle: const TextStyle(
                  color: AppColors.textHint, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ]);
  }
}

// ════════════════════════════════════════════════════════════════
// Carte demande individuelle
// ════════════════════════════════════════════════════════════════
class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.data, required this.id});
  final Map<String, dynamic> data;
  final String id;

  Color get _color {
    switch (data['statut']) {
      case 'approuvé': return const Color(0xFF059669);
      case 'refusé':   return const Color(0xFFDC2626);
      default:         return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (data['statut']) {
      case 'approuvé': return Icons.check_circle_outline;
      case 'refusé':   return Icons.cancel_outlined;
      default:         return Icons.access_time_rounded;
    }
  }

  String get _label {
    switch (data['statut']) {
      case 'approuvé': return 'Approuvé';
      case 'refusé':   return 'Refusé';
      default:         return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = data['imgProd'] as String? ?? '';
    final motif  = data['motifRefus'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imgUrl.isNotEmpty
              ? Image.network(imgUrl, width: 52, height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgFallback())
              : _imgFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['nom'] ?? '—',
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                Text(
                    '${data['prix'] ?? 0} DA  •  '
                    'Qté: ${data['quantite'] ?? 0}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                if (data['statut'] == 'refusé' &&
                    motif.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Motif : $motif',
                      style: const TextStyle(fontSize: 11,
                          color: Color(0xFFDC2626),
                          fontStyle: FontStyle.italic)),
                ],
              ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_icon, color: _color, size: 13),
            const SizedBox(width: 4),
            Text(_label,
                style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700, color: _color)),
          ]),
        ),
      ]),
    );
  }

  Widget _imgFallback() => Container(
    width: 52, height: 52,
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.medical_services_outlined,
        color: AppColors.primary, size: 24),
  );
}