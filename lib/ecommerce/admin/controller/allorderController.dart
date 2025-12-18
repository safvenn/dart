

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/admin/provider/allorderProvider.dart';

import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class AllorderController {
  final Ref ref;
  AllorderController(this.ref);

  late final service = ref.watch(allorderserviceProvider);

  Future<void> delete(OrderModel order) async {
    await service.delete(order);
  }

  Future<void> update( String id,Object value) async {
    await service.edit(id, value);
  }

  Stream<QuerySnapshot> allorders() {
    return service.allorders();
  }
}
