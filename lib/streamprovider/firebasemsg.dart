import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final measageProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance.collection("messages").snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) => doc.data()['text'] as String).toList();
  });
});

class Firebasse extends ConsumerWidget {
  const Firebasse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msg = ref.watch(measageProvider);
    return msg.when(
      data: (list)=> Center(
        child: ListView(
          children: list.map((text) => Center(child: Text(text,style: TextStyle(color: Colors.blue,inherit: false),))).toList()
        ),
      ),
      error: (err, stack) {
        return Center(child: Text('error$err',style: TextStyle(fontSize: 20),));
      },
      loading: ()=> Center(child: CircularProgressIndicator(padding: EdgeInsets.all(12),)),
    );
  }
}
