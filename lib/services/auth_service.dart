import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final db = FirebaseFirestore.instance;

  Future<bool> createUser(String email, String password) async {
    try {
      final credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credentials.additionalUserInfo!.isNewUser) {
        await db.collection("users").doc(credentials.user!.uid).set({
          "email": email,
        });
      }

      return true;
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  Future<bool> signinGoogle() async {
    try {
      final credentials = await signInWithGoogle();
      if (credentials.additionalUserInfo!.isNewUser) {
        await db.collection("users").doc(credentials.user!.uid).set({
          "email": credentials.user!.email,
        });
      }
      return true;
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
}
