import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrail/core/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneytrail/core/core.dart';

// Parent Provider
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// Auth Stream Provider
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
