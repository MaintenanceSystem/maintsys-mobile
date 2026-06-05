import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/machines/screens/machines_list_screen.dart';
import '../../features/machines/screens/machine_detail_screen.dart';
import '../../features/service_orders/screens/service_orders_screen.dart';
import '../../features/service_orders/screens/service_order_detail_screen.dart';
import '../../features/maintenance_logs/screens/maintenance_logs_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';

final _authService = AuthService();

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: _globalRedirect,
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),

    // Shell com Bottom Nav
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/machines',
          name: 'machines',
          builder: (_, __) => const MachinesListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'machine-detail',
              builder: (_, state) => MachineDetailScreen(
                machineId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (_, __) => const ServiceOrdersScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'order-detail',
              builder: (_, state) => ServiceOrderDetailScreen(
                orderId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/logs',
          name: 'logs',
          builder: (_, __) => const MaintenanceLogsScreen(),
        ),
        GoRoute(
          path: '/alerts',
          name: 'alerts',
          builder: (_, __) => const AlertsScreen(),
        ),
      ],
    ),
  ],
);

Future<String?> _globalRedirect(BuildContext context, GoRouterState state) async {
  final isLoggedIn = await _authService.isLoggedIn();
  final isAuthRoute = state.matchedLocation == '/login' ||
      state.matchedLocation == '/splash';

  if (!isLoggedIn && !isAuthRoute) return '/login';
  if (isLoggedIn && state.matchedLocation == '/login') return '/home';
  return null;
}

// =====================================================
//  SPLASH SCREEN
// =====================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final isLoggedIn = await _authService.isLoggedIn();
    if (!mounted) return;
    context.go(isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MaintSys',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manutenção Industrial 4.0',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
//  MAIN SHELL - Bottom Navigation
// =====================================================
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Home', path: '/home'),
    (icon: Icons.precision_manufacturing_rounded, label: 'Máquinas', path: '/machines'),
    (icon: Icons.assignment_rounded, label: 'Ordens', path: '/orders'),
    (icon: Icons.history_rounded, label: 'Logs', path: '/logs'),
    (icon: Icons.notifications_rounded, label: 'Alertas', path: '/alerts'),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexFor(location),
        onTap: (i) => context.go(_items[i].path),
        items: _items
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e.icon),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}
