import 'package:crypto_app/ecommerce/models/cartmodel.dart';

import 'package:crypto_app/ecommerce/provider/Cart_Provider.dart';
import 'package:crypto_app/ecommerce/services/userCartservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Cartcontroller {
  final Ref ref;
  Cartcontroller(this.ref);

  CartRepository get service => ref.read(cartserviceProvider);
  String get uid => FirebaseAuth.instance.currentUser!.uid;
  Future<void> addCart(CartItem product) async {
    await service.addToCart(uid, product);
  }

  Future<void> decreaseFromCart(CartItem productId) async {
    await service.removeCart(uid, productId);
  }

  Future<void> removeCartitem(CartItem product) async {
    await service.removecartitem(uid, product);
  }

  Future<void> clearcart(String uid) async {
    await service.clearCart(uid);
  }
}
