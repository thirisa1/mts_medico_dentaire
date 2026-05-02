import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/cart_icon_widget.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/login_link.dart';
import '../../widgets/prouitsCart.dart';

class BoutiqueScreen extends StatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  State<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

class _BoutiqueScreenState extends State<BoutiqueScreen> {
  // ── Contrôleurs ───────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchBarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── État UI ───────────────────────────────────────────────────
  bool _menuOpen = false;
  bool _isGridView = true;
  String _searchQuery = '';
  String? _selectedCategory;
  int _currentPage = 1;
  static const int _perPage = 12;

  // ── Données Firestore ─────────────────────────────────────────
  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filtered = [];
  List<String> _categories = [];
  bool _loading = true;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ── Pagination ────────────────────────────────────────────────
  int get _totalPages => (_filtered.length / _perPage).ceil().clamp(1, 999);
  List<QueryDocumentSnapshot> get _pageDocs {
    final start = (_currentPage - 1) * _perPage;
    final end = (start + _perPage).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Charger d'abord les produits
      await _loadProducts();

      // 2. Ensuite appliquer la query si elle existe
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?['query'] != null) {
        final q = args!['query'] as String;
        _searchController.text = q;
        _onSearch(q);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchBarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // CHARGEMENT FIRESTORE
  // ════════════════════════════════════════════════════════════════

  // Future<void> _loadProducts() async {
  //   setState(() => _loading = true);
  //   try {
  //     final snap =
  //         await FirebaseFirestore.instance
  //             .collection('produits')
  //             .orderBy('nom')
  //             .get();

  //     final cats = <String>{};
  //     for (final doc in snap.docs) {
  //       final cat = (doc.data()['categorie'] as String?) ?? '';
  //       if (cat.isNotEmpty) cats.add(cat);
  //     }

  //     setState(() {
  //       _allDocs = snap.docs;
  //       _categories = cats.toList()..sort();
  //       _loading = false;
  //     });
  //     _applyFilters();
  //   } catch (e) {
  //     setState(() => _loading = false);
  //   }
  // }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('produits')
              .orderBy('nom')
              .get();

      final cats = <String>{};
      for (final doc in snap.docs) {
        final cat = (doc.data()['categorie'] as String?) ?? '';
        if (cat.isNotEmpty) cats.add(cat);
      }

      setState(() {
        _allDocs = snap.docs;
        _categories = cats.toList()..sort();
        _loading = false;
      });

      _applyFilters(); // ← garde-le ici pour le rechargement manuel
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    final q = _searchQuery.toLowerCase().trim();
    setState(() {
      _filtered =
          _allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nom = (data['nom'] as String? ?? '').toLowerCase();
            final cat = (data['categorie'] as String? ?? '').toLowerCase();
            final marque = (data['marque'] as String? ?? '').toLowerCase();
            final desc = (data['descreption'] as String? ?? '').toLowerCase();

            final matchSearch =
                q.isEmpty ||
                nom.contains(q) ||
                cat.contains(q) ||
                marque.contains(q) ||
                desc.contains(q);

            final matchCat =
                _selectedCategory == null ||
                (data['categorie'] as String? ?? '') == _selectedCategory;

            return matchSearch && matchCat;
          }).toList();
      _currentPage = 1;
    });
  }

  void _onSearch(String val) {
    setState(() => _searchQuery = val);
    _applyFilters();
  }

  void _selectCategory(String? cat) {
    setState(() => _selectedCategory = cat);
    _applyFilters();
    if (_isMobile) Navigator.pop(context); // fermer drawer mobile
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: _isMobile ? _buildDrawer() : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            if (!_isMobile && _menuOpen) _buildMobileMenu(),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HEADER
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
            const SizedBox(height: 40),
            _buildPageTitle(),
            const SizedBox(height: 48),
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
              onSubmitted: _onSearch,
            ),
            const SizedBox(width: 14),
            const CartIconWidget(),
            const SizedBox(width: 8),
            LoginLink(
              onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
              onRegister:
                  () => Navigator.pushNamed(context, AppRoutes.register),
            ),
            // const SizedBox(width: 14),
            // LoginLink(
            //   onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
            //   onRegister:
            //       () => Navigator.pushNamed(context, AppRoutes.register),
            // ),
          ],
          if (_isMobile)
            Builder(
              builder:
                  (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primaryDark),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
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

  Widget _buildMobileMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.navbarMarginHMobile,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mobileMenuBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _mobileNavItem(
            Icons.store_outlined,
            'Boutique',
            () => Navigator.pushNamed(context, AppRoutes.boutique),
          ),
          _mobileNavItem(
            Icons.info_outline,
            'À Propos',
            () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          _mobileNavItem(
            Icons.mail_outline,
            'Contactez-nous',
            () => Navigator.pushNamed(context, AppRoutes.contact),
          ),
          _mobileNavItem(
            Icons.description_outlined,
            'CGU',
            () => Navigator.pushNamed(context, AppRoutes.cgu),
          ),
          const Divider(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.login),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Se connecter / S'inscrire",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimens.fontConnexion,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileNavItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildPageTitle() {
    return Column(
      children: [
        const Text(
          'NOTRE CATALOGUE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.bannerWelcome,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Boutique',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Découvrez notre catalogue complet de matériel médico-dentaire professionnel.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.bannerDesc,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        // Breadcrumb
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const Text(
              'Boutique',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DRAWER MOBILE (catégories)
  // ──────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
                ),
              ),
              child: const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(child: _buildCategoryList()),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BODY : sidebar + produits
  // ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 12 : 40,
        vertical: 40,
      ),
      child:
          _isMobile
              ? _buildMobileBody()
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar fixe
                  SizedBox(width: 240, child: _buildSidebar()),
                  const SizedBox(width: 28),
                  // Zone produits
                  Expanded(child: _buildProductsZone()),
                ],
              ),
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        _buildMobileToolbar(),
        const SizedBox(height: 16),
        _buildProductsZone(),
      ],
    );
  }

  // ── Toolbar mobile ────────────────────────────────────────────

  Widget _buildMobileToolbar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearch,
            onChanged: (v) {
              //if (v.isEmpty) _onSearch('');
              _onSearch(v);
            },
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 18,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Builder(
          builder:
              (ctx) => ElevatedButton.icon(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Filtres'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
        ),
        const SizedBox(width: 8),
        _buildViewToggle(),
      ],
    );
  }

  // ── SIDEBAR ───────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recherche
        _buildSidebarSearch(),
        const SizedBox(height: 24),
        // Catégories
        _buildSidebarCard(child: _buildCategoryList()),
      ],
    );
  }

  Widget _buildSidebarSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearch,
        onChanged: (v) {
          // if (v.isEmpty) _onSearch('');
          _onSearch(v);
        },
        decoration: InputDecoration(
          hintText: 'Recherche...',
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
            size: 18,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Catégories de produits',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        // Toutes les catégories
        _buildCategoryItem(null, 'Tous les produits'),
        // Divider
        const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Color(0xFFE2E8F0),
        ),
        // Liste catégories
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          ..._categories.map((cat) => _buildCategoryItem(cat, cat)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryItem(String? value, String label) {
    final selected = _selectedCategory == value;
    return InkWell(
      onTap: () => _selectCategory(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary, size: 14),
          ],
        ),
      ),
    );
  }

  // ── ZONE PRODUITS ─────────────────────────────────────────────

  Widget _buildProductsZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductsToolbar(),
        const SizedBox(height: 20),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_filtered.isEmpty)
          _buildEmptyState()
        else ...[
          _isGridView ? _buildGrid() : _buildList(),
          const SizedBox(height: 32),
          _buildPagination(),
        ],
      ],
    );
  }

  Widget _buildProductsToolbar() {
    return Row(
      children: [
        // Résultats
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              children: [
                TextSpan(
                  text: '${_filtered.length} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const TextSpan(text: 'produit(s) trouvé(s)'),
                if (_selectedCategory != null) ...[
                  const TextSpan(text: ' dans '),
                  TextSpan(
                    text: _selectedCategory,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Filtre actif
        if (_selectedCategory != null)
          GestureDetector(
            onTap: () => _selectCategory(null),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCategory!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 12, color: AppColors.primary),
                ],
              ),
            ),
          ),
        // Toggle vue
        if (!_isMobile) _buildViewToggle(),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(Icons.grid_view_rounded, true),
          _toggleBtn(Icons.view_list_rounded, false),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool isGrid) {
    final active = _isGridView == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGridView = isGrid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }

  // ── GRILLE ────────────────────────────────────────────────────

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= 900) {
          columns = 3;
        } else if (constraints.maxWidth >= 580) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemCount: _pageDocs.length,
          itemBuilder: (context, index) => _buildProductCard(_pageDocs[index]),
        );
      },
    );
  }

  // ── LISTE ─────────────────────────────────────────────────────

  Widget _buildList() {
    return Column(
      children:
          _pageDocs
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProductListItem(doc),
                ),
              )
              .toList(),
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final quantite = (data['quantite'] as num?)?.toInt() ?? 0;

    return Stack(
      children: [
        ProductCard(
          id: doc.id,
          nom: data['nom'] ?? 'Sans nom',
          categorie: data['categorie'] ?? '—',
          description: data['descreption'] ?? '',
          marque: data['marque'] ?? '—',
          prix: (data['prix'] as num?)?.toDouble() ?? 0.0,
          imgProd: data['imgProd'] as String?,
          quantite: (data['quantite'] as num?)?.toInt() ?? 0,
          isLoggedIn: _isLoggedIn,
        ),
        // ProductCard(
        //   id: doc.id,
        //   nom: data['nom'] ?? 'Sans nom',
        //   categorie: data['categorie'] ?? '—',
        //   description: data['descreption'] ?? '',
        //   marque: data['marque'] ?? '—',
        //   prix: (data['prix'] as num?)?.toDouble() ?? 0.0,
        //   isLoggedIn: _isLoggedIn,
        // ),
        // Badge épuisé
        if (quantite == 0)
          Positioned(
            top: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: const Color(0xFFDC2626),
                child: const Text(
                  'ÉPUISÉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductListItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final quantite = (data['quantite'] as num?)?.toInt() ?? 0;
    final epuise = quantite == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.13),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 36,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                if (epuise)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ÉPUISÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _chip(data['categorie'] ?? '—', AppColors.primary),
                      const SizedBox(width: 6),
                      _chip(data['marque'] ?? '—', const Color(0xFF7C3AED)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['nom'] ?? 'Sans nom',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['descreption'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Prix + boutons
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _isLoggedIn
                      ? '${((data['prix'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)} DA'
                      : '— DA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  epuise ? 'Rupture de stock' : 'En stock ($quantite)',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        epuise
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF059669),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: {'id': doc.id},
                      ),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('Détails', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── PAGINATION ────────────────────────────────────────────────

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    final pages = _buildPageNumbers();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Précédent
        _pageBtn(
          icon: Icons.chevron_left,
          onTap: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
        ),
        const SizedBox(width: 8),
        // Numéros
        ...pages.map((p) {
          if (p == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          final active = p == _currentPage;
          return GestureDetector(
            onTap: () => _goToPage(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  '$p',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        // Suivant
        _pageBtn(
          icon: Icons.chevron_right,
          onTap:
              _currentPage < _totalPages
                  ? () => _goToPage(_currentPage + 1)
                  : null,
        ),
      ],
    );
  }

  List<int> _buildPageNumbers() {
    final pages = <int>[];
    if (_totalPages <= 7) {
      for (int i = 1; i <= _totalPages; i++) pages.add(i);
    } else {
      pages.add(1);
      if (_currentPage > 3) pages.add(-1); // ...
      for (
        int i = (_currentPage - 1).clamp(2, _totalPages - 1);
        i <= (_currentPage + 1).clamp(2, _totalPages - 1);
        i++
      ) {
        pages.add(i);
      }
      if (_currentPage < _totalPages - 2) pages.add(-1); // ...
      pages.add(_totalPages);
    }
    return pages;
  }

  Widget _pageBtn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }

  // ── ÉTAT VIDE ─────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez une autre recherche ou catégorie.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _onSearch('');
              _selectCategory(null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Réinitialiser les filtres'),
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
