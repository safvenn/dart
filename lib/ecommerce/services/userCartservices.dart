import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/cartmodel.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';

class CartRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference getCartRef(String uid) =>
      _db.collection("users").doc(uid).collection("cartItems");

  Future<void> addToCart(String uid, CartItem product) async {
    final ref = getCartRef(uid).doc(product.productId.toString());
    final data = product.toMap();
    data['qty'] = FieldValue.increment(1);
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> removeCart(String uid, CartItem product) async {
    final ref = getCartRef(uid).doc(product.productId.toString());
    final data = product.toMap();
    final currentqty = data['qty'];
    if (currentqty > 1) {
      await ref.update({'qty': FieldValue.increment(-1)});
    } else {
      await ref.delete();
    }
  }

  Future<void> removecartitem(String uid, CartItem product) async {
    await getCartRef(uid).doc(product.productId).delete();
  }

  Stream<List<CartItem>> watchCart(String uid) {
    return getCartRef(uid).snapshots().map((snap) {
      return snap.docs
          .map((d) => CartItem.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
