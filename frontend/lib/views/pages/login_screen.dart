// view/login_screen.dart
// Vue reliée au provider d'authentification (étape 3)
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_providers.dart'; // adapte le chemin si besoin

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
    final email = _emailCtrl.text.trim();
    final pwd   = _pwdCtrl.text.trim();
    ref.read(authControllerProvider.notifier).login(email, pwd);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    // Navigation lorsqu'on est connecté
    auth.whenOrNull(data: (u) {
      if (u != null) WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    });

    final bool loading = auth.isLoading;
    final String? error = auth.whenOrNull(error: (e, _) => e.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      onPressed: loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Login'),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign up here!"),
              ),
              const SizedBox(height: 24),
              _QuickLoginCard(onLogin: (email) {
                ref.read(authControllerProvider.notifier).login(email, 'Password1,');
              }, onReset: () {
                // TODO: appeler l'endpoint de reset DB puis afficher un SnackBar de confirmation
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Widgets auxiliaires ----------
class _QuickLoginCard extends StatelessWidget {
  const _QuickLoginCard({required this.onLogin, required this.onReset});
  final void Function(String email) onLogin;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final mail in [
              'bepenelle@epfc.eu',
              'boverhaegen@epfc.eu',
              'gedielman@epfc.eu',
              'admin@epfc.eu',
            ])
              TextButton(
                onPressed: () => onLogin(mail),
                child: Text('Login as $mail', style: const TextStyle(color: Colors.deepOrange)),
              ),
            const Divider(),
            TextButton(
              onPressed: onReset,
              child: const Text('Reset Database', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
