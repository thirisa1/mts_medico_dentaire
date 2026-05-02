import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Couleurs marque (fixes) ──
  static const Color primary      = Color(0xFF1A3A8F);
  static const Color accent       = Color(0xFF29ABE2);
  static const Color green        = Color(0xFF39B54A);
  static const Color primaryLight = Color(0x1A1A3A8F);
  static const Color accentLight  = Color(0x1A29ABE2);
  static const Color textOnDark   = Colors.white;

  // ── Dégradés (fixes) ──
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF1A3A8F), Color(0xFF1557B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient fabGradient = LinearGradient(
    colors: [Color(0xFF29ABE2), Color(0xFF1A3A8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardAccent = LinearGradient(
    colors: [Color(0xFF1A3A8F), Color(0xFF29ABE2)],
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
  );

  // ── Statuts ──
  static const Color statusEnAttente     = Color(0xFFFFF3E0);
  static const Color statusEnAttenteText = Color(0xFFE65100);
  static const Color statusValidee       = Color(0xFF39B54A);
  static const Color statusEnCours       = Color(0xFF29ABE2);
  static const Color statusLivree        = Color(0xFF1A3A8F);

  // ── Fond & surfaces ──
  static const Color background  = Color(0xFFF0F4FF);
  static const Color surface     = Colors.white;
  static const Color surfaceAlt  = Color(0xFFF8FAFF);

  // ── Textes ──
  static const Color textPrimary   = Color(0xFF0D1B4B);
  static const Color textSecondary = Color(0xFF5A6A8A);
  static const Color textHint      = Color(0xFFB0BED9);
  static const Color textMuted     = Color(0xFF9AAAC4);

  // ── Ombres ──
  static const Color shadow     = Color(0x141A3A8F);
  static const Color shadowDeep = Color(0x281A3A8F);
}