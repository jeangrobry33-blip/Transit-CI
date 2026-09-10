import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../interurban/presentation/providers/interurban_controller.dart';

class AdminCompaniesScreen extends ConsumerWidget {
  const AdminCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compagnies de transport')),
      body: companiesAsync.when(
        data: (companies) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: companies.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final c = companies[i];
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
                      color: c.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(c.name, style: TextStyle(color: c.color, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.fullName, style: Theme.of(context).textTheme.titleMedium),
                        Text('${c.citiesServed.length} villes desservies',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}
