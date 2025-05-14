import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/tricount.dart';
import 'package:prbd_2425_a07/providers/auth_service_provider.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import '../widgets/tricound_card.dart';
import 'package:prbd_2425_a07/providers/theme_provider.dart';
import 'package:prbd_2425_a07/providers/reset_db_provider.dart';

import 'package:prbd_2425_a07/core/services/auth_service.dart';

class TricountListPage extends ConsumerWidget {
  static const routeName = '/tricounts';
  const TricountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricountsAsync = ref.watch(tricountnotifyer);
    final reset = ref.watch(resetDbControllerProvider);
    final bool loadingReset = reset.isLoading;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text('My Tricounts'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/addtricount');
            }, // + button
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {}, // - button
            icon: Icon(Icons.refresh),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),

            // ✅ Dark Mode Toggle
            Consumer(
              builder: (context, ref, _) {
                final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

                return SwitchListTile(
                  secondary: Icon(Icons.mode_night),
                  title: Text('Dark Mode'),
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
            
            ListTile(
              leading: Icon(Icons.recycling),
              title: Text('Reset Database'),
              onTap: loadingReset
                  ? null
                  : () => ref.read(resetDbControllerProvider.notifier).reset(context),
              trailing: loadingReset
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : null,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                ref.read(authUserProvider.notifier).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),

          ],
        ),
      ),


      body: tricountsAsync.when(
        data: (tricounts) {
          if (tricounts == null || tricounts.isEmpty) {
            return Center(child: Text('No tricounts found.'));
          }

          return ListView(
            children: tricounts.map((t) {
              return TricountCard(tricount: t);
            }).toList(),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
