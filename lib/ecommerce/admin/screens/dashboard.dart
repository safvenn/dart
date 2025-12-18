import 'package:crypto_app/ecommerce/admin/screens/AllOrders.dart';
import 'package:crypto_app/ecommerce/admin/screens/adminproduct.dart';
import 'package:crypto_app/ecommerce/admin/screens/users.dart';
import 'package:crypto_app/ecommerce/admin/services/allorders.dart';
import 'package:crypto_app/notifier/login/login.dart';
import 'package:crypto_app/notifier/login/register.dart' hide authProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_app/ecommerce/models/navbar.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final isAdmin = auth.isAdmin ?? false;
    if (isAdmin != true) {
      return const Scaffold(
        body: Center(child: Text('Access Denied: Admins Only')),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),

        actions: [
          IconButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            icon: Icon(Icons.logout_rounded),
          ),
          IconButton(
            tooltip: 'Open user view',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const Navbar()));
            },
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Overview', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _adminCard(
                      context,
                      label: 'Users',
                      subtitle: 'Manage users and roles',
                      icon: Icons.person_outline,
                      color: Colors.indigo,
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const Users())),
                    ),
                    _adminCard(
                      context,
                      label: 'Products',
                      subtitle: 'Add / Edit products',
                      icon: Icons.inventory_2_outlined,
                      color: Colors.teal,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const Adminproduct()),
                      ),
                    ),
                    _adminCard(
                      context,
                      label: 'Orders',
                      subtitle: 'Recent orders',
                      icon: Icons.receipt_long,
                      color: Colors.deepOrange,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAllorders())),
                    ),
                    _adminCard(
                      context,
                      label: 'Analytics',
                      subtitle: 'Sales & traffic',
                      icon: Icons.show_chart,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _adminCard(
  BuildContext context, {
  required String label,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  return Material(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,

              children: [Icon(Icons.chevron_right, color: theme.hintColor)],
            ),
          ],
        ),
      ),
    ),
  );
}
