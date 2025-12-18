import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/admin/controller/usercontroll.dart';
import 'package:crypto_app/ecommerce/admin/services/userservices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alluserprovider = StreamProvider.family<QuerySnapshot, String>((
  ref,
  uid,
) {
  return Usercontroll(ref).getallusers();
});

final userservicesprovider = Provider((ref) => Userservices());

final usercontrollProvider = Provider((ref) => Usercontroll(ref));
