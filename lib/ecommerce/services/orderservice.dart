import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/cartmodel.dart';
import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Create a new order from current cart items.
  Future<void> createOrderFromCart(List<CartItem> cartItems) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Convert cart items to OrderItem
    final orderItems = cartItems
        .map(
          (c) => OrderItem(
            productId: c.productId,
            title: c.title,
            price: c.price,
            qty: c.qty,
          ),
        )
        .toList();

    final total = orderItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.qty,
    );
    final orderdoc = _firestore.collection("orders").doc();

    final orders = OrderModel(
      id: orderdoc.id,
      userId: user.uid,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
      items: orderItems,
    );

    await orderdoc.set(orders.toMap());
  }

  Stream<List<OrderModel>> userOrderStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<OrderModel>>.empty();
    }
    return _firestore
        .collection("orders")
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList());
  }
}
