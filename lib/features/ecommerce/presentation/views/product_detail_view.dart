import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../providers/ecommerce_provider.dart';

const _primaryColor = Color(0xFF067DF7);
const _imageBackgroundColor = Color(0xFFEAF2FF);
const _textColor = Color(0xFF202124);

class ProductDetailView extends ConsumerStatefulWidget {
  const ProductDetailView({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  String? _selectedSize;
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(ecommerceProductsProvider);

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
      body: productsAsync.when(
        data: (products) {
          Product? selectedProduct;
          for (final product in products) {
            if (product.id == widget.productId) {
              selectedProduct = product;
              break;
            }
          }

          final product = selectedProduct;
          if (product == null) {
            return const Center(child: Text('Producto no encontrado.'));
          }

          _selectedSize ??= product.sizes.isEmpty ? null : product.sizes.first;

          return _ProductDetailContent(
            product: product,
            selectedSize: _selectedSize,
            selectedColorIndex: _selectedColorIndex,
            onSizeSelected: (size) {
              setState(() {
                _selectedSize = size;
              });
            },
            onColorSelected: (index) {
              setState(() {
                _selectedColorIndex = index;
              });
            },
            onAddToCart: () {
              ref.read(ecommerceControllerProvider.notifier).addToCart(product);
              context.goNamed('ecommerce-cart');
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el producto: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.onSizeSelected,
    required this.onColorSelected,
    required this.onAddToCart,
  });

  final Product product;
  final String? selectedSize;
  final int selectedColorIndex;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text('EUR ${product.price.toStringAsFixed(2)}'),
          const SizedBox(height: 20),
          Text(product.description),
          const SizedBox(height: 28),
          Text(
            'Size',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          if (selectedSize != null)
            _SizeSelector(
              sizes: product.sizes,
              selectedSize: selectedSize!,
              onSelected: onSizeSelected,
            ),
          const SizedBox(height: 24),
          Text(
            'Color',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          _ColorSelector(
            colors: product.colors,
            selectedIndex: selectedColorIndex,
            onSelected: onColorSelected,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onAddToCart,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add to bag'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
  });

  final List<String> sizes;
  final String selectedSize;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          sizes.map((size) {
            final isSelected = size == selectedSize;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () => onSelected(size),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 28,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minWidth: 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : _imageBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<int> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(colors.length, (index) {
        final isSelected = index == selectedIndex;

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(colors[index]),
                    shape: BoxShape.circle,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
