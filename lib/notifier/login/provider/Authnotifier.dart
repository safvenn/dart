import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/notifier/login/models/authmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/legacy.dart';

final _db = FirebaseFirestore.instance.collection('users');

class Authnotifier extends StateNotifier<AuthState> {
  late final StreamSubscription<User?> _authSub;

  Authnotifier() : super(AuthState()) {
    // Listen to Firebase auth state changes and hydrate state (isAdmin, email)
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        state = AuthState();
        return;
      }
      // default while fetching
      state = state.copyWith(isloading: true);
      bool isAdmin = false;
      try {
        final userDoc = await _db.doc(user.uid).get();
        isAdmin = userDoc.data()?['isAdmin'] ?? false;
      } catch (_) {
        isAdmin = false;
      }
      state = state.copyWith(
        isloading: false,
        isAuthenticate: true,
        userEmail: user.email,
        isAdmin: isAdmin,
      );
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isloading: true, error: null);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is admin
      bool isAdmin = false;
      if (cred.user != null) {
        try {
          final userDoc = await _db.doc(cred.user!.uid).get();
          isAdmin = userDoc.data()?['isAdmin']?? false;
        } catch (e) {
          isAdmin = false;
        }
      }

      state = state.copyWith(
        isloading: false,
        isAuthenticate: cred.user != null,
        userEmail: cred.user?.email,
        isAdmin: isAdmin,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isloading: false,
        isAuthenticate: false,
        error: 'error:$e',
      );
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isloading: true, error: null);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      if (cred.user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user!.uid)
            .set({
              "email": email,
              "name": name,
              "createdAt": DateTime.now(),
              "isAdmin": false,
            });
      }

      state = state.copyWith(
        isloading: false,
        isAuthenticate: cred.user != null,
        userEmail: cred.user?.email,
        isAdmin: false,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isloading: false,
        isAuthenticate: false,
        error: 'error:$e',
      );
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    state = AuthState();
  }
}

final authstateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges().map((user) => user)
);
