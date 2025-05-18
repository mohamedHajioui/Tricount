import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/auth_service.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/providers/get_current_user.dart';
import 'package:prbd_2425_a07/providers/users_provider.dart';

class AddTricountPage extends ConsumerStatefulWidget {
  static const routeName = '/addtricount';
  const AddTricountPage({super.key});

  @override
  ConsumerState<AddTricountPage> createState() => _AddTricountPageState();
}

class _AddTricountPageState extends ConsumerState<AddTricountPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final List<User> addedUsers = [];
  User? selectedUser;
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    final usersListAsync = ref.watch(users_listnotifyer);
    final currentUserAsync = ref.watch(logged_usernotifyer);

    return currentUserAsync.when(
      data: (loggedUser) {
        if (!initialized && loggedUser != null && !addedUsers.contains(loggedUser)) {
          addedUsers.add(loggedUser);
          initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Add Tricount"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  // save action
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Participants",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...addedUsers.map((user) {
                  return ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_alt_1),
                      onPressed: () {
                        setState(() {
                          addedUsers.remove(user);
                        });
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                usersListAsync.when(
                  data: (allUsers) {
                    final availableUsers = allUsers.where((u) => !addedUsers.contains(u)).toList();
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<User>(
                            hint: const Text("Add a new participant"),
                            value: selectedUser,
                            items: availableUsers.map((u) {
                              return DropdownMenuItem<User>(
                                value: u,
                                child: Text(u.fullName),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedUser = val;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add_alt),
                          onPressed: () {
                            if (selectedUser != null && !addedUsers.contains(selectedUser)) {
                              setState(() {
                                addedUsers.add(selectedUser!);
                                selectedUser = null;
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading users: $err'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
