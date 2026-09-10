import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/ride_models.dart';
import '../providers/ride_controller.dart';

class RateDriverScreen extends ConsumerStatefulWidget {
  const RateDriverScreen({super.key});

  @override
  ConsumerState<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends ConsumerState<RateDriverScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  final _tips = [0, 200, 500, 1000];
  int _selectedTip = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(rideBookingProvider).trip;
    if (trip == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text('Trajet terminé', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Total payé : ${AppFormatters.currency(trip.estimatedFare)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
              ),
              const SizedBox(height: AppSpacing.xl),
              CircleAvatar(
                radius: 36,
                backgroundColor: trip.vehicleType.color.withValues(alpha: 0.15),
                child: Text(trip.driver.photoInitials,
                    style: TextStyle(color: trip.vehicleType.color, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(trip.driver.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Text('Comment était votre trajet ?', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.warning),
                onRatingUpdate: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${_rating.toStringAsFixed(0)} / 5', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Laisser un commentaire (facultatif)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Ajouter un pourboire', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: _tips.map((tip) {
                  final selected = _selectedTip == tip;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTip = tip),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.orange.withValues(alpha: 0.12) : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: selected ? AppColors.orange : Colors.transparent),
                          ),
                          child: Text(
                            tip == 0 ? 'Aucun' : '$tip F',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              AppButton(
                label: 'Terminer',
                onPressed: () {
                  ref.read(rideBookingProvider.notifier).reset();
                  context.go(RoutePaths.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
