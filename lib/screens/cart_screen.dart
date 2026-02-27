import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../theme.dart';
import 'order_tracking_screen.dart';

// ─── Cart Screen ──────────────────────────────────────────────
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart (${cart.itemCount})'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Remove all items from your cart?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          context.read<CartProvider>().clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear',
                            style:
                                TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add some delicious items!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 48)),
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return _CartItemCard(item: item);
                    },
                  ),
                ),
                // ── Order Summary ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow('Subtotal', formatCurrency(cart.subtotal)),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        'Delivery Fee',
                        cart.deliveryFee == 0
                            ? 'FREE'
                            : formatCurrency(cart.deliveryFee),
                        valueColor: cart.deliveryFee == 0
                            ? AppColors.success
                            : null,
                      ),
                      if (cart.subtotal < 5000)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Add ${formatCurrency(5000 - cart.subtotal)} more for free delivery!',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        'Total',
                        formatCurrency(cart.total),
                        isBold: true,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CheckoutScreen()),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          TwendeImage(
            url: item.product.imageUrls.isNotEmpty
                ? item.product.imageUrls.first
                : '',
            width: 70,
            height: 70,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(item.product.effectivePrice),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _btn(Icons.remove,
                        () => cart.removeItem(item.product.id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _btn(Icons.add, () => cart.addItem(item.product)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                onPressed: () => cart.deleteItem(item.product.id),
              ),
              Text(
                formatCurrency(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.fontSize = 14,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  (isBold ? AppColors.primary : AppColors.textPrimary),
              fontWeight:
                  isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      );
}

// ─── Checkout Screen ──────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  final _notesCtrl = TextEditingController();
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address
                  _SectionTitle('📍 Delivery Address'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'Enter your full delivery address...',
                      prefixIcon:
                          Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method
                  _SectionTitle('💳 Payment Method'),
                  const SizedBox(height: 12),
                  ...[
                    ('cash', '💵', 'Cash on Delivery'),
                    ('mpesa', '📱', 'M-Pesa'),
                    ('card', '💳', 'Credit/Debit Card'),
                  ].map(
                    (method) => GestureDetector(
                      onTap: () => setState(
                          () => _paymentMethod = method.$1),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _paymentMethod == method.$1
                              ? AppColors.primaryLight
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _paymentMethod == method.$1
                                ? AppColors.primary
                                : AppColors.border,
                            width:
                                _paymentMethod == method.$1 ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(method.$2,
                                style:
                                    const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Text(
                              method.$3,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _paymentMethod == method.$1
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (_paymentMethod == method.$1)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  _SectionTitle('📝 Delivery Notes (Optional)'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'Any special instructions for delivery...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  _SectionTitle('🧾 Order Summary'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8),
                            child: Row(
                              children: [
                                Text('${item.quantity}x ',
                                    style: const TextStyle(
                                        color:
                                            AppColors.textSecondary)),
                                Expanded(
                                    child:
                                        Text(item.product.name)),
                                Text(
                                    formatCurrency(item.total),
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        _SummaryRow('Subtotal',
                            formatCurrency(cart.subtotal)),
                        const SizedBox(height: 4),
                        _SummaryRow(
                            'Delivery',
                            cart.deliveryFee == 0
                                ? 'FREE'
                                : formatCurrency(cart.deliveryFee),
                            valueColor: cart.deliveryFee == 0
                                ? AppColors.success
                                : null),
                        const Divider(),
                        _SummaryRow('Total',
                            formatCurrency(cart.total),
                            isBold: true, fontSize: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Place Order Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: ElevatedButton(
              onPressed: _isPlacing ? null : () => _placeOrder(context),
              child: _isPlacing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Place Order • ${formatCurrency(cart.total)}'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address')),
      );
      return;
    }
    setState(() => _isPlacing = true);
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orders = context.read<OrdersProvider>();
    try {
      final orderId = await orders.placeOrder(
        userId: auth.user!.id,
        userName: auth.user!.name,
        userPhone: auth.user!.phone,
        items: cart.items,
        deliveryAddress: AddressModel(
          id: 'temp',
          label: 'Delivery',
          fullAddress: _addressCtrl.text.trim(),
          lat: 0,
          lng: 0,
        ),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        paymentMethod: _paymentMethod,
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );
      cart.clearCart();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Try again.')),
      );
    }
    setState(() => _isPlacing = false);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
}
