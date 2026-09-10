class AdminUserSummary {
  const AdminUserSummary({
    required this.name,
    required this.phone,
    required this.tripsCount,
    required this.joinedAt,
    required this.status,
  });

  final String name;
  final String phone;
  final int tripsCount;
  final DateTime joinedAt;
  final String status;
}

class AdminDriverSummary {
  const AdminDriverSummary({
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.tripsCount,
    required this.status,
  });

  final String name;
  final String vehicle;
  final double rating;
  final int tripsCount;
  final String status;
}

class AdminPaymentSummary {
  const AdminPaymentSummary({
    required this.reference,
    required this.method,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String reference;
  final String method;
  final double amount;
  final DateTime date;
  final String status;
}
