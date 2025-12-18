

import 'package:crypto_app/ecommerce/admin/controller/allorderController.dart';
import 'package:crypto_app/ecommerce/admin/services/allorders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allorderserviceProvider = Provider<Allorders>((ref) {
  return Allorders();
});

final allorderController = Provider((ref) {
  return AllorderController(ref);
});

final allorderProvider = StreamProvider((ref) {
  final controller = ref.watch(allorderController);
  return controller.allorders();
});