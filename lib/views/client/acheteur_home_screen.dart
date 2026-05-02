import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/cart_icon_widget.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/notification_bell_widget.dart';

// ════════════════════════════════════════════════════════════════
// Sections disponibles
// ════════════════════════════════════════════════════════════════
enum _Section {
  dashboard,
  boutique,
  Hcommandes,
  favoris,
  compte,
  vendre, // pro uniquement
}

class AcheteurHomeScreen extends StatefulWidget {
  final String role;
  const AcheteurHomeScreen({super.key, required this.role});

  @override
  State<AcheteurHomeScreen> createState() => _AcheteurHomeScreenState();
}

class _AcheteurHomeScreenState extends State<AcheteurHomeScreen> {
  _Section _currentSection = _Section.dashboard;
  final TextEditingController _searchBarController = TextEditingController();
  bool _menuOpen = false;

  bool get _isPro => widget.role == 'professionnel';
  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;

  // ── Items de navigation ───────────────────────────────────────
  List<_NavItem> get _navItems => [
    _NavItem(_Section.dashboard, Icons.dashboard_outlined, 'Tableau de bord'),
    _NavItem(_Section.boutique, Icons.store_outlined, 'Boutique'),
    _NavItem(
      _Section.Hcommandes,
      Icons.receipt_long_outlined,
      'Historique Commandes',
    ),
    _NavItem(_Section.favoris, Icons.favorite_outline, 'Liste de favoris'),
    if (_isPro) _NavItem(_Section.vendre, Icons.sell_outlined, 'Vendre'),
    _NavItem(
      _Section.compte,
      Icons.manage_accounts_outlined,
      'Détails du compte',
    ),
  ];

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Color(0xFFDC2626)),
                SizedBox(width: 10),
                Text(
                  'Déconnexion',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
    );
    if (confirm == true && mounted) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: _isMobile ? _buildDrawer() : null,
      body: Column(
        children: [
          _buildNavbar(),
          Expanded(
            child:
                _isMobile
                    ? _buildBody()
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebar(),
                        Expanded(child: _buildBody()),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // NAVBAR
  // ──────────────────────────────────────────────────────────────

  Widget _buildNavbar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
        ),
      ),
      child: SafeArea(
        child: Container(
          height:
              _isMobile
                  ? AppDimens.navbarHeightMobile
                  : AppDimens.navbarHeightDesktop,
          margin: EdgeInsets.symmetric(
            horizontal:
                _isMobile
                    ? AppDimens.navbarMarginHMobile
                    : AppDimens.navbarMarginH,
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
              // Logo
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
              if (!_isMobile) ...[
                const Column(
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
                ),
              ],
              const Spacer(),
              if (!_isMobile) ...[
                NavItem(
                  title: 'Accueil',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                ),
                NavItem(
                  title: 'à propos',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
                NavItem(
                  title: 'contactez-nous',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
                ),
                NavItem(
                  title: 'CGU/CGV',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
                ),
                const SizedBox(width: 8),
                // AppSearchBar(
                //   controller: _searchBarController,
                //   width: AppDimens.searchWidthDesktop,
                //   onSubmitted:
                //       (val) => Navigator.pushNamed(
                //         context,
                //         AppRoutes.about,
                //         arguments: {'query': val},
                //       ),
                // ),
                const NotificationBellWidget(),
                const SizedBox(width: 14),
                const CartIconWidget(),
                const SizedBox(width: 14),
                // Badge rôle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isPro
                            ? AppColors.primary.withOpacity(0.1)
                            : const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          _isPro
                              ? AppColors.primary.withOpacity(0.3)
                              : const Color(0xFF059669).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPro
                            ? Icons.medical_information_outlined
                            : Icons.person_outline,
                        size: 14,
                        color:
                            _isPro
                                ? AppColors.primary
                                : const Color(0xFF059669),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPro ? 'Professionnel' : 'Client',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              _isPro
                                  ? AppColors.primary
                                  : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_isMobile)
                Builder(
                  builder:
                      (ctx) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // SIDEBAR DESKTOP
  // ──────────────────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          // Profil
          _buildSidebarProfile(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                ..._navItems.map((item) => _buildSidebarItem(item)),
                const Divider(
                  height: 24,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFE2E8F0),
                ),
                // Déconnexion
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  title: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  onTap: _logout,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarProfile() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Mon compte',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item) {
    final active = _currentSection == item.section;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: active ? AppColors.primary : AppColors.textMuted,
          size: 20,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.primaryDark,
          ),
        ),
        selected: active,
        selectedTileColor: AppColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() => _currentSection = item.section);
          if (item.section == _Section.boutique) {
            Navigator.pushNamed(context, AppRoutes.boutique);
          }
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DRAWER MOBILE
  // ──────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
                ),
              ),
              child: _buildSidebarProfile(),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._navItems.map(
                    (item) => ListTile(
                      leading: Icon(
                        item.icon,
                        color:
                            _currentSection == item.section
                                ? AppColors.primary
                                : AppColors.textMuted,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight:
                              _currentSection == item.section
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentSection = item.section);
                        if (item.section == _Section.boutique) {
                          Navigator.pushNamed(context, AppRoutes.boutique);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: Color(0xFFDC2626)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BODY — contenu selon section
  // ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 32),
      child: switch (_currentSection) {
        _Section.dashboard => _buildDashboard(),
        _Section.Hcommandes => _buildCommandes(),
        _Section.favoris => _buildFavoris(),
        _Section.compte => _buildCompte(),
        _Section.vendre => _buildVendre(),
        _Section.boutique => _buildDashboard(), // redirigé via pushNamed
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  // TABLEAU DE BORD
  // ──────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bienvenue
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, ${user?.displayName ?? 'Client'} ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isPro
                    ? 'Bienvenue sur votre espace professionnel MTS.'
                    : 'Bienvenue sur votre espace client MTS.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.bannerDesc,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Cartes raccourcis
        _buildSectionTitle('Accès rapide'),
        const SizedBox(height: 16),
        _buildDashboardGrid(),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    final items = [
      _DashCard(
        icon: Icons.store_outlined,
        label: 'Boutique',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
      ),
      _DashCard(
        icon: Icons.receipt_long_outlined,
        label: 'Commandes',
        color: const Color(0xFF7C3AED),
        onTap: () => setState(() => _currentSection = _Section.Hcommandes),
      ),
      _DashCard(
        icon: Icons.favorite_outline,
        label: 'Favoris',
        color: const Color(0xFFEC4899),
        onTap: () => setState(() => _currentSection = _Section.favoris),
      ),
      _DashCard(
        icon: Icons.manage_accounts_outlined,
        label: 'Mon compte',
        color: const Color(0xFF059669),
        onTap: () => setState(() => _currentSection = _Section.compte),
      ),
      if (_isPro)
        _DashCard(
          icon: Icons.sell_outlined,
          label: 'Vendre',
          color: const Color(0xFFF59E0B),
          onTap: () => setState(() => _currentSection = _Section.vendre),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isMobile ? 2 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // // ──────────────────────────────────────────────────────────────
  // // COMMANDES
  // // ──────────────────────────────────────────────────────────────

  Widget _buildCommandes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return _buildEmptyState('Connectez-vous pour voir vos commandes.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mes commandes'),
        const SizedBox(height: 16),
        // ── Notifications livraison ──
        StreamBuilder<List<AppNotification>>(
          stream: NotificationService.myNotificationsStream(),
          builder: (context, snapNotif) {
            debugPrint('[Commandes] state: ${snapNotif.connectionState}');
            debugPrint('[Commandes] error: ${snapNotif.error}');
            final notifs = snapNotif.data ?? [];
            final unread = notifs.where((n) => !n.lu).toList();
            return Column(
              children: [
                // Badge notification si non lues
                if (unread.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF059669).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${unread.length} nouvelle${unread.length > 1 ? 's' : ''} notification${unread.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => NotificationService.markAllAsRead(),
                              child: const Text(
                                'Tout marquer lu',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF059669),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...unread.map((n) => _buildNotifCard(n)),
                      ],
                    ),
                  ),
                // ── Liste des commandes ──
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('commandes')
                          .where('userId', isEqualTo: uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (snap.hasError) {
                      debugPrint('[Commandes] erreur: ${snap.error}');
                      return _buildEmptyState(
                        'Erreur de chargement. Réessayez.',
                      );
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return _buildEmptyState(
                        'Vous n\'avez pas encore de commandes.',
                        icon: Icons.receipt_long_outlined,
                        actionLabel: 'Découvrir la boutique',
                        onAction:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.boutique,
                            ),
                      );
                    }
                    return Column(
                      children:
                          docs.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return _buildCommandeCard(d, doc.id);
                          }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Carte notification livraison ──
  Widget _buildNotifCard(AppNotification n) {
    return GestureDetector(
      onTap: () async {
        await NotificationService.markAsRead(n.id);
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.all(28),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF059669),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        n.titre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF059669).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          n.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            height: 1.7,
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Fermer',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF059669),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.titre,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    n.orderRef,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte commande améliorée ──
  Widget _buildCommandeCard(Map<String, dynamic> d, String id) {
    final statut = d['statut'] ?? 'en_attente';
    final total = (d['total'] ?? 0).toDouble();

    Color statutColor;
    String statutLabel;
    IconData statutIcon;

    switch (statut) {
      case 'livree':
        statutColor = const Color(0xFF059669);
        statutLabel = 'Livrée';
        statutIcon = Icons.done_all_rounded;
        break;
      case 'annulee':
        statutColor = const Color(0xFFDC2626);
        statutLabel = 'Annulée';
        statutIcon = Icons.cancel_outlined;
        break;
      default:
        statutColor = const Color(0xFFF59E0B);
        statutLabel = 'En attente';
        statutIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statutColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statutIcon, color: statutColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${total.toStringAsFixed(0)} DA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statutColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statutColor.withOpacity(0.3)),
            ),
            child: Text(
              statutLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statutColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCommandes() {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null)
  //     return _buildEmptyState('Connectez-vous pour voir vos commandes.');

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionTitle('Mes commandes'),
  //       const SizedBox(height: 16),
  //       StreamBuilder<QuerySnapshot>(
  //         stream:
  //             FirebaseFirestore.instance
  //                 .collection('commandes')
  //                 .where('userId', isEqualTo: uid)
  //                 .orderBy('createdAt', descending: true)
  //                 .snapshots(),
  //         builder: (context, snap) {
  //           if (snap.connectionState == ConnectionState.waiting) {
  //             return const Center(
  //               child: CircularProgressIndicator(color: AppColors.primary),
  //             );
  //           }
  //           final docs = snap.data?.docs ?? [];
  //           if (docs.isEmpty) {
  //             return _buildEmptyState(
  //               'Vous n\'avez pas encore de commandes.',
  //               icon: Icons.receipt_long_outlined,
  //               actionLabel: 'Découvrir la boutique',
  //               onAction:
  //                   () => Navigator.pushNamed(context, AppRoutes.boutique),
  //             );
  //           }
  //           return Column(
  //             children:
  //                 docs.map((doc) {
  //                   final d = doc.data() as Map<String, dynamic>;
  //                   return _buildCommandeCard(d, doc.id);
  //                 }).toList(),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCommandeCard(Map<String, dynamic> d, String id) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 44,
  //           height: 44,
  //           decoration: BoxDecoration(
  //             color: AppColors.primary.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: const Icon(
  //             Icons.shopping_bag_outlined,
  //             color: AppColors.primary,
  //             size: 22,
  //           ),
  //         ),
  //         const SizedBox(width: 14),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Commande #${id.substring(0, 8).toUpperCase()}',
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w700,
  //                   color: AppColors.primaryDark,
  //                 ),
  //               ),
  //               Text(
  //                 '${d['total'] ?? 0} DA',
  //                 style: const TextStyle(
  //                   fontSize: 13,
  //                   color: AppColors.textMuted,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF059669).withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Text(
  //             d['statut'] ?? 'En attente',
  //             style: const TextStyle(
  //               fontSize: 11,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF059669),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ──────────────────────────────────────────────────────────────
  // FAVORIS
  // ──────────────────────────────────────────────────────────────

  Widget _buildFavoris() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return _buildEmptyState('Connectez-vous pour voir vos favoris.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ma liste de favoris'),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('favoris')
                  .doc(uid)
                  .collection('items')
                  .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return _buildEmptyState(
                'Votre liste de favoris est vide.',
                icon: Icons.favorite_outline,
                actionLabel: 'Explorer la boutique',
                onAction:
                    () => Navigator.pushNamed(context, AppRoutes.boutique),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _isMobile ? 1 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i].data() as Map<String, dynamic>;
                return _buildFavoriCard(d, docs[i].id, uid);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFavoriCard(
    Map<String, dynamic> d,
    String productId,
    String uid,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              child:
                  d['imgProd'] != null && d['imgProd'].isNotEmpty
                      ? Image.network(
                        d['imgProd'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgFallback(),
                      )
                      : _imgFallback(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['nom'] ?? '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${d['prix'] ?? 0} DA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: {'id': productId},
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Voir',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Supprimer des favoris
                    GestureDetector(
                      onTap:
                          () =>
                              FirebaseFirestore.instance
                                  .collection('favoris')
                                  .doc(uid)
                                  .collection('items')
                                  .doc(productId)
                                  .delete(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFDC2626),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.medical_services_outlined,
          size: 40,
          color: AppColors.primary.withOpacity(0.25),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DÉTAILS DU COMPTE
  // ──────────────────────────────────────────────────────────────

  Widget _buildCompte() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _buildEmptyState('Non connecté.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Détails du compte'),
        const SizedBox(height: 16),
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (!snap.hasData || !snap.data!.exists) {
              return _buildEmptyState('Profil introuvable.');
            }
            final d = snap.data!.data() as Map<String, dynamic>;
            return _CompteForm(data: d, uid: uid, isPro: _isPro);
          },
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // VENDRE (PRO UNIQUEMENT)
  // ──────────────────────────────────────────────────────────────

  Widget _buildVendre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Espace Vendeur'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sell_outlined,
                  color: Color(0xFFF59E0B),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Espace Vendeur Professionnel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'En tant que professionnel MTS, vous pouvez proposer vos produits à la vente.\nCette fonctionnalité sera disponible prochainement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bientôt disponible',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    String message, {
    IconData icon = Icons.inbox_outlined,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.primary.withOpacity(0.25)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Formulaire détails du compte
// ════════════════════════════════════════════════════════════════

class _CompteForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final String uid;
  final bool isPro;

  const _CompteForm({
    required this.data,
    required this.uid,
    required this.isPro,
  });

  @override
  State<_CompteForm> createState() => _CompteFormState();
}

class _CompteFormState extends State<_CompteForm> {
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.data['prenom'] ?? '');
    _nomCtrl = TextEditingController(text: widget.data['nom'] ?? '');
    _emailCtrl = TextEditingController(text: widget.data['email'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.data['telephone'] ?? '');
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'prenom': _prenomCtrl.text.trim(),
            'nom': _nomCtrl.text.trim(),
            'telephone': _phoneCtrl.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text('Informations mises à jour !'),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge rôle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color:
                  widget.isPro
                      ? AppColors.primary.withOpacity(0.1)
                      : const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.isPro ? 'Compte Professionnel' : 'Compte Client',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    widget.isPro ? AppColors.primary : const Color(0xFF059669),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _field('Prénom', _prenomCtrl, Icons.person_outline),
          const SizedBox(height: 16),
          _field('Nom', _nomCtrl, Icons.person_outline),
          const SizedBox(height: 16),
          // Email non modifiable
          _fieldReadOnly('Email', _emailCtrl.text, Icons.mail_outline),
          const SizedBox(height: 16),
          _field(
            'Téléphone',
            _phoneCtrl,
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save_outlined, size: 18),
              label: Text(
                _saving ? 'Enregistrement...' : 'Enregistrer les modifications',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _fieldReadOnly(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.lock_outline,
                color: AppColors.textMuted,
                size: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Data classes
// ════════════════════════════════════════════════════════════════

class _NavItem {
  final _Section section;
  final IconData icon;
  final String label;
  const _NavItem(this.section, this.icon, this.label);
}

class _DashCard {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DashCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
