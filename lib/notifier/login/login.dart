// lib/screens/login_stylish.dart
import 'package:crypto_app/ecommerce/screens/home.dart';
import 'package:crypto_app/main.dart';

import 'package:crypto_app/notifier/login/models/authmodel.dart';
import 'package:crypto_app/notifier/login/register.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_app/notifier/login/provider/Authnotifier.dart';
import 'package:flutter_riverpod/legacy.dart';

// keep your existing provider and controllers (you said they're top-level)
final authProvider = StateNotifierProvider<Authnotifier, AuthState>((ref) {
  return Authnotifier();
});
final _formkey = GlobalKey<FormState>();
final TextEditingController _email = TextEditingController();
final TextEditingController _pass = TextEditingController();



class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login>
    with SingleTickerProviderStateMixin {
  bool _obscure = true;
  // simplified: removed animation fields

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // no local animation controllers to dispose
    // Note: controllers are top-level in your snippet; don't dispose them here if shared elsewhere.
    // If you want them disposed with the screen, uncomment the following lines:
    // _email.dispose();
    // _pass.dispose();
    super.dispose();
  }


  Future<void> _submitLogin() async {
    
    if (!_formkey.currentState!.validate()) return;
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    await ref.read(authProvider.notifier).login(email, pass);
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(MaterialPageRoute(builder: (_) =>const my()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    

    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter email';
                      final email = v.trim();
                      final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!regex.hasMatch(email)) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (auth.error != null)
                    Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isloading ? null : _submitLogin,
                      child: auth.isloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log in'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        ),
                        child: const Text('Create account'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/forgot-password'),
                        child: const Text('Forgot?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
