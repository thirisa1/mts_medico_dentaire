import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_service.dart';
import '../style/constants/app_colors.dart';
import '../style/constants/app_routes.dart';

// ─────────────────────────────────────────────
// CartIconWidget — icône panier avec badge
// À placer dans la navbar globale.
// S'abonne en temps réel au stream du panier.
// Affiche rien si l'utilisateur n'est pas connecté.
// ─────────────────────────────────────────────
class CartIconWidget extends StatelessWidget {
  const CartIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Non connecté → pas d'icône panier
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: CartService.cartCountStream(),
      builder: (context, snap) {
        final count = snap.data ?? 0;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Icône panier
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                // Badge count
                if (count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}