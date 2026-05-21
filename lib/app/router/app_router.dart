import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/ecommerce/presentation/views/cart_view.dart';
import '../../features/ecommerce/presentation/views/checkout_payment_view.dart';
import '../../features/ecommerce/presentation/views/ecommerce_home_view.dart';
import '../../features/ecommerce/presentation/views/product_detail_view.dart';
// import '../../features/onboarding/presentation/views/onboarding_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // GoRoute(
      //   path: '/',
      //   name: 'onboarding',
      //   builder: (context, state) => const OnboardingView(),
      // ),
      GoRoute(
        path: '/', 
        redirect: (context, state) => '/ecommerce'
      ),
      GoRoute(
        path: '/ecommerce',
        name: 'ecommerce-home',
        builder: (context, state) => const EcommerceHomeView(),
      ),
      GoRoute(
        path: '/ecommerce/product/:productId',
        name: 'ecommerce-product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailView(productId: productId);
        },
      ),
      GoRoute(
        path: '/ecommerce/cart',
        name: 'ecommerce-cart',
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: '/ecommerce/checkout/payment',
        name: 'ecommerce-checkout-payment',
        builder: (context, state) => const CheckoutPaymentView(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
        ),
  );
});
