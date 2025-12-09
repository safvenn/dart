


class CartItem {
  final String productId;
  final String title;
  final double price;
  final String image;
  final int qty;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'qty': qty,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      qty: (map['qty'] as num).toInt(),
    );
  }
}
