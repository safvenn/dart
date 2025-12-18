import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/admin/provider/alluserprovider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Usercontroll {
  final Ref ref;
  Usercontroll(this.ref);

  late final service = ref.watch(userservicesprovider);

  Future<void> deelete(String uid) async {
    await service.delete(uid);
  }

  Future<void> update(String uid, name, bool? isAdmin) async {
    await service.update(uid, name, isAdmin);
  }

  Stream<QuerySnapshot> getallusers() {
    return service.getAllUsers();
  }
}
