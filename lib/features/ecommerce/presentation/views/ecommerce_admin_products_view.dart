import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/ecommerce_provider.dart';
import 'ecommerce_bottom_nav_bar.dart';

const _primaryColor = Color(0xFF067DF7);

class EcommerceAdminProductsView extends ConsumerWidget {
  const EcommerceAdminProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, _) => Scaffold(
            body: Center(child: Text('No se pudo validar el rol: $error')),
          ),
      data: (profile) {
        if (profile?.rol != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Acceso restringido')),
            body: const Center(
              child: Text(
                'Solo los administradores pueden gestionar productos.',
              ),
            ),
          );
        }

        return _AdminProductsContent(userName: profile?.name ?? 'Admin');
      },
    );
  }
}

class _AdminProductsContent extends ConsumerWidget {
  const _AdminProductsContent({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(ecommerceProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar productos'),
        actions: [
          IconButton(
            tooltip: 'Agregar producto',
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: EcommerceBottomNavBar(
        currentIndex: 4,
        isAdmin: true,
        onItemSelected: (index) {
          if (index == 0) context.goNamed('ecommerce-home');
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar producto',
        onPressed: () => _openEditor(context),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudieron cargar los productos: $error'),
              ),
            ),
        data:
            (products) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder:
                  (context, index) => _AdminProductTile(
                    product: products[index],
                    onEdit:
                        () => _openEditor(context, product: products[index]),
                    onDelete:
                        () => _confirmDelete(context, ref, products[index]),
                  ),
            ),
      ),
    );
  }

  void _openEditor(BuildContext context, {Product? product}) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProductEditorDialog(product: product),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar producto'),
            content: Text('Se eliminara "${product.name}" de Firestore.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB3261E),
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    await ref.read(deleteProductProvider)(product.id);
    ref.invalidate(ecommerceProductsProvider);
  }
}

class _AdminProductTile extends StatelessWidget {
  const _AdminProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: _ProductThumbnail(imageUrl: product.imageUrl),
      title: Text(product.name),
      subtitle: Text(
        '${product.category} - EUR ${product.price.toStringAsFixed(2)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Editar producto',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar producto',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ProductEditorDialog extends ConsumerStatefulWidget {
  const _ProductEditorDialog({this.product});

  final Product? product;

  @override
  ConsumerState<_ProductEditorDialog> createState() =>
      _ProductEditorDialogState();
}

class _ProductEditorDialogState extends ConsumerState<_ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _sizesController;
  late final TextEditingController _colorsController;
  late String _category;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    _sizesController = TextEditingController(
      text: product?.sizes.join(', ') ?? '',
    );
    _colorsController = TextEditingController(
      text: product?.colors.join(', ') ?? '',
    );
    _category = product?.category ?? 'Perfect for you';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      category: _category,
      imageUrl:
          _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
      sizes: _splitValues(_sizesController.text),
      colors: _splitValues(_colorsController.text).map(int.parse).toList(),
    );

    try {
      if (_isEditing) {
        await ref.read(updateProductProvider)(product);
      } else {
        await ref.read(createProductProvider)(product);
      }

      ref.invalidate(ecommerceProductsProvider);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<String> _splitValues(String value) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar producto' : 'Agregar producto'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator:
                      (value) =>
                          (value ?? '').trim().isEmpty
                              ? 'Campo obligatorio.'
                              : null,
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Precio'),
                  validator: (value) {
                    final price = double.tryParse((value ?? '').trim());
                    return price == null || price < 0
                        ? 'Precio invalido.'
                        : null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator:
                      (value) =>
                          (value ?? '').trim().isEmpty
                              ? 'Campo obligatorio.'
                              : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Perfect for you',
                      child: Text('Perfect for you'),
                    ),
                    DropdownMenuItem(
                      value: 'For this summer',
                      child: Text('For this summer'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _category = value!),
                ),
                TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'URL de imagen'),
                ),
                TextFormField(
                  controller: _sizesController,
                  decoration: const InputDecoration(
                    labelText: 'Tallas separadas por coma',
                    hintText: 'S, M, L',
                  ),
                  validator:
                      (value) =>
                          _splitValues(value ?? '').isEmpty
                              ? 'Agrega al menos una talla.'
                              : null,
                ),
                TextFormField(
                  controller: _colorsController,
                  decoration: const InputDecoration(
                    labelText: 'Colores separados por coma',
                    hintText: '4280295700, 4285563514',
                  ),
                  validator: (value) {
                    final values = _splitValues(value ?? '');
                    return values.isEmpty ||
                            values.any((color) => int.tryParse(color) == null)
                        ? 'Usa numeros enteros separados por coma.'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(_isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 54,
        height: 54,
        child:
            imageUrl == null || imageUrl!.isEmpty
                ? const ColoredBox(
                  color: Color(0xFFEAF2FF),
                  child: Icon(Icons.image_outlined, color: Color(0xFF9ED0FF)),
                )
                : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const ColoredBox(
                        color: Color(0xFFEAF2FF),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF9ED0FF),
                        ),
                      ),
                ),
      ),
    );
  }
}
