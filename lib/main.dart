// lib/main.dart
import 'package:crypto_app/ecommerce/admin/screens/dashboard.dart';
import 'package:crypto_app/ecommerce/models/navbar.dart';
import 'package:crypto_app/notifier/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1B24),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),
      themeMode: ThemeMode.system,
      home: my(),
    );
  }
}

class my extends ConsumerWidget {
  const my({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    // Show a loading indicator while auth state is being resolved
    if (auth.isloading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If authenticated, show Dashboard for admins, Navbar for regular users
    if (auth.isAuthenticate == true) {
      final isAdmin = auth.isAdmin ?? false;
      return isAdmin ? const Dashboard() : const Navbar();
    }

    // Not authenticated -> show Login
    return const Login();
  }
}
