import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_companies_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_drivers_screen.dart';
import '../../features/admin/presentation/screens/admin_payments_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/gbaka/presentation/screens/gbaka_lines_screen.dart';
import '../../features/gbaka/presentation/screens/line_detail_screen.dart';
import '../../features/history/presentation/screens/trip_history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/interurban/presentation/screens/booking_payment_screen.dart';
import '../../features/interurban/presentation/screens/companies_screen.dart';
import '../../features/interurban/presentation/screens/seat_selection_screen.dart';
import '../../features/interurban/presentation/screens/ticket_qr_screen.dart';
import '../../features/interurban/presentation/screens/trip_search_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/payment/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/ride/presentation/screens/destination_search_screen.dart';
import '../../features/ride/presentation/screens/driver_selection_screen.dart';
import '../../features/ride/presentation/screens/rate_driver_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.otpVerification,
        builder: (context, state) => OtpVerificationScreen(phone: state.extra as String? ?? ''),
      ),

      // Réservation VTC / taxi / moto
      GoRoute(path: RoutePaths.rideSearch, builder: (context, state) => const DestinationSearchScreen()),
      GoRoute(path: RoutePaths.rideDrivers, builder: (context, state) => const DriverSelectionScreen()),
      GoRoute(path: RoutePaths.rideTracking, builder: (context, state) => const RideTrackingScreen()),
      GoRoute(path: RoutePaths.rideRate, builder: (context, state) => const RateDriverScreen()),

      // Gbaka / wôrô-wôrô / bus urbain
      GoRoute(path: RoutePaths.gbakaLines, builder: (context, state) => const GbakaLinesScreen()),
      GoRoute(
        path: '${RoutePaths.gbakaLineDetail}/:id',
        builder: (context, state) => LineDetailScreen(lineId: state.pathParameters['id']!),
      ),

      // Voyages interurbains
      GoRoute(
        path: RoutePaths.interurbanCompanies,
        builder: (context, state) => const CompaniesScreen(),
      ),
      GoRoute(path: RoutePaths.interurbanSearch, builder: (context, state) => const TripSearchScreen()),
      GoRoute(path: RoutePaths.interurbanSeats, builder: (context, state) => const SeatSelectionScreen()),
      GoRoute(
        path: RoutePaths.interurbanPayment,
        builder: (context, state) => const BookingPaymentScreen(),
      ),
      GoRoute(path: RoutePaths.interurbanTicket, builder: (context, state) => const TicketQrScreen()),

      // Paiement & portefeuille
      GoRoute(path: RoutePaths.paymentMethods, builder: (context, state) => const PaymentMethodsScreen()),
      GoRoute(path: RoutePaths.wallet, builder: (context, state) => const WalletScreen()),

      // Compte
      GoRoute(path: RoutePaths.editProfile, builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: RoutePaths.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: RoutePaths.notifications, builder: (context, state) => const NotificationsScreen()),

      // Administration
      GoRoute(path: RoutePaths.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: RoutePaths.adminUsers, builder: (context, state) => const AdminUsersScreen()),
      GoRoute(path: RoutePaths.adminDrivers, builder: (context, state) => const AdminDriversScreen()),
      GoRoute(path: RoutePaths.adminCompanies, builder: (context, state) => const AdminCompaniesScreen()),
      GoRoute(path: RoutePaths.adminPayments, builder: (context, state) => const AdminPaymentsScreen()),

      // Navigation principale à onglets
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.history, builder: (context, state) => const TripHistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.favorites, builder: (context, state) => const FavoritesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
