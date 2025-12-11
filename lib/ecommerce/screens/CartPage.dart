import 'package:crypto_app/ecommerce/provider/Cart_Provider.dart';
import 'package:crypto_app/ecommerce/provider/orderprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final uid = FirebaseAuth.instance.currentUser!.uid;

class Cartpage extends ConsumerWidget {
  const Cartpage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartitems = ref.watch(userCartProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF0f0f1e),
        child: cartitems.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final total = data.fold<double>(
              0,
              (sum, item) => sum + (item.price * item.qty),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (_, i) {
                      final item = data[i];
                      return _buildCartItem(context, ref, item);
                    },
                  ),
                ),
                // Summary & Checkout
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: data.isEmpty
                              ? null
                              : () async {
                                  final orderservice = ref.watch(
                                    orderserviceProvider,
                                  );
                                  try {
                                    await orderservice.createOrderFromCart(
                                      data,
                                    );
                                    if (context.mounted) {
                                      ref
                                          .read(cartcontrollprpovider)
                                          .clearcart(uid);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "orderplaced succesfully...!",
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'failede to place order:$e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $err',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                const SizedBox(height: 16),
                Text(
                  'Loading cart...',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[800],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, st) => Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0f0f1e),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () {
                            ref
                                .read(cartcontrollprpovider)
                                .decreaseFromCart(item);
                          },
                          icon: const Icon(
                            Icons.remove_rounded,
                            size: 16,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        Text(
                          '${item.qty}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () {
                            ref.read(cartcontrollprpovider).addCart(item);
                          },
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Color(0xFFFF6B6B),
                size: 22,
              ),
              onPressed: () {
                ref.read(cartcontrollprpovider).removeCartitem(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}
