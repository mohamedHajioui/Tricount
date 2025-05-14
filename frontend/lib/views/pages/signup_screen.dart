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
  /* ---------- controllers & keys ---------- */
  final _formKey        = GlobalKey<FormState>();
  final emailCtrl       = TextEditingController();
  final fullNameCtrl    = TextEditingController();
  final ibanCtrl        = TextEditingController();
  final pwdCtrl         = TextEditingController();
  final confirmPwdCtrl  = TextEditingController();

  final _emailKey = GlobalKey<FormFieldState>();
  final _nameKey  = GlobalKey<FormFieldState>();
  final _ibanKey  = GlobalKey<FormFieldState>();
  final _pwdKey   = GlobalKey<FormFieldState>();
  final _confKey  = GlobalKey<FormFieldState>();

  /* ---------- async state ---------- */
  bool _isEmailAvailable = true;
  bool _isNameAvailable  = true;

  Timer? _emailTimer, _nameTimer;

  /* ---------- VALIDATORS ---------- */
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    const pat = r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$';
    if (!RegExp(pat).hasMatch(v.trim())) return 'Invalid email';
    return _isEmailAvailable ? null : 'Not available';
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.trim().length < 3) return 'Name too short';
    return _isNameAvailable ? null : 'Not available';
  }

  String? _validateIban(String? v) {
    if (v == null || v.isEmpty) return null; // facultatif
    return RegExp(r'^BE\d{2}(?: \d{4}){3}$').hasMatch(v)
        ? null
        : 'Invalid format';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Need A-Z';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Need a-z';
    if (!RegExp(r'\d').hasMatch(v))   return 'Need 0-9';
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(v)) return 'Need symbol';
    return null;
  }

  String? _validateConfirmPwd(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    return v == pwdCtrl.text ? null : 'Mismatch';
  }

  /* ---------- async checks ---------- */
  Future<void> _checkEmail(String email) async {
    final ok = await ref.read(authServiceProvider).checkEmailAvailable(email);
    if (!mounted) return;
    setState(() {
      _isEmailAvailable = ok;
      _emailKey.currentState?.validate();
    });
  }

  Future<void> _checkName(String name) async {
    final ok = await ref.read(authServiceProvider).checkNameAvailable(name);
    if (!mounted) return;
    setState(() {
      _isNameAvailable = ok;
      _nameKey.currentState?.validate();
    });
  }

  /* ---------- submit ---------- */
  bool get _canSubmit =>
      _validateEmail(emailCtrl.text) == null &&
          _validateName(fullNameCtrl.text) == null &&
          _validateIban(ibanCtrl.text) == null &&
          _validatePassword(pwdCtrl.text)  == null &&
          _validateConfirmPwd(confirmPwdCtrl.text) == null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authUserProvider.notifier).signup(
      emailCtrl.text.trim(),
      fullNameCtrl.text.trim(),
      ibanCtrl.text.trim(),
      pwdCtrl.text.trim(), 
    );
    debugPrint('👉 SUBMIT called email=${emailCtrl.text}');
  }

  /* ---------- UI ---------- */
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
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /* Email */
                TextFormField(
                  key: _emailKey,
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  onChanged: (val) {
                    _emailKey.currentState?.validate();
                    setState(() {});                    // refresh button
                    _emailTimer?.cancel();
                    if (val.trim().isEmpty) return;
                    _emailTimer = Timer(
                      const Duration(milliseconds: 300),
                          () => _checkEmail(val.trim()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                /* Full name */
                TextFormField(
                  key: _nameKey,
                  controller: fullNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                  onChanged: (val) {
                    _nameKey.currentState?.validate();
                    setState(() {});
                    _nameTimer?.cancel();
                    if (val.trim().isEmpty) return;
                    _nameTimer = Timer(
                      const Duration(milliseconds: 300),
                          () => _checkName(val.trim()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                /* IBAN (optional) */
                TextFormField(
                  key: _ibanKey,
                  controller: ibanCtrl,
                  decoration: const InputDecoration(
                    labelText: 'IBAN',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateIban,
                  onChanged: (_) {
                    _ibanKey.currentState?.validate();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                /* Password */
                TextFormField(
                  key: _pwdKey,
                  controller: pwdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validatePassword,
                  onChanged: (_) {
                    _pwdKey.currentState?.validate();
                    _confKey.currentState?.validate(); // re-valide confirm
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                /* Confirm password */
                TextFormField(
                  key: _confKey,
                  controller: confirmPwdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validateConfirmPwd,
                  onChanged: (_) {
                    _confKey.currentState?.validate();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: (!loading && _canSubmit) ? _submit : null,
                  child: loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Sign up'),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
    
  }
}
