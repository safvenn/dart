import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:crypto_app/ecommerce/provider/orderprovider.dart';

// Analytics Model
class AnalyticsData {
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final double averageOrderValue;
  final int pendingOrders;
  final int completedOrders;
  final Map<String, double> monthlySales;
  final Map<String, int> orderStatusDistribution;

  AnalyticsData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.averageOrderValue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.monthlySales,
    required this.orderStatusDistribution,
  });
}

// Provider for analytics data
final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('orders').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList();
  });
});

final analyticsDataProvider = StreamProvider<AnalyticsData>((ref) async* {
  final orders = await ref.watch(allOrdersProvider.future);

  // Calculate metrics
  double totalRevenue = 0;
  Set<String> uniqueCustomers = {};
  int pendingOrders = 0;
  int completedOrders = 0;
  Map<String, double> monthlySales = {};
  Map<String, int> orderStatusDistribution = {};

  for (var order in orders) {
    totalRevenue += order.total;
    uniqueCustomers.add(order.userId);

    // Count by status
    orderStatusDistribution[order.status] =
        (orderStatusDistribution[order.status] ?? 0) + 1;

    if (order.status == 'pending') pendingOrders++;
    if (order.status == 'shipped') completedOrders++;

    // Group by month
    final monthKey =
        '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
    monthlySales[monthKey] = (monthlySales[monthKey] ?? 0) + order.total;
  }

  yield AnalyticsData(
    totalRevenue: totalRevenue,
    totalOrders: orders.length,
    totalCustomers: uniqueCustomers.length,
    averageOrderValue: orders.isEmpty ? 0 : totalRevenue / orders.length,
    pendingOrders: pendingOrders,
    completedOrders: completedOrders,
    monthlySales: monthlySales,
    orderStatusDistribution: orderStatusDistribution,
  );
});

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsyncValue = ref.watch(analyticsDataProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: analyticsAsyncValue.when(
        data: (analytics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Metrics Row 1
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Total Revenue',
                        value: '\$${analytics.totalRevenue.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Total Orders',
                        value: '${analytics.totalOrders}',
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Key Metrics Row 2
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Total Customers',
                        value: '${analytics.totalCustomers}',
                        icon: Icons.people,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Avg Order Value',
                        value:
                            '\$${analytics.averageOrderValue.toStringAsFixed(2)}',
                        icon: Icons.calculate,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Order Status Section
                const SizedBox(height: 20),
                const Text(
                  'Order Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatusCard(
                        status: 'Pending',
                        count: analytics.pendingOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.pendingOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusCard(
                        status: 'Shipped',
                        count: analytics.completedOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.completedOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusCard(
                        status: 'Other',
                        count:
                            analytics.totalOrders -
                            analytics.pendingOrders -
                            analytics.completedOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : ((analytics.totalOrders -
                                      analytics.pendingOrders -
                                      analytics.completedOrders) /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Monthly Sales Chart Section
                if (analytics.monthlySales.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Sales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: analytics.monthlySales.entries.map((
                              entry,
                            ) {
                              final maxRevenue = analytics.monthlySales.values
                                  .reduce((a, b) => a > b ? a : b);
                              final percentage =
                                  (entry.value / maxRevenue) * 100;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage / 100,
                                          minHeight: 20,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.blue[400]!,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        '\$${entry.value.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Metric Card Widget
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Status Card Widget
class StatusCard extends StatelessWidget {
  final String status;
  final int count;
  final double percentage;
  final Color color;

  const StatusCard({
    Key? key,
    required this.status,
    required this.count,
    required this.percentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getStatusIcon(status), color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
