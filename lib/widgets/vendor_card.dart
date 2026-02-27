import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../utils/theme.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  const VendorCard({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/vendor', arguments: vendor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Image.network(vendor.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.store, size: 64, color: Colors.grey))),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                if (vendor.isVerified) const Icon(Icons.verified, color: Colors.blue, size: 18),
              ]),
              const SizedBox(height: 4),
              Text(vendor.description, style: TextStyle(color: AppTheme.textLight, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Expanded(child: Text(vendor.location, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                Text(' ${vendor.rating}  ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Container(width: 1, height: 14, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Text('${vendor.productCount} products', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(vendor.category, style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
