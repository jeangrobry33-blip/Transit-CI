import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/sos_button.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../gbaka/domain/transit_line.dart';
import '../../../ride/domain/ride_models.dart';
import '../../../ride/presentation/providers/ride_controller.dart';
import '../widgets/transport_mode_grid.dart';

/// Tableau de bord principal — point d'entrée vers tous les modes de transport.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startRide(BuildContext context, WidgetRef ref, VehicleType type) {
    ref.read(rideEstimateProvider.notifier).setVehicleType(type);
    context.push(RoutePaths.rideSearch);
  }

  void _openLines(BuildContext context, LineMode mode) {
    context.push(RoutePaths.gbakaLines);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final items = [
      TransportModeItem(
        icon: VehicleType.vtcStandard.icon,
        label: 'VTC',
        color: AppColors.modeVtc,
        onTap: () => _startRide(context, ref, VehicleType.vtcStandard),
      ),
      TransportModeItem(
        icon: VehicleType.taxiCompteur.icon,
        label: 'Taxi compteur',
        color: AppColors.modeTaxi,
        onTap: () => _startRide(context, ref, VehicleType.taxiCompteur),
      ),
      TransportModeItem(
        icon: VehicleType.motoTaxi.icon,
        label: 'Moto-taxi',
        color: AppColors.modeMoto,
        onTap: () => _startRide(context, ref, VehicleType.motoTaxi),
      ),
      TransportModeItem(
        icon: LineMode.gbaka.icon,
        label: 'Gbaka',
        color: AppColors.modeGbaka,
        onTap: () => _openLines(context, LineMode.gbaka),
      ),
      TransportModeItem(
        icon: LineMode.woroworo.icon,
        label: 'Wôrô-wôrô',
        color: AppColors.modeWoroworo,
        onTap: () => _openLines(context, LineMode.woroworo),
      ),
      TransportModeItem(
        icon: LineMode.busUrbain.icon,
        label: 'Bus urbain',
        color: AppColors.modeBusUrbain,
        onTap: () => _openLines(context, LineMode.busUrbain),
      ),
      TransportModeItem(
        icon: Icons.directions_bus_filled_rounded,
        label: 'Interurbain',
        color: AppColors.modeInterurbain,
        onTap: () => context.push(RoutePaths.interurbanSearch),
      ),
      TransportModeItem(
        icon: Icons.apartment_rounded,
        label: 'Compagnies',
        color: AppColors.slate,
        onTap: () => context.push(RoutePaths.interurbanCompanies),
      ),
    ];

    return Scaffold(
      floatingActionButton: const SosButton(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${user?.fullName.split(' ').first ?? 'voyageur'}.',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.orangeInk),
                            const SizedBox(width: 2),
                            Text(
                              user?.favoriteCityDefault ?? 'Abidjan, Côte d\'Ivoire',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Notifications',
                    button: true,
                    child: InkWell(
                      onTap: () => context.push(RoutePaths.notifications),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                        child: Stack(
                          children: [
                            const Center(child: Icon(Icons.notifications_none_rounded)),
                            Positioned(
                              top: 11,
                              right: 11,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: () => context.push(RoutePaths.tripSearch),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted),
                      const SizedBox(width: AppSpacing.md),
                      Text('Où allez-vous ?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: () => context.go(RoutePaths.map),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.fog,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.map_rounded, size: 56, color: AppColors.mist)),
                      Positioned(
                        left: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.my_location_rounded, size: 14, color: AppColors.ivoryGreen),
                              SizedBox(width: 6),
                              Text('Position détectée', style: TextStyle(fontSize: 12, color: AppColors.night)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_rounded, size: 14, color: AppColors.night),
                              SizedBox(width: 6),
                              Text('Ouvrir la carte', style: TextStyle(fontSize: 12, color: AppColors.night, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Comment voyagez-vous ?', subtitle: 'Choisissez votre mode de transport'),
              const SizedBox(height: AppSpacing.md),
              TransportModeGrid(items: items),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Trajets récents',
                actionLabel: 'Voir tout',
                onAction: () => context.push(RoutePaths.history),
              ),
              const SizedBox(height: AppSpacing.md),
              const _RecentTripsPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pas d'historique de trajet simulé ici : tant que le trajet n'est pas
/// réellement enregistré (voir feature `history`), on le dit plutôt que
/// d'inventer un trajet "Plateau → Cocody" fictif.
class _RecentTripsPlaceholder extends StatelessWidget {
  const _RecentTripsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Vos trajets récents apparaîtront ici après votre première recherche.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
