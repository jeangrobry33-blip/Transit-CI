/// Règles de validation des formulaires (auth, réservation, paiement...).
class AppValidators {
  AppValidators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  // Numéros ivoiriens : 10 chiffres, éventuellement précédés de +225.
  static final _phoneRegex = RegExp(r'^(\+225)?[0-9]{10}$');

  static String? required(String? value, {String field = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$field est requis';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis';
    if (!_emailRegex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le numéro est requis';
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) return 'Numéro ivoirien invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }
}
