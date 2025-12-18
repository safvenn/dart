import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/admin/products/adminproductProvider.dart';
import 'package:crypto_app/ecommerce/admin/products/producservice.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class adminproductcontroll {
  final Ref ref;
  adminproductcontroll(this.ref);

  AdminProductservice get service => ref.watch(adminproductservice);

  Future<void> deleteproduct(Product product) async {
    await service.removeProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await service.updateProduct(product);
  }
  Future<void> addProduct(Product product) async {
    await service.addProduct(product);
  }
  Stream<QuerySnapshot> getallproducts() {
    return service.getproduct();
  }
}
