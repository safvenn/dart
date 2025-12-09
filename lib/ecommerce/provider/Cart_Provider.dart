import 'package:crypto_app/ecommerce/models/cartmodel.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:crypto_app/ecommerce/services/cartcontroller.dart';
import 'package:crypto_app/ecommerce/services/userCartservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final cartserviceProvider = Provider((ref) => CartRepository());
final cartcontrollprpovider = Provider((ref) {
  return Cartcontroller(ref);
});
final userCartProvider = StreamProvider<List<CartItem>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  final service = ref.watch(cartserviceProvider);
  return service.watchCart(user.uid);
});
