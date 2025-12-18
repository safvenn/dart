import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Userservices {
  final _db = FirebaseFirestore.instance.collection("users");
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> delete(String uid) async {
    await _db.doc(uid).delete();
  }

  Future<void> update(String uid, name, bool? isAdmin) async {
    await _db.doc(uid).update({
      "name": name,
      "isAdmin":isAdmin
    });
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _db.snapshots();
  }
}
