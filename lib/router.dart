import 'package:go_router/go_router.dart';
import 'package:moneytrail/views/view.dart';
import 'package:moneytrail/views/edit_profile.dart'; // Add import

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/home', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddTransactionPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
  ],
);
