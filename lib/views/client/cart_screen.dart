import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cart_service.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_routes.dart';

// ─────────────────────────────────────────────
// CartScreen — Page panier
// Structure identique à l'image fournie :
//   • Tableau : Produit | Prix | Quantité | Total | ✕
//   • Bouton "Mettre à jour le panier"
//   • Résumé : Sous-total, Expédition, Total
//   • Bouton "Valider la commande"
// ─────────────────────────────────────────────
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Copie locale modifiable des lignes (pour +/-)
  List<CartItem> _items = [];
  bool _loading = true;
  bool _updating = false;

  static const double _fraisExpedition = 600.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await CartService.fetchCart();
    if (mounted)
      setState(() {
        _items = items;
        _loading = false;
      });
  }

  double get _sousTotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _total => _sousTotal + _fraisExpedition;

  // ── Mettre à jour toutes les quantités modifiées ──
  Future<void> _updateCart() async {
    setState(() => _updating = true);
    for (final item in _items) {
      await CartService.updateQuantity(item.productId, item.quantite);
    }
    if (mounted) {
      setState(() => _updating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Panier mis à jour !'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    await CartService.removeItem(item.productId);
    setState(() => _items.remove(item));
  }

  void _incrementQty(CartItem item) {
    setState(() => item.quantite++);
  }

  void _decrementQty(CartItem item) {
    if (item.quantite > 1) setState(() => item.quantite--);
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            if (user == null)
              _buildNotLoggedIn()
            else if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (_items.isEmpty)
              _buildEmptyCart()
            else
              _buildCartContent(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header avec navbar ──
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
            const SizedBox(height: 32),
            // Titre page
            const Text(
              'Mon Panier',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap:
                      () =>
                          Navigator.pushNamed(context, AppRoutes.acheteurHome),
                  child: const Text(
                    'Accueil',
                    style: TextStyle(
                      color: AppColors.bannerWelcome,
                      fontSize: 13,
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
                  'Panier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.navbarBg,
        borderRadius: BorderRadius.circular(16),
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
            height: 36,
            errorBuilder:
                (_, __, ___) => const Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
          ),
          const SizedBox(width: 10),
          if (!_isMobile)
            const Text(
              'MTS Médico Dentaire',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          const Spacer(),
          // Retour boutique
          TextButton.icon(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.acheteurHome),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            label: const Text(
              'Continuer les achats',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contenu panier ──
  Widget _buildCartContent() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 48,
        vertical: 40,
      ),
      child: _isMobile ? _buildMobileCart() : _buildDesktopCart(),
    );
  }

  // ── Layout Desktop ──
  Widget _buildDesktopCart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tableau produits
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildTable(),
              const SizedBox(height: 16),
              // Bouton Mettre à jour
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _updating ? null : _updateCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _updating
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Mettre à jour le panier',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Résumé
        SizedBox(width: 320, child: _buildSummary()),
      ],
    );
  }

  // ── Layout Mobile ──
  Widget _buildMobileCart() {
    return Column(
      children: [
        ..._items.map((item) => _buildMobileItem(item)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _updating ? null : _updateCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Mettre à jour le panier',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSummary(),
      ],
    );
  }

  // ── Tableau desktop ──
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
            4: IntrinsicColumnWidth(),
          },
          children: [
            // En-tête
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              children: [
                _th('PRODUIT'),
                _th('PRIX'),
                _th('QUANTITÉ'),
                _th('TOTAL'),
                _th(''),
              ],
            ),
            // Lignes produits
            ..._items.map((item) => _buildTableRow(item)),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(CartItem item) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      children: [
        // Produit
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.imgProd != null && item.imgProd!.isNotEmpty
                        ? Image.network(
                          item.imgProd!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgFallback(),
                        )
                        : _imgFallback(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.nom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Prix
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${item.prix.toStringAsFixed(0)} DA',
            style: const TextStyle(fontSize: 14, color: AppColors.primaryDark),
          ),
        ),
        // Quantité avec +/-
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildQtyControl(item),
        ),
        // Total
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${item.total.toStringAsFixed(0)} DA',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        // Supprimer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GestureDetector(
            onTap: () => _removeItem(item),
            child: const Icon(Icons.close, color: Color(0xFFDC2626), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _th(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Contrôle quantité +/- ──
  Widget _buildQtyControl(CartItem item) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Center(
              child: Text(
                '${item.quantite}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          Container(
            width: 28,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Incrémenter
                GestureDetector(
                  onTap: () => _incrementQty(item),
                  child: Container(
                    height: 22,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                // Décrémenter
                GestureDetector(
                  onTap: () => _decrementQty(item),
                  child: const SizedBox(
                    height: 22,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Item mobile ──
  Widget _buildMobileItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                item.imgProd != null && item.imgProd!.isNotEmpty
                    ? Image.network(
                      item.imgProd!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(size: 56),
                    )
                    : _imgFallback(size: 56),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.prix.toStringAsFixed(0)} DA',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyControl(item),
                    const Spacer(),
                    Text(
                      '${item.total.toStringAsFixed(0)} DA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeItem(item),
            child: const Icon(Icons.close, color: Color(0xFFDC2626), size: 20),
          ),
        ],
      ),
    );
  }

  // ── Résumé commande ──
  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL PANIER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          // Sous-total
          _summaryRow('Sous-Total', '${_sousTotal.toStringAsFixed(0)} DA'),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          // Expédition
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expédition',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  children: [
                    TextSpan(text: 'Forfait: '),
                    TextSpan(
                      text: '600 DA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Les options de livraison seront mises à jour lors de la commande.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Calculer les frais d\'expédition',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(0)} DA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bouton valider
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Valider la commande et payer',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _imgFallback({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.medical_services_outlined,
        color: AppColors.primary.withOpacity(0.3),
        size: size * 0.45,
      ),
    );
  }

  // ── Panier vide ──
  Widget _buildEmptyCart() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ajoutez des produits depuis la boutique\npour les retrouver ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.boutique),
            icon: const Icon(Icons.store_outlined, size: 18),
            label: const Text('Découvrir la boutique'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Non connecté ──
  Widget _buildNotLoggedIn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Connectez-vous pour voir votre panier',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      child: Column(
        children: [
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 16),
          const Text(
            '© 2025 MTS Médico-Dentaire — Tous droits réservés',
            style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }
}
