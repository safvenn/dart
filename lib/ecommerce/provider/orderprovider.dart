import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:crypto_app/ecommerce/services/orderservice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderserviceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final userOrderProvider = StreamProvider<List<OrderModel>>((ref) {
  final service = ref.watch(orderserviceProvider);
  return service.userOrderStream();
});
