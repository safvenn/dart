import 'package:crypto_app/ecommerce/screens/CartPage.dart';
import 'package:crypto_app/ecommerce/screens/home.dart';
import 'package:crypto_app/ecommerce/screens/orderpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

var NavProvider = StateProvider<int>((ref) => 0);

class Navbar extends ConsumerWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: [
        const Home(),
        const Cartpage(),
        const OrdersPage(),
      ][ref.watch(NavProvider)],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cartpage',
            selectedIcon: Icon(Icons.shopping_bag),
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping),
            label: 'OrdersPage',
            selectedIcon: Icon(Icons.local_shipping_outlined),
          ),
        ],
        selectedIndex: ref.watch(NavProvider),
        indicatorColor: Colors.deepPurple,
        onDestinationSelected: (index) {
          ref.read(NavProvider.notifier).state = index;
        },
      ),
    );
  }
}
