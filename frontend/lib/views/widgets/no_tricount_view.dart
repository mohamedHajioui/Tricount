import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/views/pages/add_tricount.dart';

class NoTricountsView extends StatelessWidget {
  const NoTricountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "No tricounts yet!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Create your first tricount now!",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTricountPage(tricountId: 0),
                    ),
                  );
                },
                child: const Text('Create tricount'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}