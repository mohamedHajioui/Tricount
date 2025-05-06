import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_service_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends ConsumerState<SignupScreen>{
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final fullName = TextEditingController();
  final iban = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  
  bool _dirty = false;
  
  @override
  void dispose(){
    email.dispose();
    fullName.dispose();
    iban.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  String? validateEmail(String? v) {
    if (!_dirty) return null;
    if (v == null || v.trim().isEmpty) return 'Required';

    // Regex simple mais correct pour usage courant
    final pattern = r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$';
    final isValid = RegExp(pattern).hasMatch(v.trim());
    return isValid ? null : 'Not a valid mail';
  }

  String? validatePassword(String? v) {
    if (!_dirty) return null;
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
  
  String? validateConfirmPwd(String? v){
    if(!_dirty) return null;
    if (v == null || v.isEmpty) return 'required';
    if(v != password.text) return 'password do not match';
    return null;
  }
  
  String? validateIban(String? v){
    if(!_dirty) return null;
    if(v == null || v.isEmpty) return 'required';
    const pattern = r'^BE\d{2}(?: \d{4}){3}$';
    final isValid = RegExp(pattern).hasMatch(v);
    return isValid ? null : 'invalid format';
  }
  

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authUserProvider).isLoading;
    
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
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dirty = true),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fullName,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dirty = true),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: iban,
                  decoration: InputDecoration(
                    labelText: 'IBAN',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dirty = true),
                  validator: validateIban,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dirty = true),
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dirty = true),
                  validator: validateConfirmPwd,
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
    
  }

  
  
  
  
}