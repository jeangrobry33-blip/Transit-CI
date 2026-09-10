import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/router/route_paths.dart';
import '../auth/presentation/providers/auth_controller.dart';

const onboardingSeenKey = 'onboarding_seen';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool(onboardingSeenKey) ?? false;

    // Laisse le temps à l'animation et à la restauration de session.
    await Future.delayed(const Duration(milliseconds: 1400));

    var attempts = 0;
    while (ref.read(authControllerProvider) is AuthInitial && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    final authState = ref.read(authControllerProvider);

    if (!mounted) return;

    if (!seenOnboarding) {
      context.go(RoutePaths.onboarding);
    } else if (authState is AuthAuthenticated) {
      context.go(RoutePaths.home);
    } else {
      context.go(RoutePaths.login);
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
      backgroundColor: AppColors.orange,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.night.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Image.asset('assets/branding/logo_mark_rounded.png'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Transit CI',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tous vos transports, un seul clic',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
