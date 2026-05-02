import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_routes.dart';

class AcheteurHomeScreen extends StatelessWidget {
  final String role; // 'professionnel' ou 'autre'
  const AcheteurHomeScreen({super.key, required this.role});
 
  @override
  Widget build(BuildContext context) {
    final isPro = role == 'professionnel';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPro
                    ? Icons.medical_information_outlined
                    : Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPro ? 'Je suis Professionnel' : 'Je suis Acheteur',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark),
            ),
            const SizedBox(height: 10),
            Text(
              isPro
                  ? 'Accès complet au catalogue professionnel.'
                  : 'Bienvenue sur la boutique MTS.',
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.boutique),
              icon: const Icon(Icons.store_outlined, size: 18),
              label: const Text('Aller à la boutique'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await AuthService.instance.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout,
                  size: 16, color: AppColors.textMuted),
              label: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}