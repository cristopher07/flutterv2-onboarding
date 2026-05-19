import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ecommerce_provider.dart';

class CheckoutPaymentView extends ConsumerWidget {
  const CheckoutPaymentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(ecommercePaymentMethodsProvider);
    final state = ref.watch(ecommerceControllerProvider);
    final controller = ref.read(ecommerceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.goNamed('ecommerce-cart'),
          child: const Text('Cancel'),
        ),
        leadingWidth: 96,
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose a payment method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final method in methods)
            ListTile(
              leading: Icon(
                state.selectedPaymentMethodId == method.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(method.brand),
              subtitle: Text('xxxx xxxx xxxx ${method.lastDigits}'),
              onTap: () => controller.selectPaymentMethod(method.id),
            ),
          CheckboxListTile(
            value: state.billingSameAsShipping,
            onChanged: (value) {
              if (value == null) return;
              controller.setBillingSameAsShipping(value);
            },
            title: const Text(
              'My billing address is the same as my shipping address',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Continue')),
        ],
      ),
    );
  }
}
