import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/interurban_controller.dart';

/// Billet électronique avec QR code, affiché après confirmation du paiement.
class TicketQrScreen extends ConsumerWidget {
  const TicketQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(interurbanBookingProvider).booking;
    if (booking == null) return const Scaffold(body: Center(child: Text('Aucun billet trouvé')));

    final trip = booking.trip;

    return Scaffold(
      appBar: AppBar(title: const Text('Votre billet'), automaticallyImplyLeading: false),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text('Réservation confirmée', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(color: AppColors.night.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Text(trip.company.fullName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  QrImageView(
                    data: booking.qrPayload,
                    size: 180,
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('N° réservation : ${booking.id}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketInfo(label: 'Départ', value: trip.originCity),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.mist, size: 18),
                      Expanded(
                        child: _TicketInfo(label: 'Arrivée', value: trip.destinationCity, alignEnd: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _TicketInfo(label: 'Date', value: AppFormatters.date(trip.departure))),
                      Expanded(child: _TicketInfo(label: 'Heure', value: AppFormatters.time(trip.departure), alignEnd: true)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _TicketInfo(label: 'Passager', value: booking.passengerName)),
                      Expanded(
                        child: _TicketInfo(
                          label: 'Sièges',
                          value: booking.seatNumbers.join(', '),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total payé', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
                      Text(AppFormatters.currency(booking.totalPrice),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Retour à l\'accueil',
              onPressed: () {
                ref.read(interurbanBookingProvider.notifier).reset();
                context.go(RoutePaths.home);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Télécharger le billet',
              variant: AppButtonVariant.outline,
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Billet enregistré dans vos téléchargements')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  const _TicketInfo({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
