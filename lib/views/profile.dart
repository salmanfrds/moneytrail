import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneytrail/provider/auth_provider.dart'; // Keep your existing provider import
import 'package:moneytrail/provider/theme_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    // Fetch user data from Firestore to get the current 'photoUrl'
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        // Get photoUrl from Firestore if it exists
        String? firestorePhotoUrl;
        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          firestorePhotoUrl = data['photoUrl'];
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 100, // radius 50 * 2
                        height: 100,
                        child: firestorePhotoUrl != null
                            ? Image.network(
                                firestorePhotoUrl,
                                fit: BoxFit.cover,
                                // 1. LOADING STATE (While fetching the actual JPG bytes)
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.indigo.shade100,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      );
                                    },
                                // 2. ERROR STATE (If URL is broken 404)
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.indigo,
                                    child: const Icon(
                                      Icons.person_off,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            // 3. EMPTY STATE (No URL in Firestore)
                            : Container(
                                color: Colors.indigo,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? "User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "No Email",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 40),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    context.push('/edit-profile');
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text("Dark Mode"),
                  value: ref.watch(themeProvider) == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
