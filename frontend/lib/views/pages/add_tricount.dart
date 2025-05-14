import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/providers/users_provider.dart';

class AddTricountPage extends ConsumerWidget {
  static const routeName = '/addtricount';
  const AddTricountPage({super.key});
  

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final userslist = ref.watch(users_listnotifyer);
    List<User> added_users = [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add Tricount"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // save action
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description with validation
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 4),

            // Participants
            Text(
              "Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Geoffrey", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.person_remove_alt_1),
            ),

            // Dropdown + Add
            userslist.when(
              data: (allUsers) {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<User>(
                        hint: Text("Add a new participant"),
                        items: (allUsers??[]).map((user) {
                          return DropdownMenuItem<User>(
                            value: user,
                            child: Text(user.fullName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          // You can use val here
                          print('Selected: ${val?.fullName}');
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add_alt),
                      onPressed: () {
                        // Add action
                      },
                    ),
                  ],
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading users: $err'),
            )],
        ),
      ),
    );
  }
}
