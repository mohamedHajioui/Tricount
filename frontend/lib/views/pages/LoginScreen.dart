import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routename = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose(){
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller:_pwdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        //TODO: a implementer la logique de connexion
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (){
                  //TODO: naviquer vers le signup
                },
                child: const Text("Don't have an account? Sign up here!"),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: (){
                          //TODO
                        },
                        child: const Text('Login as bepenelle@epfc.eu', style: TextStyle(color: Colors.deepOrange))
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO:
                        },
                        child: const Text('Login as boverhaegen@epfc.eu', style: TextStyle(color: Colors.deepOrange)),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 
                        },
                        child: const Text('Login as gedielman@epfc.eu', style: TextStyle(color: Colors.deepOrange)),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 
                        },
                        child: const Text('Login as admin@epfc.eu', style: TextStyle(color: Colors.deepOrange)),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: () {
                          // TODO: 
                        },
                        child: const Text('Reset Database', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}