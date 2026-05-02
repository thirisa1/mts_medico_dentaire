import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../style/theme/colors.dart';
import 'accounts_page.dart';
import 'products_page.dart';
import 'settings_panel.dart';
import '../../widgets/order_card.dart';
import '../../widgets/status_chip.dart';

// ─────────────────────────────────────────────
// HomePage Admin — MTS Médico-Dentaire
// ─────────────────────────────────────────────
class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAdmin>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _fabController.forward(),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      // Version mobile avec BottomNavigationBar
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const _HomeTab(),
            const AccountsPage(),
            const ProductsPage(),
            const _DashboardTab(),
          ],
        ),
        floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
        bottomNavigationBar: _buildBottomNav(),
      );
    } else {
      // Version web avec Sidebar
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  const _HomeTab(),
                  const AccountsPage(),
                  const ProductsPage(),
                  const _DashboardTab(),
                  const SettingsPage(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ── Sidebar Web ──
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Médico-Dentaire',
                  style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildSidebarItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Comptes',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Produits',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Tableau de bord',
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  index: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Item Sidebar ──
  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border:
                  isActive
                      ? Border(
                        left: BorderSide(color: AppColors.primary, width: 4),
                      )
                      : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.textHint,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav (Mobile) ──
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Comptes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  // ── FAB (visible uniquement sur l'onglet Accueil, mobile) ──
  Widget _buildFAB() {
    return ScaleTransition(
      scale: _fabScale,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.fabGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          label: const Text(
            'Filtrer commandes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Onglet 0 — Accueil (contenu de l'ancienne HomePage)
// ─────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _searchQuery = '';

  List<Order> get _filteredOrders {
    if (_searchQuery.isEmpty) return kSampleOrders;
    return kSampleOrders.where((o) {
      return o.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 24),
          _buildHeader(),
          _buildSearchBar(),
          const SizedBox(height: 8),
          _buildStatusSummary(),
          const SizedBox(height: 4),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  '../../../images/logo1.png',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Text(
                          'MTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Médico-Dentaire',
                style: TextStyle(
                  color: AppColors.accent.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8),
          //     child: IconButton(
          //       icon: Container(
          //         padding: const EdgeInsets.all(6),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withValues(alpha: 0.15),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: const Icon(
          //           Icons.settings_outlined,
          //           color: Colors.white,
          //           size: 18,
          //         ),
          //       ),
          //       onPressed: () => openSettingsPanel(context),
          //     ),
          //   ),
          // ],
        ),
      ),
    );
  }

  // ── En-tête ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Admin 👋',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${kSampleOrders.length} commandes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.cardAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDeep,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.today_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  "Aujourd'hui",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Résumé statuts ──
  Widget _buildStatusSummary() {
    final counts = {
      OrderStatus.enAttente:
          kSampleOrders.where((o) => o.status == OrderStatus.enAttente).length,
      OrderStatus.livree:
          kSampleOrders.where((o) => o.status == OrderStatus.livree).length,
    };
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children:
            counts.entries
                .map((e) => StatusChip(status: e.key, count: e.value))
                .toList(),
      ),
    );
  }

  // ── Barre de recherche ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Rechercher une commande...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.accent,
              size: 20,
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textHint,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                    : null,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ── Liste des commandes ──
  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'Aucune commande trouvée',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _filteredOrders.length,
      itemBuilder:
          (context, index) =>
              OrderCard(order: _filteredOrders[index], index: index),
    );
  }
}

// ─────────────────────────────────────────────
// Onglet 3 — Tableau de bord (placeholder)
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDeep,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
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
                  'Statistiques & analyses',
                  style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
                ),
              ],
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tableau de bord',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'En cours de développement',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
