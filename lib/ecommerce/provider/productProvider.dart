
import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final productsProvider = FutureProvider<List<Product>>((ref) async {
  // corrected endpoint path: "products" (was misspelled as "prodcts")
  final res = await Dio().get("https://fakestoreapi.com/products");
  final List data = res.data as List;
  return data.map((e) => Product.fromJson(e)).toList();
});
