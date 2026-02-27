import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final p = widget.product;
    return Scaffold(
      backgroundColor: TwendeColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: TwendeColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: p.imageUrl.isNotEmpty
                  ? Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: TwendeColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: TwendeColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text(p.category, style: const TextStyle(color: TwendeColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      if (p.rating > 0) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${p.rating}  (${p.reviewCount})', style: const TextStyle(fontSize: 12, color: TwendeColors.textMid, fontFamily: 'DM Sans')),
                      ]
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('TZS ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: TwendeColors.primary)),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(p.description, style: const TextStyle(color: TwendeColors.textMid, fontFamily: 'DM Sans', height: 1.6)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _QtyBtn(icon: Icons.remove, onTap: () { if (_qty > 1) setState(() => _qty--); }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      _QtyBtn(icon: Icons.add, onTap: () => setState(() => _qty++)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        for (int i = 0; i < _qty; i++) cart.addItem(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$_qty x ${p.name} added!'), backgroundColor: TwendeColors.primary),
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Add $_qty to Cart • TZS ${(p.price * _qty).toStringAsFixed(0)}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: TwendeColors.primary.withOpacity(0.1),
    child: const Center(child: Icon(Icons.image_outlined, size: 80, color: TwendeColors.textLight)),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: TwendeColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: TwendeColors.primary, size: 18),
    ),
  );
}
