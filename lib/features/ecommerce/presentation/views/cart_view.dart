import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ecommerce_provider.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ecommerceControllerProvider);
    final controller = ref.read(ecommerceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your bag'),
        leading: IconButton(
          onPressed: () => context.goNamed('ecommerce-home'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: state.cartItems.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final item = state.cartItems[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              () => controller.updateQuantity(
                                item.product.id,
                                item.quantity - 1,
                              ),
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed:
                              () => controller.updateQuantity(
                                item.product.id,
                                item.quantity + 1,
                              ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                const Text('Total'),
                const Spacer(),
                Text('EUR ${state.total.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              
              child: FilledButton(
                onPressed:
                    state.cartItems.isEmpty
                        ? null
                        : () => context.goNamed('ecommerce-checkout-payment'),
                 style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF067DF7),
                  foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                ),
                child: const Text('Checkout'),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
