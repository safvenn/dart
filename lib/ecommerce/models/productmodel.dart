class Product {
  final String id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String description;
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
  });
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      title: (map['title'] ?? '') as String,
      price: (map['price'] ?? 0.0) as double,
      image: (map['image'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      description: (map['description'] ?? map['discription'] ?? '') as String,
    );
  }
}
