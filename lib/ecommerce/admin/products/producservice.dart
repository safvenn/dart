import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';

class AdminProductservice {
  final productref = FirebaseFirestore.instance.collection('products');

  Stream<QuerySnapshot> getproduct()  {
    return productref.snapshots();
  }

  Future<void> removeProduct(Product product) async {
    return await productref.doc(product.id).delete();
  }

  Future<void> updateProduct(Product product) async {
    return await productref.doc(product.id).update({
      "title": product.title,
      "category": product.category,
      "price": product.price,
      "image": product.image,
      "discription": product.description,
    });
  }

  Future<void> addProduct(Product product) async {
    final docref = productref.doc();
    final newproduct = Product(
      id: docref.id,
      title: product.title,
      category: product.category,
      price: product.price,
      image: product.image,
      description: product.description,
    );
    return await docref.set({
      "title": newproduct.title,
      "category": newproduct.category,
      "price": newproduct.price,
      "image": newproduct.image,
      "discription": newproduct.description,
    });
  }
}
