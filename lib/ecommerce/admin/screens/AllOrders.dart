import 'package:crypto_app/ecommerce/admin/provider/allorderProvider.dart';
import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAllorders extends ConsumerWidget {
  const AdminAllorders({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderasync = ref.watch(allorderProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        elevation: 0,
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      body: orderasync.when(
        data: (doc) {
          final daata = doc.docs;
          if (daata.isEmpty) {
            return const Center(
              child: Text(
                'No orders available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daata.length,
            itemBuilder: (context, index) {
              final order = daata[index];
              final status = order['status'] ?? 'pending';
              final statusColor = _getStatusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      status.toLowerCase() == 'pending'
                          ? Icons.hourglass_top
                          : status.toLowerCase() == 'shipped'
                          ? Icons.local_shipping
                          : Icons.check_circle,
                      color: statusColor,
                    ),
                  ),
                  title: Text(
                    'Order ID: ${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$${order['total'] ?? 0.0}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          _showStatusDialog(context, ref, order, status);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      ref.read(allorderController).delete(OrderModel.fromDoc( order));
                    },
                    icon: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic order,
    String currentStatus,
  ) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF16213e),
          title: const Text(
            'Update Order Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            dropdownColor: const Color(0xFF0f0f1e),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0f0f1e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                ref.read(allorderController).update( order.id, selectedStatus);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
