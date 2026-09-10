import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';
import '../widgets/social_login_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
    if (ok && mounted) context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final loading = authState is AuthLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.danger),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                _LogoMark(),
                const SizedBox(height: AppSpacing.xl),
                Text('Bon retour parmi nous', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connectez-vous pour continuer votre trajet à travers la Côte d\'Ivoire.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Email ou téléphone',
                  hint: 'exemple@email.com ou 07 00 00 00 00',
                  controller: _identifierController,
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => AppValidators.required(v, field: 'Ce champ'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: AppValidators.password,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RoutePaths.forgotPassword),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(label: 'Se connecter', loading: loading, onPressed: _submit),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('ou continuer avec',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SocialLoginButtons(onSuccess: () => context.go(RoutePaths.home)),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pas encore de compte ?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
                    TextButton(
                      onPressed: () => context.push(RoutePaths.register),
                      child: const Text('Créer un compte'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.directions_transit_filled_rounded, color: AppColors.white),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('Transit CI', style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
