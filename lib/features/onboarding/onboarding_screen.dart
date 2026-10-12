import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/ticket_shape.dart';
import '../splash/splash_screen.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final Color accent;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.compare_arrows_rounded,
    accent: AppColors.modeGbaka,
    title: 'Un seul endroit pour comparer',
    description:
        'Gbaka, wôrô-wôrô, taxi compteur, bus urbain, VTC ou moto-taxi : Transit CI compare prix et durée, sans réserver de chauffeur.',
  ),
  _OnboardingPage(
    icon: Icons.signpost_rounded,
    accent: AppColors.modeWoroworo,
    title: 'Un temps de trajet qui tient compte de la pluie',
    description:
        'Heures de pointe, averses, affluence : l\'estimation du temps de trajet s\'ajuste, elle ne reste pas figée.',
  ),
  _OnboardingPage(
    icon: Icons.confirmation_number_rounded,
    accent: AppColors.modeInterurbain,
    title: 'De vraies compagnies, de vraies gares',
    description:
        'UTB, SBTA, Sabé Transport et d\'autres compagnies retrouvées par nos recherches de terrain : sièges, paiement et QR code pour voyager entre les villes.',
  ),
  _OnboardingPage(
    icon: Icons.account_balance_wallet_rounded,
    accent: AppColors.ivoryGreenDark,
    title: 'Orange Money, MTN MoMo, Wave',
    description: 'Payez comme vous le faites déjà, sans compte bancaire à ouvrir.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingSeenKey, true);
    if (mounted) context.go(RoutePaths.login);
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(onPressed: _finish, child: const Text('Passer')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingPageView(page: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    // orangeDark (pas orange) : un indicateur a besoin de 3:1
                    // minimum contre le fond, orange brut n'y arrive pas.
                    color: i == _index ? AppColors.orangeDark : AppColors.fog,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppButton(
                label: _index == _pages.length - 1 ? 'Commencer' : 'Suivant',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: page.accent.withValues(alpha: 0.1),
            shape: const TicketShapeBorder(radius: AppRadius.xl, notchRadius: 12),
            child: SizedBox(
              width: 240,
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(page.icon, size: 56, color: page.accent),
                    ),
                  ),
                  TicketPerforation(color: page.accent.withValues(alpha: 0.35), height: 150),
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'TRANSIT CI',
                          style: AppTextStyles.caption.copyWith(color: page.accent, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
