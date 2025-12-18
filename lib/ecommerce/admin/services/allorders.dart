import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/orders.dart';

class Allorders {
  final _db = FirebaseFirestore.instance.collection("orders");

  Stream<QuerySnapshot> allorders() {
    return _db.snapshots();
  }

  Future<void> delete(OrderModel order) async {
    await _db.doc(order.id).delete();
  }

  Future<void> edit(String id, Object value) async {
    await _db.doc(id).update({
      "status":value.toString(),
    });
  }
}
