import 'package:flutter/material.dart';
import '../../model/product.dart';
import '../../services/product_service.dart';
import '../../style/theme/colors.dart';
import 'Editproductpage.dart';

// ─────────────────────────────────────────────
// Page Détail Produit
// ─────────────────────────────────────────────
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onProductUpdated,
    required this.onProductDeleted,
  });

  final Product product;
  final void Function(Product updated) onProductUpdated;
  final void Function(String productId) onProductDeleted;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late Product _product;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Ouvrir la page d'édition ──
  Future<void> _openEdit() async {
    final updated = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditProductPage(
              product: _product,
              onProductUpdated: (p) {
                setState(() => _product = p);
                widget.onProductUpdated(p);
              },
            ),
      ),
    );
    if (updated != null) {
      setState(() => _product = updated);
    }
  }

  // ── Confirmer la suppression ──
  Future<void> _confirmDelete() async {
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Supprimer ?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Text(
              'Le produit « ${_product.name} » sera archivé et ne sera plus visible dans le catalogue.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      // 1. Appeler Firestore pour mettre deleted=true
      await ProductService.deleteProduct(_product.id);

      // 3. Mettre à jour la liste dans ProductsPage
      widget.onProductDeleted(_product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPriceStockRow(),
                    const SizedBox(height: 20),
                    if (_product.description.isNotEmpty) ...[
                      _buildSection(
                        icon: Icons.description_outlined,
                        title: 'Description',
                        child: Text(
                          _product.description,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildSection(
                      icon: Icons.category_outlined,
                      title: 'Catégorie',
                      child: _buildBadge(
                        _product.category.label,
                        AppColors.accent,
                        AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.people_outline_rounded,
                      title: 'Acheteurs autorisés',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _product.allowedBuyers
                                .map(
                                  (b) => _buildBadge(
                                    b.label,
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SliverAppBar avec image ──
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _openEdit,
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Modifier',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background:
            _product.imagePath != null && _product.imagePath!.isNotEmpty
                ? Image.network(
                  _product.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
                : _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.appBarGradient),
      child: Center(
        child: Icon(
          Icons.medical_services_outlined,
          color: Colors.white.withOpacity(0.4),
          size: 80,
        ),
      ),
    );
  }

  // ── En-tête nom + marque ──
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          _product.name,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.business_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              _product.brand,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Prix + Stock ──
  Widget _buildPriceStockRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.sell_outlined,
            label: 'Prix',
            value: '${_product.price.toStringAsFixed(0)} DA',
            color: AppColors.primary,
            bgColor: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.layers_outlined,
            label: 'Stock',
            value: '${_product.quantity} unités',
            color: AppColors.accent,
            bgColor: AppColors.accentLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section générique ──
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Boutons Modifier / Supprimer ──
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Modifier le produit',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: Colors.red.shade600,
            ),
            label: Text(
              'Supprimer le produit',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.red.shade600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red.shade300, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
