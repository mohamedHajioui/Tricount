import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/login_card.dart';
import 'package:prbd_2425_a07/views/widgets/login_card.dart';
import '../../providers/auth_providers.dart';
import '../../providers/reset_db_provider.dart'; 

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).login(
      _emailCtrl.text.trim(),
      _pwdCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---------------- ÉTAT LOGIN ----------------
    final auth = ref.watch(authControllerProvider);
    final bool loadingLogin = auth.isLoading;
    final String? loginError = auth.whenOrNull(error: (e, _) => e.toString());

    // Navigue lorsqu’on est connecté
    auth.whenOrNull(data: (u) {
      if (u != null) WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    });

    // ---------------- ÉTAT RESET DB -------------
    final reset = ref.watch(resetDbControllerProvider);
    final bool loadingReset = reset.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- FORMULAIRE ----------------
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                      v != null && v.contains('@') ? null : 'Email invalide',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) =>
                      v != null && v.length >= 6 ? null : '6 caractères min.',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: loadingLogin ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: loadingLogin
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Login'),
                    ),
                    if (loginError != null) ...[
                      const SizedBox(height: 12),
                      Text(loginError, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign up here!"),
              ),
              const SizedBox(height: 24),
              LoginCard(
                onLogin: (email) => ref
                    .read(authControllerProvider.notifier)
                    .login(email, 'Password1,'),
                onReset: loadingReset
                    ? null
                    : () => ref
                    .read(resetDbControllerProvider.notifier)
                    .reset(context),
                showResetLoader: loadingReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

