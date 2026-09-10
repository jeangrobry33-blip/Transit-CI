import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/router/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../splash/splash_screen.dart';

class _OnboardingPage {
  const _OnboardingPage({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.map_rounded,
    title: 'Tous les transports, une seule app',
    description:
        'Gbakas, wôrô-wôrô, taxis compteurs, bus, VTC et motos-taxis : trouvez le moyen de transport idéal partout en Côte d\'Ivoire.',
  ),
  _OnboardingPage(
    icon: Icons.near_me_rounded,
    title: 'Suivez votre trajet en direct',
    description:
        'Localisation GPS en temps réel, estimation des temps et des coûts, trafic routier et navigation intelligente.',
  ),
  _OnboardingPage(
    icon: Icons.directions_bus_filled_rounded,
    title: 'Voyagez entre les villes',
    description:
        'Réservez vos billets avec UTB, SBTA, TSR, AVS et d\'autres compagnies : sièges, paiement et QR code en quelques secondes.',
  ),
  _OnboardingPage(
    icon: Icons.wallet_rounded,
    title: 'Payez comme vous le voulez',
    description:
        'Orange Money, MTN Money, Moov Money, carte bancaire ou portefeuille Transit CI : le paiement n\'a jamais été aussi simple.',
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
                    color: i == _index ? AppColors.orange : AppColors.fog,
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
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(page.icon, size: 80, color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mist),
          ),
        ],
      ),
    );
  }
}
