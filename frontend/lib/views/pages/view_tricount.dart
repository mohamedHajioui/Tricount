import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';
import 'package:prbd_2425_a07/views/widgets/operation_card.dart';
import 'package:prbd_2425_a07/views/widgets/tricount_total_bar.dart';

class TricountView extends ConsumerStatefulWidget { 
  final int tricountId;

  const TricountView({required this.tricountId, Key? key}) : super(key: key);

  @override
  ConsumerState<TricountView> createState() => _TricountViewState();
}

class _TricountViewState extends ConsumerState<TricountView> {
  @override
  void initState() {
    super.initState();
    // Charge le tricount après le build initial
    Future.microtask(() =>
        ref.read(currentTricountProvider.notifier).loadTricount(widget.tricountId)
    );
  }

  @override
  Widget build(BuildContext context) {
    final tricountState = ref.watch(currentTricountProvider);

    if (tricountState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tricountState.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${tricountState.error}')),
      );
    }

    final tricount = tricountState.tricount;
    if (tricount == null) {
      return const Scaffold(
        body: Center(child: Text('Tricount not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tricount.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tricount.depenses.length,
              itemBuilder: (context, index) {
                return OperationCard(
                  depense: tricount.depenses[index],
                );
              },
            ),
          ),
          TricountTotalBar(),
        ],
      ),
    );
  }
}