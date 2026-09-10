import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/interurban_controller.dart';

/// Sélection des sièges dans le bus (plan interactif).
class SeatSelectionScreen extends ConsumerWidget {
  const SeatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(interurbanBookingProvider);
    final trip = booking.selectedTrip;
    if (trip == null) return const Scaffold(body: Center(child: Text('Aucun trajet sélectionné')));

    final seatsAsync = ref.watch(seatMapProvider(trip));

    return Scaffold(
      appBar: AppBar(title: const Text('Sélection des sièges')),
      body: SafeArea(
        top: false,
        child: seatsAsync.when(
          data: (seats) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    _Legend(color: Theme.of(context).cardColor, label: 'Libre', bordered: true),
                    const SizedBox(width: AppSpacing.lg),
                    const _Legend(color: AppColors.orange, label: 'Sélectionné'),
                    const SizedBox(width: AppSpacing.lg),
                    const _Legend(color: AppColors.mist, label: 'Occupé'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.airline_seat_recline_normal_rounded, color: AppColors.mist),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: seats.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, i) {
                          final seat = seats[i];
                          // Laisse un couloir central entre les colonnes 2 et 3.
                          final isAisleStart = i % 4 == 1;
                          final selected = booking.selectedSeats.contains(seat.number);
                          return Padding(
                            padding: EdgeInsets.only(right: isAisleStart ? AppSpacing.xl : 0),
                            child: _SeatTile(
                              number: seat.number,
                              taken: seat.taken,
                              selected: selected,
                              onTap: seat.taken
                                  ? null
                                  : () => ref.read(interurbanBookingProvider.notifier).toggleSeat(seat.number),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: AppColors.night.withValues(alpha: 0.06), blurRadius: 12)],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${booking.selectedSeats.length} siège(s)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                            Text(AppFormatters.currency(booking.totalPrice),
                                style: Theme.of(context).textTheme.headlineSmall),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AppButton(
                          label: 'Continuer',
                          onPressed: booking.selectedSeats.isEmpty
                              ? null
                              : () => context.push(RoutePaths.interurbanPayment),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erreur : $e')),
        ),
      ),
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({required this.number, required this.taken, required this.selected, this.onTap});

  final int number;
  final bool taken;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = taken
        ? AppColors.mist.withValues(alpha: 0.3)
        : selected
            ? AppColors.orange
            : Theme.of(context).cardColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: selected ? AppColors.orange : AppColors.fog),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: selected ? AppColors.white : (taken ? AppColors.white : null),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.bordered = false});

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: bordered ? Border.all(color: AppColors.fog) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
