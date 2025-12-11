// lib/ui/orders_page.dart
import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:crypto_app/ecommerce/provider/orderprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} '
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    final itemsPreview = order.items.take(2).map((e) => e.title).join(', ');
    final extraCount = order.items.length - 2;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Date: $dateStr'),
            const SizedBox(height: 4),
            Text('Status: ${order.status}', style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 4),
            Text('Total: \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Items: ${itemsPreview}${extraCount > 0 ? " +$extraCount more" : ""}'),
          ],
        ),
      ),
    );
  }
}
