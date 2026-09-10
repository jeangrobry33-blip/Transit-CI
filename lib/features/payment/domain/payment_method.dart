import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum PaymentMethodType { orangeMoney, mtnMoney, moovMoney, card, wallet }

extension PaymentMethodTypeX on PaymentMethodType {
  String get label => switch (this) {
        PaymentMethodType.orangeMoney => 'Orange Money',
        PaymentMethodType.mtnMoney => 'MTN Mobile Money',
        PaymentMethodType.moovMoney => 'Moov Money',
        PaymentMethodType.card => 'Carte bancaire',
        PaymentMethodType.wallet => 'Portefeuille Transit CI',
      };

  IconData get icon => switch (this) {
        PaymentMethodType.orangeMoney => Icons.phone_android_rounded,
        PaymentMethodType.mtnMoney => Icons.phone_android_rounded,
        PaymentMethodType.moovMoney => Icons.phone_android_rounded,
        PaymentMethodType.card => Icons.credit_card_rounded,
        PaymentMethodType.wallet => Icons.account_balance_wallet_rounded,
      };

  Color get color => switch (this) {
        PaymentMethodType.orangeMoney => AppColors.orange,
        PaymentMethodType.mtnMoney => const Color(0xFFFFCC00),
        PaymentMethodType.moovMoney => const Color(0xFF00A19A),
        PaymentMethodType.card => AppColors.info,
        PaymentMethodType.wallet => AppColors.ivoryGreen,
      };
}

class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.isDefault = false,
  });

  final String id;
  final PaymentMethodType type;
  final String label;
  final bool isDefault;
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isCredit;
}
