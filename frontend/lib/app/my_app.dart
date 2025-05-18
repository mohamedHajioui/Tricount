import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/views/pages/signup_screen.dart';
import 'package:prbd_2425_a07/views/pages/test_page.dart';
import 'package:prbd_2425_a07/views/pages/login_screen.dart';
import 'package:prbd_2425_a07/views/pages/view_tricount.dart';
import 'package:prbd_2425_a07/views/pages/view_tricounts.dart';
import 'package:prbd_2425_a07/providers/theme_provider.dart';
import 'package:prbd_2425_a07/views/pages/add_tricount.dart';

import '../views/pages/view_balance.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); 
    return MaterialApp(
      title: 'Namer App',

      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,       
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) =>SignupScreen(),
        '/tricounts': (context) => TricountListPage(),
        '/addtricount':(context)=> AddTricountPage(),
        '/viewbalance':(context) => ViewBalance()
      },
    );
  }
}
