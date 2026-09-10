import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      category: NotificationCategory.departure,
      title: 'Votre bus part bientôt',
      message: 'Le bus UTB pour Bouaké part dans 30 minutes depuis la gare du Plateau.',
      date: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AppNotification(
      id: 'n2',
      category: NotificationCategory.promotion,
      title: '-20% sur vos trajets VTC',
      message: 'Profitez de 20% de réduction sur toutes vos courses VTC ce week-end.',
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotification(
      id: 'n3',
      category: NotificationCategory.traffic,
      title: 'Trafic dense signalé',
      message: 'Ralentissements importants sur le Boulevard VGE en direction de Cocody.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      read: true,
    ),
    AppNotification(
      id: 'n4',
      category: NotificationCategory.arrival,
      title: 'Chauffeur arrivé',
      message: 'Kouadio Yao est arrivé à votre point de départ.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      read: true,
    ),
    AppNotification(
      id: 'n5',
      category: NotificationCategory.system,
      title: 'Mise à jour de l\'application',
      message: 'De nouvelles fonctionnalités sont disponibles dans Transit CI.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      read: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _notifications = _notifications
                  .map((n) => AppNotification(
                        id: n.id,
                        category: n.category,
                        title: n.title,
                        message: n.message,
                        date: n.date,
                        read: true,
                      ))
                  .toList();
            }),
            child: const Text('Tout marquer lu'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'Aucune notification',
              message: 'Vous êtes à jour ! Revenez plus tard pour de nouvelles informations.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: n.read ? Theme.of(context).cardColor : n.category.color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: n.category.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(n.category.icon, size: 18, color: n.category.color),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(n.message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                            const SizedBox(height: 4),
                            Text(AppFormatters.dateTime(n.date),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                          ],
                        ),
                      ),
                      if (!n.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
