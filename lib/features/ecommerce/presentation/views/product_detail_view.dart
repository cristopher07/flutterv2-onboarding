import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ecommerce_provider.dart';

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(ecommerceProductsProvider);
    final product = products.firstWhere((product) => product.id == productId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goNamed('ecommerce-home'),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: () => context.goNamed('ecommerce-cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240,
              width: double.infinity,
              color: const Color(0xFFEAF2FF),
              child: const Icon(Icons.image_outlined, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('EUR ${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Text(product.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(ecommerceControllerProvider.notifier)
                      .addToCart(product);
                  context.goNamed('ecommerce-cart');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to bag'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
