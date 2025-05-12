import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/login_card.dart';
import 'package:prbd_2425_a07/views/widgets/login_card.dart';
import '../../providers/auth_service_provider.dart';
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
  bool _emailDirty = false;
  bool _pwdDirty = false;
  bool _triedLogin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _triedLogin = true);
    if (!_formKey.currentState!.validate()) return;
    ref.read(authUserProvider.notifier).login(
      _emailCtrl.text.trim(),
      _pwdCtrl.text.trim(),
    );
  }

  // VALIDATEURS
  String? _validateEmail(String? v) {
    if (!_emailDirty) return null;
    if (v == null || v.trim().isEmpty) return 'Required';

    // Regex simple mais correct pour usage courant
    final pattern = r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$';
    final isValid = RegExp(pattern).hasMatch(v.trim());
    return isValid ? null : 'Not a valid mail';
  }

  String? _validatePassword(String? v) {
    if (!_pwdDirty) return null;
    if (v == null || v.isEmpty) return 'Required';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'At least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'At least one lowercase letter';
    if (!RegExp(r'\d').hasMatch(v)) return 'At least one number';
    if (!RegExp(r'[!@#\\\$%^&*(),.?\":{}|<>]').hasMatch(v)) {
      return 'At least one special character';
    }
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  }
  //pour desactiver login
  bool _formHasErrors() {
    return _validateEmail(_emailCtrl.text) != null ||
        _validatePassword(_pwdCtrl.text) != null;
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('Bad credentials'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // ---------------- ÉTAT LOGIN ----------------
    final auth = ref.watch(authUserProvider);
    final bool loadingLogin = auth.isLoading;

    final loginError = ref.watch(authUserProvider).whenOrNull(
      error: (e, _) => e.toString(),
    );

    if (_triedLogin && loginError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
      setState(() => _triedLogin = false);
    }



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
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (_) => setState(() => _emailDirty = true),
                      validator: _validateEmail
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (_) => setState(() => _pwdDirty = true),
                      validator: _validatePassword
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (loadingLogin || _formHasErrors()) ? null : _submit,
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
                onLogin: (email) async {
                  await ref.read(authUserProvider.notifier).login(email, 'Password1,');
                  final user = ref.read(authUserProvider).value;

                  if (user != null && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/tricounts');
                  }
                },

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

