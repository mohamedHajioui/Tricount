
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/auth_service.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';
import 'package:prbd_2425_a07/models/depense.dart';
import 'package:prbd_2425_a07/models/repartition.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/providers/auth_service_provider.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';
import 'package:prbd_2425_a07/providers/get_current_user.dart';
import 'package:prbd_2425_a07/providers/savetricount_provider.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import 'package:prbd_2425_a07/providers/users_provider.dart';

class AddTricountPage extends ConsumerStatefulWidget {
  final int tricountId;

  const AddTricountPage({required this.tricountId, Key? key}) : super(key: key);
  
  @override
  ConsumerState<AddTricountPage> createState() => _AddTricountPageState();
}

class _AddTricountPageState extends ConsumerState<AddTricountPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
   List<User> addedUsers = [];
   List<User> unremovable_users = [];
  User? selectedUser;
  String? titleError;
  String? descError;
  
  
  Tricount tricount(){
    final int tricountId = widget.tricountId;
    debugPrint("input : $tricountId");
    final current_user = ref.read(authUserProvider).value;
    final tricount_state = ref.read(currentTricountProvider);
    
    Tricount tricount = new Tricount(id: 0, title: "", dateHour: null, creator: current_user!.id, participants: [], depenses: []);
    
    if(tricountId != 0) {
      
      tricount = tricount_state.tricount??new Tricount(id: 0, title: "", dateHour: null, creator: current_user!.id, participants: [], depenses: []);
    }

    
    return tricount;
  }
  
  void refresh_elements(){
    final tricountListNotifier = ref.read(tricountnotifyer.notifier);
    final tricount_state = ref.read(currentTricountProvider);


    tricountListNotifier.refreshTriCountList();
    tricount_state.refresh();
  }




  @override
  void initState() {
    super.initState();
    

    titleController.addListener(validateInputs);
    descController.addListener(validateInputs);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tricount_state = ref.read(currentTricountProvider);
      final c_tricount = tricount();

      

      if (c_tricount != null) {
        titleController.text = c_tricount.title;
        descController.text = c_tricount.description ?? '';
        setState(() {
          addedUsers = c_tricount.participants;
        });
      }

      final loggedUser = ref.read(logged_usernotifyer).asData?.value;
      debugPrint("lslsl ${c_tricount!.id}");
      if(c_tricount!.id == 0) {
        debugPrint("lslsllslslsllsls");
        if (loggedUser != null && !addedUsers.contains(loggedUser)) {
          setState(() {
            addedUsers.add(loggedUser);
          });
        }
      }
      
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> validateInputs() async {
    // on recupere les donnes importantes
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    final currentid = tricount().id;
    
    final errors = await Tricount.validateInputs(title, desc, currentid, ref);

    setState(() {
      titleError = errors['title'];
      descError = errors['description'];
    });
  }


  @override
  Widget build(BuildContext context) {
    
    
    final c_tricount = tricount();
    final isEditing = widget.tricountId != 0;
    final unremovable = c_tricount.unremovable_list_const();
    

    final usersListAsync = ref.watch(users_listnotifyer);
    final currentUserAsync = ref.watch(logged_usernotifyer);

    return currentUserAsync.when(
      data: (loggedUser) {
        if (loggedUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(isEditing ? "Edit Tricount" : "Add Tricount",
                style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            )),
            actions: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: () async {
                  await validateInputs();
                  if (titleError == null && descError == null) {
                    debugPrint('tricountid : ${c_tricount.id}');
                    c_tricount.title = titleController.text.trim();
                    c_tricount.description = descController.text.trim();
                    c_tricount.participants = addedUsers;

                    final notifier = ref.read(saveTricountNotifierProvider.notifier);

                    try {
                      await notifier.save(c_tricount);
                      refresh_elements();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tricount saved successfully')),
                        );
                        Navigator.pop(context); // Or navigate to the list page
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save: $e')),
                        );
                      }
                    }
                  }
                },

              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title input + validation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (titleError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          titleError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description input + validation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (descError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          descError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Participants",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Participant list
                ...addedUsers.map((user) {
                  final isLoggedUser = loggedUser.id == user.id;
                  return ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: isLoggedUser || unremovable.contains(user.id)
                        ? null
                        : IconButton(
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

                // Dropdown to add new participant
                usersListAsync.when(
                  data: (allUsers) {
                    final availableUsers = allUsers.where((u) => !addedUsers.contains(u) && u.id != loggedUser.id).toList();
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
