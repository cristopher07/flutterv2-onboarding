import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/payment_method.dart';
import '../providers/ecommerce_provider.dart';

class CheckoutPaymentView extends ConsumerWidget {
  const CheckoutPaymentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(ecommercePaymentMethodsProvider);
    final state = ref.watch(ecommerceControllerProvider);
    final controller = ref.read(ecommerceControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 72,
        leading: TextButton(
          onPressed: () => context.goNamed('ecommerce-cart'),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF067DF7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            const _CheckoutSteps(),
            const SizedBox(height: 36),
            const Text(
              'Choose a payment method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You won’t be charged until you review the order on the next page',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF8A94A6),
              ),
            ),
            const SizedBox(height: 22),
            _CreditCardPanel(
              methods: methods,
              selectedPaymentMethodId: state.selectedPaymentMethodId,
              billingSameAsShipping: state.billingSameAsShipping,
              onSelectMethod: controller.selectPaymentMethod,
              onBillingChanged: controller.setBillingSameAsShipping,
            ),
            const SizedBox(height: 16),
            _ApplePayTile(
              selected: state.selectedPaymentMethodId == 'apple_pay',
              onTap: () => controller.selectPaymentMethod('apple_pay'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed:
                    state.isProcessingPayment
                        ? null
                        : () => controller.processSelectedPayment(methods),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF067DF7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    state.isProcessingPayment
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Pay now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            if (state.paymentResult != null || state.paymentError != null) ...[
              const SizedBox(height: 14),
              _PaymentStatusPanel(
                success: state.paymentResult?.success ?? false,
                title:
                    state.paymentResult?.success == true
                        ? 'Payment approved'
                        : 'Payment not completed',
                message: state.paymentResult?.message ?? state.paymentError!,
                transactionId: state.paymentResult?.transactionId,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusPanel extends StatelessWidget {
  const _PaymentStatusPanel({
    required this.success,
    required this.title,
    required this.message,
    this.transactionId,
  });

  final bool success;
  final String title;
  final String message;
  final String? transactionId;

  @override
  Widget build(BuildContext context) {
    final color = success ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFEFFBF3) : const Color(0xFFFEF2F2),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (transactionId != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    transactionId!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSteps extends StatelessWidget {
  const _CheckoutSteps();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StepItem(
          label: 'Your bag',
          icon: Icons.check,
          active: true,
          completed: true,
        ),
        _StepItem(
          label: 'Shipping',
          icon: Icons.check,
          active: true,
          completed: true,
        ),
        _StepItem(label: 'Payment', text: '3', active: true),
        _StepItem(label: 'Review', text: '4'),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.label,
    this.icon,
    this.text,
    this.active = false,
    this.completed = false,
  });

  final String label;
  final IconData? icon;
  final String? text;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final circleColor =
        completed
            ? const Color(0xFFDCEEFF)
            : active
            ? const Color(0xFF067DF7)
            : const Color(0xFFF0F2F7);

    final contentColor =
        completed
            ? const Color(0xFF067DF7)
            : active
            ? Colors.white
            : const Color(0xFFB6BECF);

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child:
              icon != null
                  ? Icon(icon, size: 14, color: contentColor)
                  : Text(
                    text ?? '',
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color:
                active || completed
                    ? const Color(0xFF111827)
                    : const Color(0xFF8A94A6),
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CreditCardPanel extends StatelessWidget {
  const _CreditCardPanel({
    required this.methods,
    required this.selectedPaymentMethodId,
    required this.billingSameAsShipping,
    required this.onSelectMethod,
    required this.onBillingChanged,
  });

  final List<PaymentMethod> methods;
  final String selectedPaymentMethodId;
  final bool billingSameAsShipping;
  final ValueChanged<String> onSelectMethod;
  final ValueChanged<bool> onBillingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 20,
                color: Color(0xFF067DF7),
              ),
              SizedBox(width: 8),
              Text(
                'Credit Card',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final method in methods) ...[
            _PaymentMethodTile(
              brand: method.brand,
              lastDigits: method.lastDigits,
              selected: selectedPaymentMethodId == method.id,
              onTap: () => onSelectMethod(method.id),
            ),
            if (method != methods.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Add new card',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF067DF7),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => onBillingChanged(!billingSameAsShipping),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Checkbox(
                  value: billingSameAsShipping,
                  onChanged: (value) {
                    if (value != null) onBillingChanged(value);
                  },
                  activeColor: const Color(0xFF067DF7),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Expanded(
                  child: Text(
                    'My billing address is the same as my shipping address',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.brand,
    required this.lastDigits,
    required this.selected,
    required this.onTap,
  });

  final String brand;
  final String lastDigits;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF2FF) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFE5E8F0),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'xxxx xxxx xxxx $lastDigits',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: Color(0xFF067DF7)),
          ],
        ),
      ),
    );
  }
}

class _ApplePayTile extends StatelessWidget {
  const _ApplePayTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color:
                  selected ? const Color(0xFF067DF7) : const Color(0xFFCBD2E1),
            ),
            const SizedBox(width: 8),
            const Text(
              'Apple Pay',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
