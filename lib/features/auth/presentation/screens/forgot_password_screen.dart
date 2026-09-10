import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(_identifierController.text.trim());
    setState(() {
      _loading = false;
      _sent = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _sent ? _buildConfirmation(context) : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 56, color: AppColors.orange),
          const SizedBox(height: AppSpacing.lg),
          Text('Réinitialiser le mot de passe', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Entrez votre email ou numéro de téléphone, nous vous enverrons un lien de réinitialisation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email ou téléphone',
            hint: 'exemple@email.com',
            controller: _identifierController,
            prefixIcon: Icons.alternate_email_rounded,
            validator: (v) => AppValidators.required(v),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Envoyer le lien', loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 72, color: AppColors.success),
        const SizedBox(height: AppSpacing.lg),
        Text('Vérifiez votre boîte de réception', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Un lien de réinitialisation a été envoyé à ${_identifierController.text}.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Retour à la connexion',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
