// import 'package:flutter/material.dart';
// import '../style/constants/app_colors.dart';
// import '../style/constants/app_routes.dart';

// class ProductCard extends StatefulWidget {
//   final String id;
//   final String nom;
//   final String categorie;
//   final String description;
//   final String marque;
//   final double prix;
//   final bool isLoggedIn;

//   const ProductCard({
//     super.key,
//     required this.id,
//     required this.nom,
//     required this.categorie,
//     required this.description,
//     required this.marque,
//     required this.prix,
//     required this.isLoggedIn,
//   });

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard>
//     with SingleTickerProviderStateMixin {
//   bool _hovered = false;
//   late AnimationController _controller;
//   late Animation<double> _elevationAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _elevationAnim = Tween<double>(
//       begin: 2,
//       end: 12,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onHover(bool hover) {
//     setState(() => _hovered = hover);
//     if (hover) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//   }

//   void _onAddToCart() {
//     if (!widget.isLoggedIn) {
//       _showLoginDialog();
//       return;
//     }
//     // TODO: logique panier (ex: CartService.add(widget.id))
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('« ${widget.nom} » ajouté au panier'),
//         backgroundColor: AppColors.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   void _showLoginDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: Row(
//               children: const [
//                 Icon(Icons.lock_outline, color: AppColors.primary),
//                 SizedBox(width: 10),
//                 Text(
//                   'Connexion requise',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.primaryDark,
//                   ),
//                 ),
//               ],
//             ),
//             content: const Text(
//               'Veuillez vous connecter d\'abord pour pouvoir ajouter des produits au panier.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textMuted,
//                 height: 1.6,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text(
//                   'Annuler',
//                   style: TextStyle(color: AppColors.textMuted),
//                 ),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(ctx);
//                   Navigator.pushNamed(context, AppRoutes.login);
//                 },
//                 child: const Text('Se connecter'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _goToDetail() {
//     Navigator.pushNamed(
//       context,
//       AppRoutes.productDetail,
//       arguments: {'id': widget.id},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => _onHover(true),
//       onExit: (_) => _onHover(false),
//       cursor: SystemMouseCursors.click,
//       child: AnimatedBuilder(
//         animation: _elevationAnim,
//         builder:
//             (_, __) => Material(
//               borderRadius: BorderRadius.circular(16),
//               elevation: _elevationAnim.value,
//               shadowColor: AppColors.primary.withOpacity(0.18),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color:
//                         _hovered
//                             ? AppColors.primary.withOpacity(0.35)
//                             : const Color(0xFFE2E8F0),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Image placeholder ──────────────────────────
//                     _buildImagePlaceholder(),

//                     // ── Contenu texte ──────────────────────────────
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Catégorie + marque
//                           Row(
//                             children: [
//                               _buildChip(widget.categorie, AppColors.primary),
//                               const SizedBox(width: 6),
//                               _buildChip(
//                                 widget.marque,
//                                 const Color(0xFF7C3AED),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),

//                           // Nom du produit
//                           Text(
//                             widget.nom,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.primaryDark,
//                               height: 1.3,
//                             ),
//                           ),
//                           const SizedBox(height: 6),

//                           // Description
//                           Text(
//                             widget.description,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 12.5,
//                               color: AppColors.textMuted,
//                               height: 1.55,
//                             ),
//                           ),
//                           const SizedBox(height: 14),

//                           // Prix
//                           Text(
//                             '${widget.prix.toStringAsFixed(2)} DA',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w800,
//                               color: AppColors.primary,
//                               letterSpacing: -0.3,
//                             ),
//                           ),
//                           const SizedBox(height: 14),

//                           // Boutons
//                           Row(
//                             children: [
//                               // Voir détails
//                               Expanded(
//                                 child: OutlinedButton.icon(
//                                   onPressed: _goToDetail,
//                                   icon: const Icon(
//                                     Icons.visibility_outlined,
//                                     size: 15,
//                                   ),
//                                   label: const Text(
//                                     'Détails',
//                                     style: TextStyle(
//                                       fontSize: 12.5,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   style: OutlinedButton.styleFrom(
//                                     foregroundColor: AppColors.primaryDark,
//                                     side: const BorderSide(
//                                       color: Color(0xFFCBD5E1),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),

//                               // Ajouter au panier
//                               Expanded(
//                                 child: ElevatedButton.icon(
//                                   onPressed: _onAddToCart,
//                                   icon: const Icon(
//                                     Icons.shopping_cart_outlined,
//                                     size: 15,
//                                   ),
//                                   label: const Text(
//                                     'Panier',
//                                     style: TextStyle(
//                                       fontSize: 12.5,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.primary,
//                                     foregroundColor: Colors.white,
//                                     elevation: 0,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       height: 160,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primaryDark.withOpacity(0.08),
//             AppColors.primary.withOpacity(0.13),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.medical_services_outlined,
//               size: 44,
//               color: AppColors.primary.withOpacity(0.35),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Aucune image',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: AppColors.primary.withOpacity(0.45),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 10.5,
//           fontWeight: FontWeight.w600,
//           color: color,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_service.dart';
import '../style/constants/app_colors.dart';
import '../style/constants/app_routes.dart';

class ProductCard extends StatefulWidget {
  final String id;
  final String nom;
  final String categorie;
  final String description;
  final String marque;
  final double prix;
  final String? imgProd;
  final int quantite;
  final bool isLoggedIn;

  const ProductCard({
    super.key,
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.marque,
    required this.prix,
    this.imgProd,
    required this.quantite,
    required this.isLoggedIn,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _isFav = false;
  bool _favLoading = false;

  late AnimationController _controller;
  late Animation<double> _elevationAnim;

  bool get _epuise => widget.quantite == 0;

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
    _checkFav();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Favoris ───────────────────────────────────────────────────

  Future<void> _checkFav() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('favoris')
              .doc(user.uid)
              .collection('items')
              .doc(widget.id)
              .get();
      if (mounted) setState(() => _isFav = doc.exists);
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginDialog();
      return;
    }
    setState(() => _favLoading = true);
    try {
      final ref = FirebaseFirestore.instance
          .collection('favoris')
          .doc(user.uid)
          .collection('items')
          .doc(widget.id);
      if (_isFav) {
        await ref.delete();
      } else {
        await ref.set({
          'nom': widget.nom,
          'prix': widget.prix,
          'imgProd': widget.imgProd ?? '',
          'categorie': widget.categorie,
          'marque': widget.marque,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) setState(() => _isFav = !_isFav);
    } catch (_) {}
    if (mounted) setState(() => _favLoading = false);
  }

  // // ── Panier ────────────────────────────────────────────────────

  // void _onAddToCart() {
  //   if (!widget.isLoggedIn) {
  //     _showLoginDialog();
  //     return;
  //   }
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('« ${widget.nom} » ajouté au panier'),
  //       backgroundColor: AppColors.primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //     ),
  //   );
  // }

  Future<void> _onAddToCart() async {
    if (!widget.isLoggedIn) {
      _showLoginDialog();
      return;
    }
    await CartService.addToCart(
      productId: widget.id,
      nom: widget.nom,
      prix: widget.prix,
      imgProd: widget.imgProd,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(child: Text('« ${widget.nom} » ajouté au panier')),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

  void _onHover(bool hover) {
    setState(() => _hovered = hover);
    hover ? _controller.forward() : _controller.reverse();
  }

  void _goToDetail() {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: {'id': widget.id},
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

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
                    // ── Image ─────────────────────────────────────
                    _buildImage(),
                    // ── Contenu ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges
                          Row(
                            children: [
                              _chip(widget.categorie, AppColors.primary),
                              const SizedBox(width: 6),
                              _chip(widget.marque, const Color(0xFF7C3AED)),
                            ],
                          ),
                          const SizedBox(height: 9),
                          // Nom
                          GestureDetector(
                            onTap: _goToDetail,
                            child: Text(
                              widget.nom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Description
                          Text(
                            widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Stock
                          Row(
                            children: [
                              Icon(
                                _epuise
                                    ? Icons.remove_circle_outline
                                    : Icons.check_circle_outline,
                                size: 13,
                                color:
                                    _epuise
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _epuise
                                    ? 'Rupture de stock'
                                    : 'En stock (${widget.quantite})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _epuise
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Prix
                          Text(
                            '${widget.prix.toStringAsFixed(0)} DA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Boutons
                          Row(
                            children: [
                              // Détails
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _goToDetail,
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Détails',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryDark,
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              // Panier
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _epuise ? null : _onAddToCart,
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Ajouter au Panier',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFFCBD5E1,
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
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

  // ── Image avec overlay favori ─────────────────────────────────

  Widget _buildImage() {
    final hasImg = widget.imgProd != null && widget.imgProd!.isNotEmpty;

    return Stack(
      children: [
        // Image principale
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: Container(
            width: double.infinity,
            height: 180,
            color: const Color(0xFFF0F7FF),
            child:
                hasImg
                    ? Image.network(
                      widget.imgProd!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
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
                    : _imgFallback(),
          ),
        ),
        // Badge épuisé
        if (_epuise)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.88),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: const Text(
                'ÉPUISÉ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        // Bouton favori
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _toggleFav,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    _isFav
                        ? const Color(0xFFDC2626).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child:
                  _favLoading
                      ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(
                        _isFav ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: _isFav ? Colors.white : const Color(0xFFDC2626),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imgFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 44,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Aucune image',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary.withOpacity(0.4),
              fontWeight: FontWeight.w500,
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
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
