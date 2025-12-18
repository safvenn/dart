import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';

class Productservice {
  final productref = FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getproduct() async {
    final sanpshot = await productref.get();

    return sanpshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .toList();
  }
}
