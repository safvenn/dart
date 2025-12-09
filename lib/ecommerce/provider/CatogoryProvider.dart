import 'package:crypto_app/ecommerce/provider/productProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final categoriesProvider = Provider<List<String>>((ref) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    data: (list) {
      final set = <String>{};
      for (final p in list) set.add(p.category);
      final categories = set.toList()..sort();
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});


final selectedcatogoryProvider = StateProvider<String?>((ref) => null);
