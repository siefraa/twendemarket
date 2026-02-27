import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text('Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showProductForm(context, null),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(backgroundColor: TwendeColors.adminAccent, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: FirebaseService.getAllProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: TwendeColors.adminAccent));
                }
                final products = snap.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet. Add some!', style: TextStyle(color: Colors.white38)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _AdminProductTile(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductForm(product: product),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  final Product product;
  const _AdminProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: TwendeColors.adminCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _img())
                : _img(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('TZS ${product.price.toStringAsFixed(0)} • ${product.category}',
                style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'DM Sans')),
              Row(children: [
                Icon(product.isAvailable ? Icons.check_circle : Icons.cancel, size: 12, color: product.isAvailable ? TwendeColors.adminAccent : TwendeColors.danger),
                const SizedBox(width: 4),
                Text(product.isAvailable ? 'Available' : 'Unavailable', style: TextStyle(color: product.isAvailable ? TwendeColors.adminAccent : TwendeColors.danger, fontSize: 11)),
              ]),
            ]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white38),
            color: TwendeColors.adminBg,
            onSelected: (v) async {
              if (v == 'edit') {
                showModalBottomSheet(
                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (_) => _ProductForm(product: product),
                );
              } else if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: TwendeColors.adminCard,
                    title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure?', style: TextStyle(color: Colors.white54)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: TwendeColors.danger))),
                    ],
                  ),
                );
                if (confirm == true) await FirebaseService.deleteProduct(product.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: TwendeColors.danger))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _img() => Container(width: 56, height: 56, color: Colors.white10, child: const Icon(Icons.image_outlined, color: Colors.white24));
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({this.product});
  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _descCtrl = TextEditingController(text: widget.product?.description);
  late final _priceCtrl = TextEditingController(text: widget.product?.price.toStringAsFixed(0));
  late final _imgCtrl = TextEditingController(text: widget.product?.imageUrl);
  late String _category = widget.product?.category ?? 'Groceries';
  late bool _available = widget.product?.isAvailable ?? true;
  bool _saving = false;

  final _categories = ['Groceries', 'Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Drinks', 'Snacks', 'Other'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: TwendeColors.adminBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(widget.product == null ? 'Add Product' : 'Edit Product', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Product Name', 'Required'),
              const SizedBox(height: 12),
              _field(_descCtrl, 'Description', null, maxLines: 3),
              const SizedBox(height: 12),
              _field(_priceCtrl, 'Price (TZS)', 'Required', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _field(_imgCtrl, 'Image URL', null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: TwendeColors.adminCard,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white38),
                  filled: true, fillColor: TwendeColors.adminCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _available,
                onChanged: (v) => setState(() => _available = v),
                title: const Text('Available for order', style: TextStyle(color: Colors.white)),
                activeColor: TwendeColors.adminAccent,
                tileColor: TwendeColors.adminCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: TwendeColors.adminAccent),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.product == null ? 'Add Product' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String? required, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        filled: true, fillColor: TwendeColors.adminCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TwendeColors.adminAccent)),
      ),
      validator: required != null ? (v) => v!.trim().isEmpty ? required : null : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        category: _category,
        imageUrl: _imgCtrl.text.trim(),
        isAvailable: _available,
      );
      if (widget.product == null) {
        await FirebaseService.addProduct(product);
      } else {
        await FirebaseService.updateProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: TwendeColors.danger));
    }
    setState(() => _saving = false);
  }
}
