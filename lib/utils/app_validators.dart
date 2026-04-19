/// Validateurs centralisés — MTS Médico Dentaire
/// Utilisation : AppValidators.email(value), AppValidators.phone(value), etc.
class AppValidators {
  AppValidators._();

  // ── Email ─────────────────────────────────────────────────────
  /// Vérifie que l'email est non vide et bien formé (x@x.xx)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'adresse email est requise.';
    final regex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Adresse email invalide (ex: exemple@gmail.com).';
    return null;
  }

  // ── Téléphone algérien ────────────────────────────────────────
  /// 10 chiffres, commence par 05 / 06 / 07
  /// Accepte les formats : 0712345678 | 07 12 34 56 78 | 07-12-34-56-78
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le numéro de téléphone est requis.';
    final digits = value.replaceAll(RegExp(r'[\s\-\.]'), '');
    if (digits.length != 10) return 'Le numéro doit contenir 10 chiffres.';
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(digits)) {
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
    if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères.';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) return 'Doit contenir au moins une lettre.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Doit contenir au moins un chiffre.';
    return null;
  }

  /// Confirmation identique au mot de passe saisi
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe.';
      if (value != original) return 'Les mots de passe ne correspondent pas.';
      return null;
    };
  }

  // ── Champs texte génériques ───────────────────────────────────
  /// Champ requis — juste non vide
  static String? required(String? value, {String label = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est requis.';
    return null;
  }

  /// Prénom / Nom : lettres uniquement, min 2 caractères
  static String? name(String? value, {String label = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est requis.';
    if (value.trim().length < 2) return '$label doit contenir au moins 2 caractères.';
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value.trim())) {
      return '$label ne doit contenir que des lettres.';
    }
    return null;
  }

  /// Message (textarea) : min N caractères
  static String? Function(String?) minLength(int min, {String label = 'Ce champ'}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return '$label est requis.';
      if (value.trim().length < min) {
        return '$label doit contenir au moins $min caractères.';
      }
      return null;
    };
  }

  // ── Fichier justificatif ──────────────────────────────────────
  /// Vérifie qu'un fichier a bien été sélectionné (passe un bool)
  static String? fileRequired(bool fileSelected) {
    if (!fileSelected) return 'Un justificatif professionnel est requis.';
    return null;
  }
}