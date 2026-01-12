import 'package:go_router/go_router.dart';
import 'package:moneytrail/views/view.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddTransactionPage(),
    ),
  ],
);
