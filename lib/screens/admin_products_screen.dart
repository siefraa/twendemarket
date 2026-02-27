import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../theme.dart';
import 'package:uuid/uuid.dart';

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, null),
        backgroundColor: AppColors.primary,
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
      body: products.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🛍️', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('No products yet',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: products.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _AdminProductCard(product: products.products[i]),
                ),
    );
  }

  void _showProductForm(BuildContext context, ProductModel? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(product: product),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  final ProductModel product;
  const _AdminProductCard({required this.product});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            TwendeImage(
              url: product.imageUrls.isNotEmpty
                  ? product.imageUrls.first
                  : '',
              width: 64,
              height: 64,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    product.categoryName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(product.effectivePrice),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.isAvailable ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: product.isAvailable
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditForm(context, product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.adminAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.adminAccent),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 16, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  void _showEditForm(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(product: product),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<ProductsProvider>().deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Product Form Sheet ───────────────────────────────────────
class ProductFormSheet extends StatefulWidget {
  final ProductModel? product;
  const ProductFormSheet({super.key, this.product});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
      text: widget.product?.name ?? '');
  late final _descCtrl = TextEditingController(
      text: widget.product?.description ?? '');
  late final _priceCtrl = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '');
  late final _stockCtrl = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '');
  late final _unitCtrl = TextEditingController(
      text: widget.product?.unit ?? 'piece');
  late final _imageCtrl = TextEditingController(
      text: widget.product?.imageUrls.firstOrNull ?? '');
  late bool _isAvailable = widget.product?.isAvailable ?? true;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Edit Product' : 'Add New Product',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _field('Product Name', _nameCtrl, required: true),
              const SizedBox(height: 12),
              _field('Description', _descCtrl,
                  maxLines: 3, required: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field('Price (TZS)', _priceCtrl,
                        keyboardType: TextInputType.number,
                        required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field('Stock', _stockCtrl,
                        keyboardType: TextInputType.number,
                        required: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field('Unit (kg/piece/litre)', _unitCtrl,
                  required: true),
              const SizedBox(height: 12),
              _field('Image URL', _imageCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Available for sale'),
                  const Spacer(),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) =>
                        setState(() => _isAvailable = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isEditing
                        ? 'Update Product'
                        : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => v!.isEmpty ? 'Required' : null
            : null,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<ProductsProvider>();

    final product = ProductModel(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      categoryId: widget.product?.categoryId ?? 'general',
      categoryName: widget.product?.categoryName ?? 'General',
      imageUrls:
          _imageCtrl.text.trim().isEmpty ? [] : [_imageCtrl.text.trim()],
      isAvailable: _isAvailable,
      stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
      unit: _unitCtrl.text.trim(),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }
}
