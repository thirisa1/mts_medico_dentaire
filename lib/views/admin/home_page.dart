import 'package:flutter/material.dart';
import 'package:mts_medico_dentaire/views/admin/demandesven_page.dart';
import '../../services/order_service.dart';
import '../../services/notification_service.dart';
import '../../style/theme/colors.dart';
import '../../widgets/notification_bell_widget.dart';
import 'accounts_page.dart';
import 'dashboard_screen.dart';
import 'products_page.dart';
import 'settings_panel.dart';

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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeTab(),
            const AccountsPage(),
            const ProductsPage(),
            const _DashboardTab(),
          ],
        ),
        floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
        bottomNavigationBar: _buildBottomNav(),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  const HomeTab(),
                  const AccountsPage(),
                  const ProductsPage(),
                  const DemandesPage(),
                  const DashboardScreen(),
                  const SettingsPage(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

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
            child: Row(
              children: [
                // ✅ LOGO + TEXTE BIEN ALIGNÉS
                Row(
                  children: [
                    //Image.asset('images/logo.jpg', width: 40, height: 40),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Image.asset('images/logo1.png', width: 28),
                    ),
                    const SizedBox(width: 12),

                    const Column(
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
                          style: TextStyle(
                            color: Color(0xAAFFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // 🔔 Cloche
                const NotificationBellWidget(),
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
                  icon: Icons.storefront_outlined,
                  label: 'Demandes Vendeurs',
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Tableau de bord',
                  index: 4,
                ),
                _buildSidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  index: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                      ? AppColors.primary.withOpacity(0.1)
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
            label: 'demandes vendeurs',
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
// Onglet Commandes
// ─────────────────────────────────────────────
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  String? _filterStatut;

  static const _statuts = ['en_attente', 'livree', 'annulee'];

  String _statutLabel(String s) {
    switch (s) {
      case 'en_attente':
        return 'En attente';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return s;
    }
  }

  Color _statutColor(String s) {
    switch (s) {
      case 'en_attente':
        return const Color(0xFFF59E0B);
      case 'livree':
        return const Color(0xFF059669);
      case 'annulee':
        return const Color(0xFFDC2626);
      default:
        return AppColors.primary;
    }
  }

  IconData _statutIcon(String s) {
    switch (s) {
      case 'en_attente':
        return Icons.access_time_rounded;
      case 'livree':
        return Icons.done_all_rounded;
      case 'annulee':
        return Icons.cancel_outlined;
      default:
        return Icons.circle;
    }
  }

  // ── Changement de statut + notification ──────
  Future<void> _changeStatut(OrderModel order, String newStatut) async {
    // Dialog de confirmation si passage à "livrée"
    if (newStatut == 'livree') {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF059669),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Marquer comme livrée ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La commande #${order.id.substring(0, 8).toUpperCase()} '
                    'de ${order.clientName} sera marquée comme livrée.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF059669),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Le client recevra une notification automatiquement.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF059669),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text(
                    'Confirmer',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
      );
      if (confirm != true) return;
    }

    // 1. Mettre à jour le statut dans Firestore
    await OrderService.updateStatut(order.id, newStatut);

    // 2. Si livrée → créer la notification pour le client
    if (newStatut == 'livree') {
      await NotificationService.createLivraisonNotification(
        userId: order.userId,
        orderId: order.id,
        clientName: order.clientName,
        total: order.total,
        lignes:
            order.lignes
                .map(
                  (l) => {'nom': l.nom, 'quantite': l.quantite, 'prix': l.prix},
                )
                .toList(),
      );

      // Snackbar de confirmation pour l'admin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${order.clientName} a été notifié — livraison confirmée.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? _buildAppBar() : null,
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderService.allOrdersStream(),
        builder: (context, snap) {
          final allOrders = snap.data ?? [];

          final filtered =
              allOrders.where((o) {
                final matchSearch =
                    _searchQuery.isEmpty ||
                    o.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    o.clientName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    o.ville.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchStatut =
                    _filterStatut == null || o.statut == _filterStatut;
                return matchSearch && matchStatut;
              }).toList();

          final enAttente =
              allOrders.where((o) => o.statut == 'en_attente').length;
          final livrees = allOrders.where((o) => o.statut == 'livree').length;

          return Column(
            children: [
              if (!isMobile) _buildWebHeader(allOrders.length),
              _buildSearchBar(),
              _buildStatutFilter(enAttente, livrees),
              const SizedBox(height: 4),
              Expanded(
                child:
                    snap.connectionState == ConnectionState.waiting
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                        : filtered.isEmpty
                        ? _buildEmpty()
                        : _buildOrderList(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                'Commandes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'MTS Médico-Dentaire',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
          actions: const [NotificationBellWidget(), SizedBox(width: 8)],
        ),
      ),
    );
  }

  Widget _buildWebHeader(int total) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Commandes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total commandes au total',
                style: TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
            hintText: 'Rechercher par N°, client, ville...',
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

  Widget _buildStatutFilter(int enAttente, int livrees) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            label: 'Tous',
            count: null,
            selected: _filterStatut == null,
            color: AppColors.primary,
            onTap: () => setState(() => _filterStatut = null),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'En attente',
            count: enAttente,
            selected: _filterStatut == 'en_attente',
            color: const Color(0xFFF59E0B),
            onTap: () => setState(() => _filterStatut = 'en_attente'),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Livrées',
            count: livrees,
            selected: _filterStatut == 'livree',
            color: const Color(0xFF059669),
            onTap: () => setState(() => _filterStatut = 'livree'),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required int? count,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.textHint.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? Colors.white.withOpacity(0.3)
                          : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final color = _statutColor(order.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_statutIcon(order.statut), color: color, size: 22),
        ),
        title: Text(
          '#${order.id.substring(0, 8).toUpperCase()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${order.clientName} • ${order.ville}',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.total.toStringAsFixed(0)} DA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statutLabel(order.statut),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
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
                _infoRow(Icons.person_outline, order.clientName),
                _infoRow(Icons.mail_outline, order.clientEmail),
                _infoRow(Icons.phone_outlined, order.telephone),
                _infoRow(
                  Icons.location_on_outlined,
                  '${order.adresse}, ${order.ville}, ${order.wilaya}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Produits :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ...order.lignes.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          size: 6,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.nom,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '×${l.quantite}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(l.prix * l.quantite).toStringAsFixed(0)} DA',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total : ${order.total.toStringAsFixed(0)} DA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Changer le statut :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      _statuts
                          .where((s) => s != order.statut)
                          .map(
                            (s) => GestureDetector(
                              // ← ICI : _changeStatut au lieu de OrderService.updateStatut
                              onTap: () => _changeStatut(order, s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statutColor(s).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _statutColor(s).withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  '→ ${_statutLabel(s)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _statutColor(s),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune commande trouvée',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Onglet Tableau de bord
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
                offset: const Offset(0, 4),
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
