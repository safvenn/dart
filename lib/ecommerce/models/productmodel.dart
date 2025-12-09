class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String description;
  Product(this.id, this.title, this.price, this.image, this.category,this.description);
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json["id"],
      json["title"],
      (json["price"] as num).toDouble(),
      json["image"],
      (json["category"] as String?) ?? "uncatogorized",
      json["description"]
    );
  }
}
