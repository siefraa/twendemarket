import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 48, color: Colors.grey))),
              Positioned(top: 8, right: 8,
                child: GestureDetector(
                  onTap: () {}, 
                  child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: const Icon(Icons.favorite_outline, size: 18, color: Colors.grey)),
                )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(product.vendorName, style: TextStyle(color: AppTheme.textLight, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 13),
                Text(' ${product.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${product.reviewCount})', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text('TZS ${_fmt(product.price)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13), overflow: TextOverflow.ellipsis)),
                GestureDetector(
                  onTap: () {
                    context.read<AppProvider>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added to cart!'), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating));
                  },
                  child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  String _fmt(double price) => price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
