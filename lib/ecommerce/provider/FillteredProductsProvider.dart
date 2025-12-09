import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:crypto_app/ecommerce/provider/CatogoryProvider.dart';
import 'package:crypto_app/ecommerce/provider/productProvider.dart';
import 'package:crypto_app/ecommerce/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(searchprovider).toLowerCase();
  final productasync = ref.watch(productsProvider);
  final selectedcatogory = ref.watch(selectedcatogoryProvider);

  return productasync.when(
    data: (list) {
      var filterd = list;
      if (selectedcatogory != null && selectedcatogory.isNotEmpty) {
        filterd = filterd.where((p) => p.category == selectedcatogory).toList();
      }
      if (query.isNotEmpty) {
        filterd = filterd
            .where((p) => p.title.toLowerCase().contains(query))
            .toList();
      }
      return filterd;
    },
    error: (_, __) => [],
    loading: () => selectedcatogory == null ? [] : [],
  );
});
