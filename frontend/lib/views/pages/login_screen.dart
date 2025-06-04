import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import '../widgets/login_card.dart';
import '../../providers/auth_service_provider.dart';
import '../../providers/reset_db_provider.dart';
import '../../providers/get_current_user.dart';
import '../../models/user.dart';



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

  
  //pour desactiver login
  bool _formHasErrors() {
    return User.validateEmail(_emailCtrl.text) != null ||
        User.validatePassword(_pwdCtrl.text) != null;
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
  
  Future<void> _showResetConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to reset the database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('yes'),
          ),
          TextButton(
              onPressed: () => Navigator.of(context).pop(false), 
              child: const Text('No'),
          ),
        ],
      ),
    );
    if(confirmed == true){
      ref.read(resetDbControllerProvider.notifier).reset(context);
    }
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
      if (u != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/tricounts');
      });
      }
    });

    // ---------------- ÉTAT RESET DB -------------
    final reset = ref.watch(resetDbControllerProvider);
    final bool loadingReset = reset.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (_) => setState(() => _emailDirty = true),
                      validator: (value) {
                      final error = User.validateEmail(value);
                      if (error != null) return error;
                      return null;
                      }
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (_) => setState(() => _pwdDirty = true),
                      validator: (value) {
                        final error = User.validatePassword(value);
                        if(error != null) return error;
                        return null;
                      },
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
                  await ref.refresh(logged_usernotifyer.future);
                  
                  
                  final user = ref.read(authUserProvider).value;

                  if (user != null && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/tricounts');
                  }
                },

                onReset: loadingReset
                    ? null
                    : _showResetConfirmationDialog,
                showResetLoader: loadingReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

