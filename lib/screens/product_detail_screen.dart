import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String _fmt(double p) => p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.favorite_outline), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text(' ${product.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('  (${product.reviewCount} reviews)', style: TextStyle(color: AppTheme.textLight)),
              ]),
              const SizedBox(height: 12),
              Text('TZS ${_fmt(product.price)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(product.description, style: TextStyle(color: AppTheme.textLight, height: 1.5)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Vendor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: AppTheme.primary, child: Text(product.vendorName[0], style: const TextStyle(color: Colors.white))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(product.vendorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Tap to view store', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
        child: Row(children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: () {
              context.read<AppProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!'), behavior: SnackBarBehavior.floating));
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
          )),
        ]),
      ),
    );
  }
}
