import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ecommerce_bottom_nav_bar.dart';
import '../providers/ecommerce_provider.dart';

class EcommerceHomeView extends ConsumerWidget {
  const EcommerceHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(ecommerceProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce'),
        actions: [
          IconButton(
            onPressed: () => context.goNamed('ecommerce-cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
        bottomNavigationBar: EcommerceBottomNavBar(
        currentIndex: 0,
        onItemSelected: (index) {
          if (index == 0) return;
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Perfect for you',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final product in products)
            Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text('EUR ${product.price.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    () => context.goNamed(
                      'ecommerce-product-detail',
                      pathParameters: {'productId': product.id},
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
