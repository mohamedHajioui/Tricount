import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/tricount.dart';
import 'package:prbd_2425_a07/providers/auth_service_provider.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import 'package:prbd_2425_a07/views/pages/add_tricount.dart';
import '../widgets/tricound_card.dart';
import 'package:prbd_2425_a07/providers/theme_provider.dart';
import 'package:prbd_2425_a07/providers/reset_db_provider.dart';

import 'package:prbd_2425_a07/core/services/auth_service.dart';
import '../widgets/no_tricount_view.dart';


class TricountListPage extends ConsumerWidget {
  static const routeName = '/tricounts';
  const TricountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricountsAsync = ref.watch(tricountnotifyer);
    final current_user = ref.read(authUserProvider).value;
    
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTricountPage(tricountId: 0),
                ),
              );
            }, // + button
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              final tricountListNotifier = ref.read(tricountnotifyer.notifier);
              tricountListNotifier.refreshTriCountList();
            }, // - button
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  if (current_user != null) ...[
                    Text(
                      current_user.fullName,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      current_user.email,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
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
            return const NoTricountsView();;
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
