import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _placing = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: TwendeColors.bg,
      appBar: AppBar(title: Text('My Cart (${cart.count})')),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: TwendeColors.textLight),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: TwendeColors.textMid)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...cart.items.map((item) => _CartItemTile(item: item)),
                      const SizedBox(height: 16),
                      _SectionTitle('Delivery Details'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Enter delivery address...',
                          prefixIcon: Icon(Icons.location_on_outlined, color: TwendeColors.primary),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Delivery note (optional)',
                          prefixIcon: Icon(Icons.note_outlined, color: TwendeColors.textLight),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle('Order Summary'),
                      const SizedBox(height: 8),
                      _SummaryRow('Subtotal', 'TZS ${cart.subtotal.toStringAsFixed(0)}'),
                      _SummaryRow('Delivery Fee', 'TZS ${cart.deliveryFee.toStringAsFixed(0)}'),
                      const Divider(height: 20),
                      _SummaryRow('Total', 'TZS ${cart.total.toStringAsFixed(0)}', bold: true),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placing ? null : () => _placeOrder(context, cart),
                      child: _placing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Place Order • TZS ${cart.total.toStringAsFixed(0)}'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter delivery address'), backgroundColor: TwendeColors.danger));
      return;
    }
    setState(() => _placing = true);
    try {
      final auth = context.read<AuthProvider>();
      final order = Order(
        id: '',
        userId: auth.user!.id,
        userName: auth.user!.name,
        items: cart.items.map((c) => OrderItem(
          productId: c.product.id,
          productName: c.product.name,
          price: c.product.price,
          quantity: c.quantity,
          imageUrl: c.product.imageUrl,
        )).toList(),
        total: cart.total,
        address: _addressCtrl.text.trim(),
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      await FirebaseService.placeOrder(order);
      cart.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully! 🎉'), backgroundColor: TwendeColors.primary),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: TwendeColors.danger));
    }
    setState(() => _placing = false);
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl.isNotEmpty
                ? Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _img())
                : _img(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('TZS ${item.product.price.toStringAsFixed(0)}', style: const TextStyle(color: TwendeColors.primary, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              _Btn(icon: Icons.remove, onTap: () => cart.decreaseItem(item.product.id)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
              _Btn(icon: Icons.add, onTap: () => cart.addItem(item.product)),
            ],
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: TwendeColors.danger), onPressed: () => cart.removeItem(item.product.id)),
        ],
      ),
    );
  }

  Widget _img() => Container(width: 60, height: 60, color: TwendeColors.primary.withOpacity(0.1), child: const Icon(Icons.image_outlined, color: TwendeColors.textLight));
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28, decoration: BoxDecoration(color: TwendeColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: TwendeColors.primary)),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? TwendeColors.textDark : TwendeColors.textMid, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, color: bold ? TwendeColors.primary : TwendeColors.textDark, fontSize: bold ? 16 : 14)),
      ],
    ),
  );
}
