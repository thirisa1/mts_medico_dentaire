

import 'package:flutter/services.dart';

// ═════════════════════════════════════════════════════════════════
// VALIDATORS — MTS Médico Dentaire
// Retournent null si valide, sinon un message d'erreur
// ═════════════════════════════════════════════════════════════════
class AppValidators {
  AppValidators._();

  // ── Email ─────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse email est requise.';
    }
    final regex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Adresse email invalide (ex: exemple@gmail.com).';
    }
    return null;
  }

  // ── Téléphone algérien ────────────────────────────────────────
  /// 10 chiffres, commence par 05 / 06 / 07
  /// Accepte : 0712345678 | 07 12 34 56 78 | +213 XX XX XX XX
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est requis.';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-\.\+]'), '');
    // Accepte format international +213 → remplace par 0
    final normalized =
        digits.startsWith('213') ? '0${digits.substring(3)}' : digits;
    if (normalized.length != 10) {
      return 'Le numéro doit contenir 10 chiffres.';
    }
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(normalized)) {
      return 'Le numéro doit commencer par 05, 06 ou 07.';
    }
    return null;
  }

  /// Téléphone optionnel (vide autorisé)
  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  // ── Mot de passe ──────────────────────────────────────────────
  /// Min 8 caractères, au moins 1 lettre et 1 chiffre
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis.';
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Doit contenir au moins une lettre.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Doit contenir au moins un chiffre.';
    }
    return null;
  }

  /// Confirmation identique au mot de passe saisi
  /// Usage (web) : AppValidators.confirmPassword(passwordCtrl.text)
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Veuillez confirmer votre mot de passe.';
      }
      if (value != original) return 'Les mots de passe ne correspondent pas.';
      return null;
    };
  }

  /// Confirmation mot de passe — version mobile (2 paramètres)
  /// Usage (mobile) : AppValidators.confirmPasswordDirect(value, original)
  static String? confirmPasswordDirect(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }
    if (value != original) return 'Les mots de passe ne correspondent pas.';
    return null;
  }

  // ── Nom / Prénom ──────────────────────────────────────────────
  /// Lettres uniquement, min 2 caractères, max 80
  static String? name(String? value, {String label = 'Un champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est requis.';
    if (value.trim().length < 2) {
      return '$label doit contenir au moins 2 caractères.';
    }
    if (value.trim().length > 80)
      return '$label est trop long (max. 80 caractères).';
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value.trim())) {
      return '$label ne doit contenir que des lettres.';
    }
    return null;
  }

  // ── Adresse ───────────────────────────────────────────────────
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optionnel
    if (value.trim().length < 5) {
      return 'Adresse trop courte (min. 5 caractères).';
    }
    if (value.length > 150) {
      return 'Adresse trop longue (max. 150 caractères).';
    }
    return null;
  }

  // ── Champ requis générique ────────────────────────────────────
  static String? required(String? value, {String label = 'Un champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est requis.';
    return null;
  }

  // ── Longueur minimale ─────────────────────────────────────────
  static String? Function(String?) minLength(
    int min, {
    String label = 'Un champ',
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return '$label est requis.';
      if (value.trim().length < min) {
        return '$label doit contenir au moins $min caractères.';
      }
      return null;
    };
  }

  // ── Fichier justificatif ──────────────────────────────────────
  static String? fileRequired(bool fileSelected) {
    if (!fileSelected) return 'Un justificatif professionnel est requis.';
    return null;
  }

  // ── Combiner plusieurs validators ─────────────────────────────
  /// Retourne le premier échec trouvé
  static String? combine(
    String value,
    List<String? Function(String)> validators,
  ) {
    for (final v in validators) {
      final error = v(value);
      if (error != null) return error;
    }
    return null;
  }
}

// ═════════════════════════════════════════════════════════════════
// INPUT FORMATTERS — MTS Médico Dentaire
// Bloquent certains caractères en temps réel
// ═════════════════════════════════════════════════════════════════
class AppFormatters {
  AppFormatters._();

  // ── Téléphone : chiffres, +, espaces ──
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

  // ── Adresse ──
  static final List<TextInputFormatter> address = [
    FilteringTextInputFormatter.deny(RegExp(r'[<>{}]')),
    LengthLimitingTextInputFormatter(150),
  ];

  // ── Chiffres uniquement ──
  static final List<TextInputFormatter> digitsOnly = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  // ── Nom produit : tout en MAJUSCULES ──
  static final List<TextInputFormatter> upperCase = [
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          newValue.copyWith(text: newValue.text.toUpperCase()),
    ),
    LengthLimitingTextInputFormatter(120),
  ];
}
