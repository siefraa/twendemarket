import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: TwendeColors.bg,
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<Order>>(
        stream: FirebaseService.getUserOrders(user.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: TwendeColors.primary));
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: TwendeColors.textLight),
                  SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(fontSize: 18, color: TwendeColors.textMid)),
                  Text('Start shopping!', style: TextStyle(color: TwendeColors.textLight, fontFamily: 'DM Sans')),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return TwendeColors.warning;
      case OrderStatus.confirmed: return TwendeColors.info;
      case OrderStatus.preparing: return Colors.purple;
      case OrderStatus.onTheWay: return TwendeColors.accent;
      case OrderStatus.delivered: return TwendeColors.primary;
      case OrderStatus.cancelled: return TwendeColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _OrderDetail(order: order),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order #${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(order.status.label, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.items.length} item(s) • TZS ${order.total.toStringAsFixed(0)}',
              style: const TextStyle(color: TwendeColors.textMid, fontFamily: 'DM Sans')),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: TwendeColors.textLight),
                const SizedBox(width: 4),
                Expanded(child: Text(order.address, style: const TextStyle(fontSize: 12, color: TwendeColors.textMid, fontFamily: 'DM Sans'), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),
            _TrackingBar(status: order.status),
          ],
        ),
      ),
    );
  }
}

class _TrackingBar extends StatelessWidget {
  final OrderStatus status;
  const _TrackingBar({required this.status});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const Text('Order Cancelled', style: TextStyle(color: TwendeColors.danger, fontWeight: FontWeight.w600, fontSize: 12));
    }
    final currentIdx = _steps.indexOf(status);
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineIdx = i ~/ 2;
          return Expanded(child: Container(height: 2, color: lineIdx < currentIdx ? TwendeColors.primary : const Color(0xFFE2EAE9)));
        }
        final stepIdx = i ~/ 2;
        final done = stepIdx <= currentIdx;
        return Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: done ? TwendeColors.primary : Colors.white,
            border: Border.all(color: done ? TwendeColors.primary : const Color(0xFFE2EAE9), width: 2),
            shape: BoxShape.circle,
          ),
          child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        );
      }),
    );
  }
}

class _OrderDetail extends StatelessWidget {
  final Order order;
  const _OrderDetail({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2EAE9), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Order #${order.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(order.status.label, style: const TextStyle(color: TwendeColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('${item.quantity}x ${item.productName}')),
                  Text('TZS ${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('TZS ${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: TwendeColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(order.address, style: const TextStyle(color: TwendeColors.textMid, fontFamily: 'DM Sans')),
            if (order.deliveryNote != null) ...[
              const SizedBox(height: 12),
              const Text('Note', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(order.deliveryNote!, style: const TextStyle(color: TwendeColors.textMid, fontFamily: 'DM Sans')),
            ],
          ],
        ),
      ),
    );
  }
}
