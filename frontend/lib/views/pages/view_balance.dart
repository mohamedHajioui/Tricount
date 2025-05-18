import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/tricount.dart';
import 'package:prbd_2425_a07/providers/auth_service_provider.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import '../widgets/tricound_card.dart';
import 'package:prbd_2425_a07/providers/theme_provider.dart';
import 'package:prbd_2425_a07/providers/reset_db_provider.dart';
import '../widgets/login_card.dart';
import '../../providers/get_current_user.dart';

class ViewBalance extends ConsumerStatefulWidget{
  static const routeName = '/viewbalance';
  const ViewBalance({super.key});

  @override
  ConsumerState<ViewBalance> createState() => _viewBalanceState();
}

class _viewBalanceState extends ConsumerState<ViewBalance>{
  
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        
      ),
    );
  }
  
}