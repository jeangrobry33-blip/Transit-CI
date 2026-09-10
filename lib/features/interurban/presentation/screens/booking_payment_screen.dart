import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../payment/domain/payment_method.dart';
import '../../../payment/presentation/widgets/payment_method_tile.dart';
import '../providers/interurban_controller.dart';

class BookingPaymentScreen extends ConsumerStatefulWidget {
  const BookingPaymentScreen({super.key});

  @override
  ConsumerState<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  PaymentMethodType _selected = PaymentMethodType.orangeMoney;
  late final TextEditingController _nameController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    ref.read(interurbanBookingProvider.notifier).confirmBooking(_nameController.text.trim());
    if (mounted) {
      setState(() => _submitting = false);
      context.pushReplacement(RoutePaths.interurbanTicket);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(interurbanBookingProvider);
    final trip = booking.selectedTrip;
    if (trip == null) return const Scaffold(body: Center(child: Text('Aucun trajet sélectionné')));

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${trip.originCity} → ${trip.destinationCity}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '${trip.company.fullName} · ${AppFormatters.dateTime(trip.departure)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                  ),
                  const Divider(height: AppSpacing.xl),
                  _SummaryRow(label: 'Sièges', value: booking.selectedSeats.toList().join(', ')),
                  _SummaryRow(label: 'Passagers', value: '${booking.selectedSeats.length}'),
                  _SummaryRow(
                    label: 'Total',
                    value: AppFormatters.currency(booking.totalPrice),
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Nom du passager principal',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => AppValidators.required(v, field: 'Le nom'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Mode de paiement', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...PaymentMethodType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PaymentMethodTile(
                    type: type,
                    subtitle: type == PaymentMethodType.wallet
                        ? 'Solde disponible : ${AppFormatters.currency(ref.watch(currentUserProvider)?.walletBalance ?? 0)}'
                        : 'Paiement sécurisé',
                    selected: _selected == type,
                    onTap: () => setState(() => _selected = type),
                  ),
                )),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Payer ${AppFormatters.currency(booking.totalPrice)}',
              loading: _submitting,
              onPressed: _pay,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
          Text(
            value,
            style: emphasize
                ? Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
