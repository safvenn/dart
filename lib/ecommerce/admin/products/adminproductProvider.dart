import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/admin/products/producservice.dart';
import 'package:crypto_app/ecommerce/admin/products/productcontroller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
final adminproductservice = Provider((ref) => AdminProductservice());
final stramprodcts = StreamProvider<QuerySnapshot>((ref) {
  final service = ref.watch(adminproductservice);
  return service.getproduct();
});


final admincontrollProvider = Provider((ref) {
  return adminproductcontroll(ref);
});
