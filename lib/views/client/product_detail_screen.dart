import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/login_link.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _searchBarController = TextEditingController();
  final TextEditingController _avisController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _data;
  String? _productId;
  bool _loading = true;
  String? _error;
  int _quantity = 1;

  // Favoris
  bool _isFav = false;
  bool _favLoading = false;

  // Avis
  int _selectedNote = 5;
  bool _avisLoading = false;
  List<Map<String, dynamic>> _avisList = [];
  bool _avisListLoading = true;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _avisController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // CHARGEMENT
  // ════════════════════════════════════════════════════════════════

  Future<void> _loadProduct() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;

    if (id == null) {
      setState(() {
        _error = 'Produit introuvable.';
        _loading = false;
      });
      return;
    }

    _productId = id;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('produits').doc(id).get();

      if (!doc.exists) {
        setState(() {
          _error = 'Ce produit n\'existe plus.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _data = doc.data();
        _loading = false;
      });

      // Charger favoris + avis en parallèle
      await Future.wait([_checkFav(), _loadAvis()]);
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement.';
        _loading = false;
      });
    }
  }

  // ── Favoris ───────────────────────────────────────────────────

  Future<void> _checkFav() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _productId == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('favoris')
              .doc(user.uid)
              .collection('items')
              .doc(_productId)
              .get();
      if (mounted) setState(() => _isFav = doc.exists);
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }
    final user = FirebaseAuth.instance.currentUser!;
    setState(() => _favLoading = true);
    try {
      final ref = FirebaseFirestore.instance
          .collection('favoris')
          .doc(user.uid)
          .collection('items')
          .doc(_productId);
      if (_isFav) {
        await ref.delete();
      } else {
        await ref.set({
          'nom': _data!['nom'],
          'prix': _data!['prix'],
          'imgProd': _data!['imgProd'] ?? '',
          'categorie': _data!['categorie'] ?? '',
          'marque': _data!['marque'] ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) setState(() => _isFav = !_isFav);
    } catch (_) {}
    if (mounted) setState(() => _favLoading = false);
  }

  // ── Avis ──────────────────────────────────────────────────────

  Future<void> _loadAvis() async {
    if (_productId == null) return;
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('avis')
              .doc(_productId)
              .collection('commentaires')
              .orderBy('date', descending: true)
              .get();
      if (mounted) {
        setState(() {
          _avisList =
              snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
          _avisListLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _avisListLoading = false);
    }
  }

  Future<void> _submitAvis() async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }
    final msg = _avisController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _avisLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final auteur =
          user.displayName ?? user.email?.split('@').first ?? 'Anonyme';

      await FirebaseFirestore.instance
          .collection('avis')
          .doc(_productId)
          .collection('commentaires')
          .add({
            'auteur': auteur,
            'note': _selectedNote,
            'message': msg,
            'date': FieldValue.serverTimestamp(),
            'userId': user.uid,
          });

      // Notifier l'admin
      await NotificationService.createCommentaireNotification(
        productId: _productId!,
        productNom: _data?['nom'] ?? 'Produit',
        auteur: auteur,
        note: _selectedNote,
        message: msg,
      );

      _avisController.clear();
      setState(() => _selectedNote = 5);
      await _loadAvis();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Votre avis a été publié. Merci !'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la publication.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _avisLoading = false);
  }

  // ── Panier ────────────────────────────────────────────────────

  // void _addToCart() {
  //   if (!_isLoggedIn) {
  //     _showLoginDialog();
  //     return;
  //   }
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('« ${_data!['nom']} » × $_quantity ajouté(s) au panier'),
  //       backgroundColor: AppColors.primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //   );
  // }

  Future<void> _addToCart() async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }

    //  Vérifier si le produit est autorisé pour ce client
    final acheteurs =
        (_data!['achteurAutoris'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Si le produit est réservé aux professionnels uniquement
    if (acheteurs.isNotEmpty &&
        !acheteurs.contains('Autre') &&
        acheteurs.contains('Professionnel')) {
      // Récupérer le rôle du client depuis Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'] ?? 'autre';

      if (role != 'professionnel') {
        // Afficher l'alerte
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFFF59E0B)),
                      SizedBox(width: 10),
                      Text(
                        'Accès restreint',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.medical_information_outlined,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ce produit est réservé aux professionnels de santé uniquement.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryDark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Vous ne pouvez pas acheter ce produit avec votre compte actuel.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Créer un compte pro',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
          );
        }
        return;
      }
    }

    //  Autorisé — ajouter au panier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('« ${_data!['nom']} » × $_quantity ajouté(s) au panier'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary),
                SizedBox(width: 10),
                Text(
                  'Connexion requise',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Veuillez vous connecter pour effectuer cette action.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (_error != null)
              _buildErrorState()
            else ...[
              _buildBody(),
              _buildAvisSection(),
            ],
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HEADER / NAVBAR
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildNavbar(),
            if (_data != null) ...[
              const SizedBox(height: 24),
              _buildBreadcrumb(),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height:
          _isMobile
              ? AppDimens.navbarHeightMobile
              : AppDimens.navbarHeightDesktop,
      margin: EdgeInsets.symmetric(
        horizontal:
            _isMobile ? AppDimens.navbarMarginHMobile : AppDimens.navbarMarginH,
        vertical: AppDimens.navbarMarginV,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.navbarBg,
        borderRadius: BorderRadius.circular(AppDimens.navbarRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'images/logo1.png',
            height:
                _isMobile
                    ? AppDimens.logoHeightMobile
                    : AppDimens.logoHeightDesktop,
            width:
                _isMobile
                    ? AppDimens.logoWidthMobile
                    : AppDimens.logoWidthDesktop,
            fit: BoxFit.contain,
            errorBuilder:
                (_, __, ___) => const Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
          ),
          const SizedBox(width: 10),
          if (!_isMobile) _buildLogoText(),
          const Spacer(),
          if (!_isMobile) ...[
            NavItem(
              title: 'Boutique',
              onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
            ),
            NavItem(
              title: 'À Propos',
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            NavItem(
              title: 'Contactez-nous',
              onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
            ),
            NavItem(
              title: 'CGU',
              onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
            ),
            const SizedBox(width: 8),
            AppSearchBar(
              controller: _searchBarController,
              width:
                  _isTablet
                      ? AppDimens.searchWidthTablet
                      : AppDimens.searchWidthDesktop,
              onSubmitted:
                  (val) => Navigator.pushNamed(
                    context,
                    AppRoutes.boutique,
                    arguments: {'query': val},
                  ),
            ),
            const SizedBox(width: 14),
            LoginLink(
              onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
              onRegister:
                  () => Navigator.pushNamed(context, AppRoutes.register),
            ),
          ],
          if (_isMobile)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoText() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MTS Médico Dentaire',
          style: TextStyle(
            fontSize: AppDimens.fontLogoName,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'COMPTOIR DENTAIRE',
          style: TextStyle(
            fontSize: AppDimens.fontLogoSub,
            color: AppColors.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 16 : 64),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.home),
            child: const Text(
              'Accueil',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.bannerWelcome,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.bannerDesc,
              size: 16,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
            child: const Text(
              'Boutique',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.bannerWelcome,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.bannerDesc,
              size: 16,
            ),
          ),
          Flexible(
            child: Text(
              _data?['nom'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BODY PRINCIPAL (image + infos)
  // ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    final data = _data!;
    final nom = data['nom'] ?? 'Sans nom';
    final prix = (data['prix'] as num?)?.toDouble() ?? 0.0;
    final description = data['descreption'] ?? '';
    final categorie = data['categorie'] ?? '—';
    final marque = data['marque'] ?? '—';
    final quantite = (data['quantite'] as num?)?.toInt() ?? 0;
    final imgUrl = data['imgProd'] as String?;
    final epuise = quantite == 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 64,
        vertical: 48,
      ),
      child:
          _isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(imgUrl: imgUrl, epuise: epuise),
                  const SizedBox(height: 28),
                  _buildInfoSection(
                    nom: nom,
                    prix: prix,
                    description: description,
                    categorie: categorie,
                    marque: marque,
                    quantite: quantite,
                    epuise: epuise,
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildImageSection(imgUrl: imgUrl, epuise: epuise),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 6,
                    child: _buildInfoSection(
                      nom: nom,
                      prix: prix,
                      description: description,
                      categorie: categorie,
                      marque: marque,
                      quantite: quantite,
                      epuise: epuise,
                    ),
                  ),
                ],
              ),
    );
  }

  // ── Section Image ─────────────────────────────────────────────

  Widget _buildImageSection({required String? imgUrl, required bool epuise}) {
    final hasImg = imgUrl != null && imgUrl.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: _isMobile ? 260 : 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:
                    hasImg
                        ? Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                value:
                                    progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        )
                        : _imageFallback(),
              ),
            ),
            if (epuise)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ÉPUISÉ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Miniature
        if (hasImg) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF0F7FF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 72,
              color: AppColors.primary.withOpacity(0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune image',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Infos ─────────────────────────────────────────────

  Widget _buildInfoSection({
    required String nom,
    required double prix,
    required String description,
    required String categorie,
    required String marque,
    required int quantite,
    required bool epuise,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges + Favori
        Row(
          children: [
            _badge(categorie, AppColors.primary),
            const SizedBox(width: 8),
            _badge(marque, const Color(0xFF7C3AED)),
            const Spacer(),
            // Bouton favori
            GestureDetector(
              onTap: _toggleFav,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      _isFav
                          ? const Color(0xFFDC2626).withOpacity(0.1)
                          : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _isFav
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFE2E8F0),
                  ),
                ),
                child:
                    _favLoading
                        ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFDC2626),
                          ),
                        )
                        : Icon(
                          _isFav ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: const Color(0xFFDC2626),
                        ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nom
        Text(
          nom,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Prix — toujours visible
        Text(
          '${prix.toStringAsFixed(0)} DA',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
        ],

        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 20),

        // Stock
        Row(
          children: [
            Icon(
              epuise ? Icons.remove_circle_outline : Icons.check_circle_outline,
              size: 18,
              color: epuise ? const Color(0xFFDC2626) : const Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            Text(
              epuise
                  ? 'Rupture de stock'
                  : 'En stock ($quantite unités disponibles)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    epuise ? const Color(0xFFDC2626) : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quantité + Panier
        if (!epuise) ...[
          Row(
            children: [
              // Sélecteur quantité
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                      icon: const Icon(Icons.remove, size: 18),
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_quantity < quantite) {
                          setState(() => _quantity++);
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Bouton panier
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(
                    'Ajouter au panier',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Retour boutique
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.boutique),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Retour à la boutique'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // SECTION AVIS
  // ──────────────────────────────────────────────────────────────

  Widget _buildAvisSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 64,
        vertical: 48,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Avis clients',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              if (_avisList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_avisList.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),

          // Note moyenne
          if (_avisList.isNotEmpty) ...[
            _buildNoteMoyenne(),
            const SizedBox(height: 32),
          ],

          // Formulaire avis
          _buildAvisForm(),
          const SizedBox(height: 32),

          // Liste avis
          _buildAvisList(),
        ],
      ),
    );
  }

  Widget _buildNoteMoyenne() {
    final total = _avisList.fold<double>(
      0,
      (sum, a) => sum + ((a['note'] as num?)?.toDouble() ?? 0),
    );
    final moyenne = total / _avisList.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.06),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                moyenne.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              _buildStars(moyenne.round(), size: 20),
              const SizedBox(height: 4),
              Text(
                '${_avisList.length} avis',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(child: _buildNoteDistribution()),
        ],
      ),
    );
  }

  Widget _buildNoteDistribution() {
    return Column(
      children:
          [5, 4, 3, 2, 1].map((n) {
            final count =
                _avisList
                    .where((a) => (a['note'] as num?)?.toInt() == n)
                    .length;
            final pct = _avisList.isEmpty ? 0.0 : count / _avisList.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    '$n',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFF59E0B),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAvisForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laisser un avis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),

          // Note sélection
          Row(
            children: [
              const Text(
                'Note :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              ...List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNote = star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      star <= _selectedNote ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 28,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                _noteLegend(_selectedNote),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Champ texte
          TextField(
            controller: _avisController,
            maxLines: 3,
            maxLength: 400,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience avec ce produit...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton soumettre
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _avisLoading ? null : _submitAvis,
              icon:
                  _avisLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                _isLoggedIn
                    ? 'Publier mon avis'
                    : 'Connectez-vous pour laisser un avis',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisList() {
    if (_avisListLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_avisList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucun avis pour ce produit.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            const Text(
              'Soyez le premier à donner votre avis !',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _avisList.map((avis) => _buildAvisCard(avis)).toList(),
    );
  }

  Widget _buildAvisCard(Map<String, dynamic> avis) {
    final auteur = avis['auteur'] ?? 'Anonyme';
    final note = (avis['note'] as num?)?.toInt() ?? 0;
    final message = avis['message'] ?? '';
    final date = avis['date'];
    String dateStr = '';
    if (date is Timestamp) {
      final d = date.toDate();
      dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    auteur[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auteur,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStars(note, size: 16),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(int note, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < note ? Icons.star : Icons.star_border,
          color: const Color(0xFFF59E0B),
          size: size,
        ),
      ),
    );
  }

  String _noteLegend(int note) {
    switch (note) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Moyen';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent !';
      default:
        return '';
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ÉTAT ERREUR
  // ──────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.boutique),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retour à la boutique'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FOOTER
  // ──────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: EdgeInsets.fromLTRB(
        _isMobile ? 20 : 48,
        36,
        _isMobile ? 20 : 48,
        24,
      ),
      child: Column(
        children: [
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2025 MTS Médico-Dentaire — Tous droits réservés',
                style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
              ),
              if (!_isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Text(
                    'Flutter + Firebase',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.footerAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
