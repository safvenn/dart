import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:crypto_app/ecommerce/services/productservice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  // corrected endpoint path: "products" (was misspelled as "prodcts")

  return Productservice().getproduct();
});
