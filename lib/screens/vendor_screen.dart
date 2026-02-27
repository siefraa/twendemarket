import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vendor.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';

class VendorScreen extends StatelessWidget {
  final Vendor vendor;
  const VendorScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final products = context.read<AppProvider>().products.where((p) => p.vendorId == vendor.id).toList();

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(vendor.name, style: const TextStyle(fontSize: 14)),
            background: Stack(children: [
              Image.network(vendor.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
              Container(color: Colors.black38),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(vendor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                if (vendor.isVerified) Row(children: [const Icon(Icons.verified, color: Colors.blue, size: 18), const SizedBox(width: 4), const Text('Verified', style: TextStyle(color: Colors.blue))]),
              ]),
              const SizedBox(height: 8),
              Text(vendor.description, style: TextStyle(color: AppTheme.textLight)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.location_on, color: AppTheme.primary, size: 16),
                const SizedBox(width: 4),
                Text(vendor.location, style: TextStyle(color: AppTheme.textLight)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${vendor.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 16),
                Text('  ${vendor.productCount} products', style: TextStyle(color: AppTheme.textLight)),
              ]),
              const SizedBox(height: 16),
              const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => ProductCard(product: products[i]),
              childCount: products.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }
}
