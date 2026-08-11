import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/purchase.dart';
import '../providers/ecommerce_provider.dart';
import 'ecommerce_bottom_nav_bar.dart';

class PurchasesView extends ConsumerStatefulWidget {
  const PurchasesView({super.key});

  @override
  ConsumerState<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends ConsumerState<PurchasesView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreNearBottom);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreNearBottom)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearBottom() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(paginatedUserPurchasesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchasesState = ref.watch(paginatedUserPurchasesProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final isAdmin = userProfileAsync.valueOrNull?.rol == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Mis compras',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: EcommerceBottomNavBar(
        currentIndex: 3,
        isAdmin: isAdmin,
        onItemSelected: (index) {
          if (index == 0) {
            context.goNamed('ecommerce-home');
            return;
          }
          if (index == 3) return;
          if (isAdmin && index == 5) {
            context.goNamed('ecommerce-admin-products');
          }
        },
      ),
      body: _PurchasesBody(
        controller: _scrollController,
        state: purchasesState,
        onRefresh:
            () =>
                ref.read(paginatedUserPurchasesProvider.notifier).loadInitial(),
        onLoadMore:
            () => ref.read(paginatedUserPurchasesProvider.notifier).loadMore(),
      ),
    );
  }
}

class _PurchasesBody extends StatelessWidget {
  const _PurchasesBody({
    required this.controller,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final ScrollController controller;
  final PaginatedUserPurchasesState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.purchases.isEmpty) {
      if (state.error != null) {
        return _PurchasesError(message: state.error!, onRetry: onRefresh);
      }

      return const _EmptyPurchases();
    }

    final itemCount =
        state.purchases.length + (state.hasMore || state.error != null ? 1 : 0);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index < state.purchases.length) {
            return _PurchaseCard(purchase: state.purchases[index]);
          }

          if (state.error != null) {
            return _InlineLoadError(message: state.error!, onRetry: onLoadMore);
          }

          return _LoadMoreIndicator(
            isLoading: state.isLoadingMore,
            onPressed: onLoadMore,
          );
        },
      ),
    );
  }
}

class _PurchasesError extends StatelessWidget {
  const _PurchasesError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudieron cargar las compras: $message',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  const _InlineLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'No se pudo cargar la siguiente pagina: $message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: const Text('Cargar mas compras'),
      ),
    );
  }
}

class _EmptyPurchases extends StatelessWidget {
  const _EmptyPurchases();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF067DF7),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Todavía no tienes compras',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cuando completes un pago, aparecerá aquí en tiempo real.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Compra ${purchase.id.substring(0, purchase.id.length > 8 ? 8 : purchase.id.length)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _StatusBadge(status: purchase.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(purchase.createdAt),
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final item in purchase.items) ...[
            _PurchaseItemRow(item: item),
            if (item != purchase.items.last) const SizedBox(height: 10),
          ],
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                'EUR ${purchase.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}

class _PurchaseItemRow extends StatelessWidget {
  const _PurchaseItemRow({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 52,
            height: 52,
            color: const Color(0xFFEAF2FF),
            child: _ProductImage(imageUrl: item.imageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name.isEmpty ? 'Producto' : item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Cantidad: ${item.quantity}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          'EUR ${item.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(
        Icons.image_outlined,
        color: Color(0xFF9ED0FF),
        size: 24,
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => const Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF9ED0FF),
            size: 24,
          ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFBF3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? 'completed' : status,
        style: const TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
