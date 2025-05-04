import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/views/pages/test_page.dart';

import '../views/pages/view_tricounts.dart';
void main() {
  runApp(
    const ProviderScope( // Needed to enable Riverpod
      child: MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {




  const MyApp({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '../views/page/view_tricount',
      routes: {
        '../views/page/view_tricount': (context) => TricountListPage(),
      },
    );
  }
}
