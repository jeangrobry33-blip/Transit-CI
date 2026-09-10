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
    ref.read(rideBookingProvider.notifier).setVehicleType(type);
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
                          'Bonjour, ${user?.fullName.split(' ').first ?? 'voyageur'} 👋',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.orange),
                            const SizedBox(width: 2),
                            Text(
                              user?.favoriteCityDefault ?? 'Abidjan, Côte d\'Ivoire',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push(RoutePaths.notifications),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                      child: Stack(
                        children: [
                          const Center(child: Icon(Icons.notifications_none_rounded)),
                          Positioned(
                            top: 10,
                            right: 10,
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
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: () => context.push(RoutePaths.rideSearch),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.mist),
                      const SizedBox(width: AppSpacing.md),
                      Text('Où allez-vous ?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Comment voyagez-vous ?', subtitle: 'Choisissez votre mode de transport'),
              const SizedBox(height: AppSpacing.md),
              TransportModeGrid(items: items),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('-20% sur votre 1er trajet VTC',
                              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Utilisez le code BIENVENUE20',
                              style: TextStyle(color: AppColors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_offer_rounded, color: AppColors.white, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Trajets récents',
                actionLabel: 'Voir tout',
                onAction: () => context.push(RoutePaths.history),
              ),
              const SizedBox(height: AppSpacing.md),
              _RecentTripTile(
                icon: Icons.directions_car_rounded,
                title: 'Plateau → Cocody',
                subtitle: 'Hier · VTC · 2 200 FCFA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTripTile extends StatelessWidget {
  const _RecentTripTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

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
              color: AppColors.modeVtc.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.modeVtc, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
              ],
            ),
          ),
          const Icon(Icons.repeat_rounded, color: AppColors.mist),
        ],
      ),
    );
  }
}
