import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import 'ecommerce_bottom_nav_bar.dart';
import '../providers/ecommerce_provider.dart';

const _primaryColor = Color(0xFF067DF7);
const _textColor = Color(0xFF202124);
const _imageBackgroundColor = Color(0xFFEAF2FF);
const _surfaceColor = Color(0xFFF8F9FD);

class EcommerceHomeView extends ConsumerWidget {
  const EcommerceHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(ecommerceProductsProvider);
    final cartItems = ref.watch(
      ecommerceControllerProvider.select((state) => state.cartItems),
    );
    final cartQuantity = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final perfectProducts =
        products
            .where((product) => product.category == 'Perfect for you')
            .toList();
    final summerProducts =
        products
            .where((product) => product.category == 'For this summer')
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: EcommerceBottomNavBar(
        currentIndex: 0,
        onItemSelected: (index) {
          if (index == 0) return;
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HomeHeader(
              cartQuantity: cartQuantity,
              onCartTap: () => context.goNamed('ecommerce-cart'),
            ),
            const _HeroCarousel(),
            const SizedBox(height: 26),
            _ProductSection(
              title: 'Perfect for you',
              products: perfectProducts,
            ),
            const SizedBox(height: 28),
            _ProductSection(title: 'For this summer', products: summerProducts),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.cartQuantity, required this.onCartTap});

  final int cartQuantity;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 18, 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '9:41',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _textColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              const Icon(Icons.signal_cellular_4_bar, size: 15),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, size: 15),
              const SizedBox(width: 4),
              const Icon(Icons.battery_full, size: 17),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 38, minWidth: 38),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border, size: 29),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 38, minWidth: 38),
              ),
              const SizedBox(width: 8),
              _CartIconButton(quantity: cartQuantity, onTap: onCartTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.quantity, required this.onTap});

  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(child: Icon(Icons.shopping_bag_outlined, size: 28)),
            Positioned(
              right: -1,
              bottom: 3,
              child: Container(
                width: 19,
                height: 19,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      color: _imageBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, color: Color(0xFF9ED0FF), size: 36),
          SizedBox(height: 76),
          _PageDots(),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isActive = index == 1;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? _primaryColor : const Color(0xFFD5DAE3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.title, required this.products});

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: _primaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(64, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See more',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => context.goNamed(
              'ecommerce-product-detail',
              pathParameters: {'productId': product.id},
            ),
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 104,
                width: double.infinity,
                color: _imageBackgroundColor,
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF9ED0FF),
                  size: 30,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'EUR ${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _textColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
