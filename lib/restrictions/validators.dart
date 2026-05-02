import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// VALIDATORS
// Retournent null si valide, sinon un message d'erreur
// Utilisation : AppValidators.email('test@mail.com')
// ─────────────────────────────────────────────
class AppValidators {
  AppValidators._();

  // ── Email ──
  static String? email(String value) {
    if (value.isEmpty) return null; // champ optionnel
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
    if (!regex.hasMatch(value)) return 'Email invalide (ex: nom@domaine.com)';
    return null;
  }

  // ── Téléphone ──
  // Accepte : +213 XX XX XX XX  /  0XX XX XX XX  /  chiffres seuls
  static String? phone(String value) {
    if (value.isEmpty) return null;
    final cleaned = value.replaceAll(' ', '');
    final regex = RegExp(r'^[+]?[0-9]{8,15}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Numéro invalide (8 à 15 chiffres, ex: +213 XX XX XX XX)';
    }
    return null;
  }

  // ── Adresse ──
  static String? address(String value) {
    if (value.isEmpty) return null;
    if (value.length < 5) return 'Adresse trop courte (min. 5 caractères)';
    if (value.length > 150) return 'Adresse trop longue (max. 150 caractères)';
    return null;
  }

  // ── Nom (comptoir, utilisateur, etc.) ──
  static String? name(String value) {
    if (value.trim().isEmpty) return 'Ce champ est obligatoire';
    if (value.trim().length < 2) return 'Trop court (min. 2 caractères)';
    if (value.length > 80) return 'Trop long (max. 80 caractères)';
    return null;
  }

  // ── Champ obligatoire générique ──
  static String? required(String value, {String fieldName = 'Ce champ'}) {
    if (value.trim().isEmpty) return '$fieldName est obligatoire';
    return null;
  }

  // ── Mot de passe ──
  static String? password(String value) {
    if (value.isEmpty) return 'Mot de passe obligatoire';
    if (value.length < 8) return 'Min. 8 caractères';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Au moins une majuscule';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
    return null;
  }

  // ── Confirmer mot de passe ──
  static String? confirmPassword(String value, String original) {
    if (value.isEmpty) return 'Veuillez confirmer le mot de passe';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  // ── Combiner plusieurs validators (retourne le premier échec) ──
  static String? combine(String value, List<String? Function(String)> validators) {
    for (final v in validators) {
      final error = v(value);
      if (error != null) return error;
    }
    return null;
  }
}

// ─────────────────────────────────────────────
// INPUT FORMATTERS
// Bloquent certains caractères en temps réel
// Utilisation : inputFormatters: AppFormatters.phone
// ─────────────────────────────────────────────
class AppFormatters {
  AppFormatters._();

  // ── Téléphone : chiffres, +, espaces uniquement ──
  static final List<TextInputFormatter> phone = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
    LengthLimitingTextInputFormatter(18),
  ];

  // ── Email : pas d'espaces ──
  static final List<TextInputFormatter> email = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(100),
  ];

  // ── Nom : lettres, espaces, tirets, apostrophes ──
  static final List<TextInputFormatter> name = [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s'\-]")),
    LengthLimitingTextInputFormatter(80),
  ];

  // ── Adresse : tout sauf caractères spéciaux dangereux ──
  static final List<TextInputFormatter> address = [
    FilteringTextInputFormatter.deny(RegExp(r'[<>{}]')),
    LengthLimitingTextInputFormatter(150),
  ];

  // ── Chiffres uniquement ──
  static final List<TextInputFormatter> digitsOnly = [
    FilteringTextInputFormatter.digitsOnly,
  ];
}