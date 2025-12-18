import 'package:crypto_app/ecommerce/admin/provider/alluserprovider.dart';
// removed unused import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Users extends ConsumerWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: const Center(child: Text('No authenticated user')),
      );
    }

    final uid = currentUser.uid;
    final usersAsync = ref.watch(alluserprovider(uid));
    TextEditingController namecontroller = TextEditingController();
    final adminController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        data: (users) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.docs.length,
            itemBuilder: (context, index) {
              final user = users.docs[index];
              final data = (user.data() as Map<String, dynamic>?) ?? {};
              final name = data['name']?.toString() ?? 'No Name';
              final email = data['email']?.toString() ?? 'No Email';
              final isAdmin = data['isAdmin'] == true;
              return ListTile(
                title: Text(name),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(email), Text(isAdmin ? 'Admin' : 'User')],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // delete the selected user by their document id
                        ref.read(usercontrollProvider).deelete(user.id);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: () {
                        namecontroller.text = name;
                        adminController.text = isAdmin.toString();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Update User'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: namecontroller,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                  ),
                                ),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    String currentAdminVal =
                                        (adminController.text.toLowerCase() ==
                                            'true')
                                        ? 'true'
                                        : 'false';
                                    return Row(
                                      children: [
                                        const Text('Role:'),
                                        const SizedBox(width: 12),
                                        DropdownButton<String>(
                                          value: currentAdminVal,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'true',
                                              child: Text('Admin'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'false',
                                              child: Text('User'),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() {
                                              currentAdminVal = v;
                                              adminController.text = v;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final isAdmin =
                                      adminController.text.toLowerCase() ==
                                      'true';
                                  ref
                                      .read(usercontrollProvider)
                                      .update(
                                        user.id,
                                        namecontroller.text,
                                        isAdmin,
                                      );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(
          child: Text(
            'err:$err',
            style: const TextStyle(color: Colors.amberAccent),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
