import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEnabled = true;
  bool _trafficAlerts = true;
  bool _promoAlerts = true;
  bool _shareLocation = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionLabel('Apparence'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('Clair'),
                    value: ThemeMode.light,
                    activeColor: AppColors.orange,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Sombre'),
                    value: ThemeMode.dark,
                    activeColor: AppColors.orange,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Système'),
                    value: ThemeMode.system,
                    activeColor: AppColors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Notifications'),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Notifications push'),
              value: _pushEnabled,
              activeThumbColor: AppColors.orange,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            SwitchListTile(
              title: const Text('Alertes trafic'),
              value: _trafficAlerts,
              activeThumbColor: AppColors.orange,
              onChanged: (v) => setState(() => _trafficAlerts = v),
            ),
            SwitchListTile(
              title: const Text('Promotions et offres'),
              value: _promoAlerts,
              activeThumbColor: AppColors.orange,
              onChanged: (v) => setState(() => _promoAlerts = v),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('Sécurité et confidentialité'),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Partager ma position en cas d\'urgence'),
              value: _shareLocation,
              activeThumbColor: AppColors.orange,
              onChanged: (v) => setState(() => _shareLocation = v),
            ),
            ListTile(
              title: const Text('Contacts de confiance'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel('À propos'),
          _SettingsCard(children: [
            ListTile(title: const Text('Conditions d\'utilisation'), onTap: () {}),
            ListTile(title: const Text('Politique de confidentialité'), onTap: () {}),
            const ListTile(title: Text('Version'), trailing: Text('1.0.0')),
          ]),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.mist)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(children: children),
    );
  }
}
