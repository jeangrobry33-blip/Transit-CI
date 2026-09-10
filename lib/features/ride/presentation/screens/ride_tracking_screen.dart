import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/sos_button.dart';
import '../../domain/ride_models.dart';
import '../providers/ride_controller.dart';

/// Suivi en direct du chauffeur avec actions (chat, appel, partage, annulation).
class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() {
    final sequence = [RideStatus.arriving, RideStatus.ongoing, RideStatus.completed];
    var step = 0;
    _timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (step >= sequence.length) {
        t.cancel();
        return;
      }
      ref.read(rideBookingProvider.notifier).updateTripStatus(sequence[step]);
      step++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la course ?'),
        content: const Text('Le chauffeur sera notifié de l\'annulation.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(rideBookingProvider.notifier).cancelTrip();
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(rideBookingProvider).trip;

    if (trip == null) {
      return const Scaffold(body: Center(child: Text('Aucune course en cours')));
    }

    ref.listen(rideBookingProvider, (previous, next) {
      if (next.trip?.status == RideStatus.completed) {
        context.pushReplacement(RoutePaths.rideRate);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.fog,
            child: const Center(
              child: Icon(Icons.map_rounded, size: 96, color: AppColors.mist),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                  const Spacer(),
                  const SosButton(compact: true),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(color: AppColors.night.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBanner(status: trip.status),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: trip.vehicleType.color.withValues(alpha: 0.15),
                          child: Text(trip.driver.photoInitials,
                              style: TextStyle(color: trip.vehicleType.color, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trip.driver.name, style: Theme.of(context).textTheme.titleMedium),
                              Text(
                                '${trip.driver.vehicleModel} · ${trip.driver.plateNumber}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                              ),
                            ],
                          ),
                        ),
                        _RoundIconButton(icon: Icons.call_rounded, onTap: () {}, filled: true),
                        const SizedBox(width: AppSpacing.sm),
                        _RoundIconButton(icon: Icons.chat_bubble_rounded, onTap: () {}, filled: true),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lien de suivi partagé avec vos proches')),
                              );
                            },
                            icon: const Icon(Icons.ios_share_rounded, size: 18),
                            label: const Text('Partager'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cancel,
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Annuler'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final RideStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RideStatus.searching => ('Recherche d\'un chauffeur…', AppColors.mist),
      RideStatus.accepted => ('Chauffeur en route', AppColors.info),
      RideStatus.arriving => ('Le chauffeur arrive', AppColors.warning),
      RideStatus.ongoing => ('Course en cours', AppColors.ivoryGreen),
      RideStatus.completed => ('Trajet terminé', AppColors.success),
      RideStatus.cancelled => ('Course annulée', AppColors.danger),
    };
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, this.filled = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? AppColors.orange.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: filled ? AppColors.orange : null, size: 20),
      ),
    );
  }
}
