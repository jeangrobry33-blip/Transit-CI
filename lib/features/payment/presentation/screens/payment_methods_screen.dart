import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/payment_method.dart';

/// Gestion des moyens de paiement enregistrés par l'utilisateur.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<SavedPaymentMethod> _methods = const [
    SavedPaymentMethod(
      id: 'pm_1',
      type: PaymentMethodType.orangeMoney,
      label: '+225 07 •• •• 03 04',
      isDefault: true,
    ),
    SavedPaymentMethod(id: 'pm_2', type: PaymentMethodType.mtnMoney, label: '+225 05 •• •• 11 22'),
    SavedPaymentMethod(id: 'pm_3', type: PaymentMethodType.card, label: 'Visa •••• 4242'),
  ];

  Future<void> _addMethod() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddPaymentMethodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moyens de paiement'),
        actions: [IconButton(onPressed: _addMethod, icon: const Icon(Icons.add_rounded))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _methods.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final method = _methods[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: method.type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(method.type.icon, color: method.type.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(method.type.label, style: Theme.of(context).textTheme.titleMedium),
                      Text(method.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text('Par défaut', style: TextStyle(color: AppColors.success, fontSize: 11)),
                  )
                else
                  IconButton(
                    onPressed: () => setState(() => _methods.remove(method)),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddPaymentMethodSheet extends StatefulWidget {
  const _AddPaymentMethodSheet();

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  PaymentMethodType _type = PaymentMethodType.orangeMoney;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajouter un moyen de paiement', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PaymentMethodType.orangeMoney,
              PaymentMethodType.mtnMoney,
              PaymentMethodType.moovMoney,
              PaymentMethodType.card,
            ].map((type) {
              final selected = _type == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (_) => setState(() => _type = type),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: _type == PaymentMethodType.card ? 'Numéro de carte' : 'Numéro de téléphone',
            hint: _type == PaymentMethodType.card ? '4242 4242 4242 4242' : '07 00 00 00 00',
            controller: _controller,
            keyboardType: _type == PaymentMethodType.card ? TextInputType.number : TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Enregistrer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
