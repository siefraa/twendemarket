import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text('All Orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: FirebaseService.getAllOrders(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: TwendeColors.adminAccent));
                }
                final orders = snap.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders yet', style: TextStyle(color: Colors.white38)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _AdminOrderCard(order: orders[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  const _AdminOrderCard({required this.order});

  static const _statusColors = {
    OrderStatus.pending: TwendeColors.warning,
    OrderStatus.confirmed: TwendeColors.info,
    OrderStatus.preparing: Colors.purple,
    OrderStatus.onTheWay: TwendeColors.accent,
    OrderStatus.delivered: TwendeColors.adminAccent,
    OrderStatus.cancelled: TwendeColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[order.status] ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: TwendeColors.adminCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: ExpansionTile(
        iconColor: Colors.white38,
        collapsedIconColor: Colors.white38,
        title: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('#${order.id.substring(0, 6).toUpperCase()} • TZS ${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'DM Sans')),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(order.status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Items:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                ...order.items.map((i) => Text('  • ${i.quantity}x ${i.productName} — TZS ${(i.price * i.quantity).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white54, fontFamily: 'DM Sans', fontSize: 13))),
                const SizedBox(height: 8),
                Text('📍 ${order.address}', style: const TextStyle(color: Colors.white54, fontFamily: 'DM Sans', fontSize: 12)),
                if (order.deliveryNote != null)
                  Text('📝 ${order.deliveryNote}', style: const TextStyle(color: Colors.white38, fontFamily: 'DM Sans', fontSize: 12)),
                const SizedBox(height: 12),
                const Text('Update Status:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: OrderStatus.values.where((s) => s != order.status).map((s) =>
                    GestureDetector(
                      onTap: () => FirebaseService.updateOrderStatus(order.id, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_statusColors[s] ?? Colors.grey).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: (_statusColors[s] ?? Colors.grey).withOpacity(0.4)),
                        ),
                        child: Text(s.label, style: TextStyle(color: _statusColors[s] ?? Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
