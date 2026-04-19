import 'package:flutter/material.dart';
import '../style/constants/app_colors.dart';
import '../style/constants/app_routes.dart';

class ProductCard extends StatefulWidget {
  final String id;
  final String nom;
  final String categorie;
  final String description;
  final String marque;
  final double prix;
  final bool isLoggedIn;

  const ProductCard({
    super.key,
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.marque,
    required this.prix,
    required this.isLoggedIn,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnim = Tween<double>(
      begin: 2,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() => _hovered = hover);
    if (hover) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onAddToCart() {
    if (!widget.isLoggedIn) {
      _showLoginDialog();
      return;
    }
    // TODO: logique panier (ex: CartService.add(widget.id))
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('« ${widget.nom} » ajouté au panier'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            title: Row(
              children: const [
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
              'Veuillez vous connecter d\'abord pour pouvoir ajouter des produits au panier.',
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

  void _goToDetail() {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: {'id': widget.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _elevationAnim,
        builder:
            (_, __) => Material(
              borderRadius: BorderRadius.circular(16),
              elevation: _elevationAnim.value,
              shadowColor: AppColors.primary.withOpacity(0.18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        _hovered
                            ? AppColors.primary.withOpacity(0.35)
                            : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image placeholder ──────────────────────────
                    _buildImagePlaceholder(),

                    // ── Contenu texte ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Catégorie + marque
                          Row(
                            children: [
                              _buildChip(widget.categorie, AppColors.primary),
                              const SizedBox(width: 6),
                              _buildChip(
                                widget.marque,
                                const Color(0xFF7C3AED),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Nom du produit
                          Text(
                            widget.nom,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Description
                          Text(
                            widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Prix
                          Text(
                            '${widget.prix.toStringAsFixed(2)} DA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Boutons
                          Row(
                            children: [
                              // Voir détails
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _goToDetail,
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'Détails',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryDark,
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Ajouter au panier
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _onAddToCart,
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'Panier',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
              ),
            ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.08),
            AppColors.primary.withOpacity(0.13),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 44,
              color: AppColors.primary.withOpacity(0.35),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune image',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary.withOpacity(0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
