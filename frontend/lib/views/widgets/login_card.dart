// view/widgets/quick_login_card.dart
import 'package:flutter/material.dart';

/// Carte de connexion rapide + bouton reset base de données.
class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.onLogin,
    required this.onReset,
    required this.showResetLoader,
  });
  
  final void Function(String email) onLogin;
  final VoidCallback? onReset;
  final bool showResetLoader;

  static const _emails = [
    'bepenelle@epfc.eu',
    'boverhaegen@epfc.eu',
    'gedielman@epfc.eu',
    'admin@epfc.eu',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final mail in _emails)
              TextButton(
                onPressed: () => onLogin(mail),
                child: Text(
                  'Login as $mail',
                  style: const TextStyle(color: Colors.deepOrange),
                ),
              ),
            const Divider(),
            TextButton(
              onPressed: onReset,
              child: showResetLoader
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                'Reset Database',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
