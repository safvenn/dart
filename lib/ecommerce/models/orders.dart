// lib/models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final int qty;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'qty': qty,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      title: map['title'] ?? '',
      price: (map['price'] as num).toDouble(),
      qty: (map['qty'] as num).toInt(),
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    final itemsList = (map['items'] as List? ?? [])
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return OrderModel(
      id: doc.id,
      userId: map['userId'] ?? '',
      total: (map['total'] as num).toDouble(),
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: itemsList,
    );
  }
}
