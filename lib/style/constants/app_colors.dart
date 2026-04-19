import 'package:flutter/material.dart';

/// Toutes les couleurs de l'application MTS Médico-Dentaire
/// Utilisation : AppColors.primary, AppColors.bannerOverlay, etc.
class AppColors {
  AppColors._(); // non instanciable

  // ── Couleurs principales ──────────────────────────────────────
  static const Color primary      = Color(0xFF1D4ED8); // bleu principal
  static const Color primaryDark  = Color(0xFF1E3A8A); // bleu foncé (titres)
  static const Color primaryDeep  = Color(0xFF0A1E6E); // bleu très foncé
  static const Color primaryLight = Color(0xFF3B82F6); // bleu clair

  // ── Textes ────────────────────────────────────────────────────
  static const Color textNavLink   = Color(0xFF374151); // liens navbar
  static const Color textMuted     = Color(0xFF6B7280); // texte secondaire
  static const Color textHint      = Color(0xFF9CA3AF); // placeholder
  static const Color textFooter    = Color(0xFF475569); // footer body
  static const Color textFooterSub = Color(0xFF64748B); // footer muted

  // ── Blanc & transparences ─────────────────────────────────────
  static const Color white            = Colors.white;
  static const Color navbarBg         = Color(0xEDFFFFFF); // 93% opacité
  static const Color searchFieldBg    = Color(0xFFF3F4F6);
  static const Color mobileMenuBg     = Color(0xF7FFFFFF); // 97% opacité

  // ── Banner overlay (dégradé bleu sombre) ─────────────────────
  static const Color bannerGradTop    = Color(0xCC0A1E64); // 80% opacité
  static const Color bannerGradMid    = Color(0xD5051450); // 84% opacité
  static const Color bannerGradBottom = Color(0xEA030F3C); // 92% opacité

  // ── Textes banner ─────────────────────────────────────────────
  static const Color bannerWelcome  = Color(0xFF93C5FD); // bleu clair
  static const Color bannerTitle    = Colors.white;
  static const Color bannerDesc     = Color(0xFFBFDBFE); // bleu très clair
  static const Color bannerBtnBorder = Color(0x99FFFFFF); // blanc 60%

  // ── Info cards (barre du bas du banner) ──────────────────────
  static const Color infoCardBg      = Color(0xBF051450); // bleu nuit 75%
  static const Color infoCardBorder  = Color(0x1AFFFFFF); // blanc 10%
  static const Color infoIconColor   = Color(0xFF93C5FD); // bleu clair
  static const Color infoIconBorder  = Color(0x5993C5FD); // bleu clair 35%
  static const Color infoTitle       = Color(0xFFF1F5F9); // blanc cassé
  static const Color infoLabel       = Color(0xFF64748B); // gris bleuté

  // ── Section About ─────────────────────────────────────────────
  static const Color aboutBgStart   = Color(0xFF0A1E6E);
  static const Color aboutBgEnd     = Color(0xFF0F3460);
  static const Color aboutEyebrow   = Color(0xFF93C5FD);
  static const Color aboutDesc      = Color(0xFF93C5FD);

  // ── Stats couleurs ────────────────────────────────────────────
  static const Color statBlue   = Color(0xFF3B82F6);
  static const Color statGreen  = Color(0xFF34D399);
  static const Color statPurple = Color(0xFFC084FC);
  static const Color statAmber  = Color(0xFFFBBF24);

  // ── Footer ────────────────────────────────────────────────────
  static const Color footerBg      = Color(0xFF071040);
  static const Color footerAccent  = Color(0xFF3B82F6);
  static const Color footerBorder  = Color(0x0DFFFFFF); // blanc 5%
}