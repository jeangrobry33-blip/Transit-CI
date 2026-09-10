/// Représente un utilisateur authentifié de Transit CI.
/// L'application ne gère qu'un seul type de compte : "utilisateur".
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.walletBalance = 0,
    this.rating = 5.0,
    this.favoriteCityDefault = 'Abidjan',
    this.emergencyContacts = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? photoUrl;
  final double walletBalance;
  final double rating;
  final String favoriteCityDefault;
  final List<String> emergencyContacts;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? photoUrl,
    double? walletBalance,
    double? rating,
    String? favoriteCityDefault,
    List<String>? emergencyContacts,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      rating: rating ?? this.rating,
      favoriteCityDefault: favoriteCityDefault ?? this.favoriteCityDefault,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}
