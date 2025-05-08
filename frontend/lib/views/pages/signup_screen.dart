import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_service_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // contrôleurs
  final emailCtrl      = TextEditingController();
  final fullNameCtrl   = TextEditingController();
  final ibanCtrl       = TextEditingController();
  final pwdCtrl        = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  // clés individuelles pour revalider un seul champ
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _nameFieldKey  = GlobalKey<FormFieldState>();

  // états d’erreur asynchrone
  bool _isEmailAvailable = true;
  bool _isNameAvailable  = true;

  // debounce
  Timer? _emailTimer;
  Timer? _nameTimer;

  @override
  void dispose() {
    emailCtrl.dispose();
    fullNameCtrl.dispose();
    ibanCtrl.dispose();
    pwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    _emailTimer?.cancel();
    _nameTimer?.cancel();
    super.dispose();
  }

  // ──────────────── requêtes disponibilité ────────────────
  Future<void> _checkEmail(String email) async {
    final ok = await ref.read(authServiceProvider).checkEmailAvailable(email);
    if (mounted) setState(() {
      _isEmailAvailable = ok;
      _emailFieldKey.currentState?.validate();
    });
  }

  Future<void> _checkName(String name) async {
    final ok = await ref.read(authServiceProvider).checkNameAvailable(name);
    if (mounted) setState(() {
      _isNameAvailable = ok;
      _nameFieldKey.currentState?.validate();
    });
  }

  // ───────────────────── validateurs ──────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    const pat = r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$';
    if (!RegExp(pat).hasMatch(v.trim())) return 'Invalid email';
    if (!_isEmailAvailable) return 'Not available';
    return null;
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().length < 3) return 'Name too short';
    if (!_isNameAvailable) return 'Not available';
    return null;
  }

  String? _validateIban(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    const pat = r'^BE\d{2}(?: \d{4}){3}$';
    return RegExp(pat).hasMatch(v) ? null : 'Invalid format';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v.length < 8)                        return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v))       return 'One uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v))       return 'One lowercase letter';
    if (!RegExp(r'\d').hasMatch(v))          return 'One number';
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(v))
      return 'One special char';
    return null;
  }

  String? _validateConfirmPwd(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v != pwdCtrl.text)       return 'Passwords do not match';
    return null;
  }

  // ───────────────────────── submit ───────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authUserProvider.notifier).signup(
      emailCtrl.text.trim(),
      fullNameCtrl.text.trim(),
      ibanCtrl.text.trim(),
      pwdCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authUserProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ────────────── Email ──────────────
                TextFormField(
                  key: _emailFieldKey,
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  onChanged: (val) {
                    _emailTimer?.cancel();
                    if (val.trim().isEmpty) return;
                    _emailTimer =
                        Timer(const Duration(milliseconds: 300),
                                () => _checkEmail(val.trim()));
                  },
                ),
                const SizedBox(height: 16),
                // ─────────── Full name ────────────
                TextFormField(
                  key: _nameFieldKey,
                  controller: fullNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                  onChanged: (val) {
                    _nameTimer?.cancel();
                    if (val.trim().isEmpty) return;
                    _nameTimer =
                        Timer(const Duration(milliseconds: 300),
                                () => _checkName(val.trim()));
                  },
                ),
                const SizedBox(height: 16),
                // ────────────── IBAN ──────────────
                TextFormField(
                  controller: ibanCtrl,
                  decoration: const InputDecoration(
                    labelText: 'IBAN',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateIban,
                ),
                const SizedBox(height: 16),
                // ─────────── Password ────────────
                TextFormField(
                  controller: pwdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                // ───── Confirm password ─────
                TextFormField(
                  controller: confirmPwdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validateConfirmPwd,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
