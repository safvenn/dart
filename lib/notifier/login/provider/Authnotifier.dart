import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/screens/home.dart';
import 'package:crypto_app/notifier/login/models/authmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/legacy.dart';

class Authnotifier extends StateNotifier<AuthState> {
  Authnotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isloading: true, error: null);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isloading: false,
        isAuthenticate: cred.user != null,
        userEmail: cred.user?.email,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isloading: false,
        isAuthenticate: false,
        error: 'error:$e',
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isloading: true, error: null);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
        await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(
            {"email": email,
            "createdAt": DateTime.now()}
          );
      state = state.copyWith(
        isloading: false,
        isAuthenticate: cred.user != null,
        userEmail: cred.user?.email,
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
  (ref) => FirebaseAuth.instance.authStateChanges(),
);