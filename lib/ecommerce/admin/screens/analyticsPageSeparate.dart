import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/ecommerce/models/orders.dart';
import 'package:crypto_app/ecommerce/provider/orderprovider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Analytics Model for Admin
class AdminAnalyticsData {
  final double totalRevenue;
  final int totalOrders;
  final int totalUsers;
  final double averageOrderValue;
  final int pendingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final Map<String, double> monthlySales;
  final Map<String, int> orderStatusDistribution;

  AdminAnalyticsData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalUsers,
    required this.averageOrderValue,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.monthlySales,
    required this.orderStatusDistribution,
  });
}

// Analytics Model for User
class UserAnalyticsData {
  final double totalSpent;
  final int totalOrders;
  final int pendingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final List<Map<String, dynamic>> recentOrders;

  UserAnalyticsData({
    required this.totalSpent,
    required this.totalOrders,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.recentOrders,
  });
}

// Provider for all orders (Admin only)
final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('orders').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList();
  });
});

// Provider for admin analytics
final adminAnalyticsProvider = StreamProvider<AdminAnalyticsData>((ref) async* {
  final orders = await ref.watch(allOrdersProvider.future);

  double totalRevenue = 0;
  Set<String> uniqueUsers = {};
  int pendingOrders = 0;
  int shippedOrders = 0;
  int deliveredOrders = 0;
  Map<String, double> monthlySales = {};
  Map<String, int> orderStatusDistribution = {};

  for (var order in orders) {
    totalRevenue += order.total;
    uniqueUsers.add(order.userId);

    orderStatusDistribution[order.status] =
        (orderStatusDistribution[order.status] ?? 0) + 1;

    if (order.status == 'pending') pendingOrders++;
    if (order.status == 'shipped') shippedOrders++;
    if (order.status == 'delivered') deliveredOrders++;

    final monthKey =
        '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
    monthlySales[monthKey] = (monthlySales[monthKey] ?? 0) + order.total;
  }

  yield AdminAnalyticsData(
    totalRevenue: totalRevenue,
    totalOrders: orders.length,
    totalUsers: uniqueUsers.length,
    averageOrderValue: orders.isEmpty ? 0 : totalRevenue / orders.length,
    pendingOrders: pendingOrders,
    shippedOrders: shippedOrders,
    deliveredOrders: deliveredOrders,
    monthlySales: monthlySales,
    orderStatusDistribution: orderStatusDistribution,
  );
});

// Provider for user analytics
final userAnalyticsProvider = StreamProvider<UserAnalyticsData>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield UserAnalyticsData(
      totalSpent: 0,
      totalOrders: 0,
      pendingOrders: 0,
      shippedOrders: 0,
      deliveredOrders: 0,
      recentOrders: [],
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .get();

  final docs = snapshot.docs;
  double totalSpent = 0;
  int pendingOrders = 0;
  int shippedOrders = 0;
  int deliveredOrders = 0;
  List<Map<String, dynamic>> recentOrders = [];

  for (var doc in docs) {
    final data = doc.data();
    totalSpent += (data['total'] as num?)?.toDouble() ?? 0;
    final status = data['status'] ?? 'pending';

    if (status == 'pending') pendingOrders++;
    if (status == 'shipped') shippedOrders++;
    if (status == 'delivered') deliveredOrders++;

    recentOrders.add({
      'id': doc.id,
      'total': data['total'],
      'status': status,
      'date': data['createdAt'],
    });
  }

  // Sort by date descending
  recentOrders.sort(
    (a, b) => (b['date'] as Timestamp).compareTo(a['date'] as Timestamp),
  );

  yield UserAnalyticsData(
    totalSpent: totalSpent,
    totalOrders: docs.length,
    pendingOrders: pendingOrders,
    shippedOrders: shippedOrders,
    deliveredOrders: deliveredOrders,
    recentOrders: recentOrders.take(5).toList(), // Recent 5 orders
  );
});

// Admin Analytics Page
class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsyncValue = ref.watch(adminAnalyticsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Analytics Dashboard'),
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
                        title: 'Total Users',
                        value: '${analytics.totalUsers}',
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
                const Text(
                  'Order Status Distribution',
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
                        count: analytics.shippedOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.shippedOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusCard(
                        status: 'Delivered',
                        count: analytics.deliveredOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.deliveredOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.green,
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
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '\$${entry.value.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.green.shade400,
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

// User Analytics Page
class UserAnalyticsPage extends ConsumerWidget {
  const UserAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsyncValue = ref.watch(userAnalyticsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders Analytics'),
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
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Total Spent',
                        value: '\$${analytics.totalSpent.toStringAsFixed(2)}',
                        icon: Icons.wallet,
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
                const SizedBox(height: 20),

                // Order Status Summary
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
                        count: analytics.shippedOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.shippedOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusCard(
                        status: 'Delivered',
                        count: analytics.deliveredOrders,
                        percentage: analytics.totalOrders == 0
                            ? 0
                            : (analytics.deliveredOrders /
                                  analytics.totalOrders *
                                  100),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Orders
                if (analytics.recentOrders.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: analytics.recentOrders.length,
                        itemBuilder: (context, index) {
                          final order = analytics.recentOrders[index];
                          final status = order['status'] as String;
                          final statusColor = _getStatusColor(status);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Order ID: ${order['id']}'),
                              subtitle: Text(
                                'Total: \$${(order['total'] as num).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
