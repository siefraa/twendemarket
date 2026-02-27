import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orders = context.read<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: orders.orderStream(orderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = OrderModel.fromFirestore(snapshot.data!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Success Header ───────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tracking Timeline ────────────────────────
                const Text(
                  'Order Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _TrackingTimeline(currentStatus: order.status),
                const SizedBox(height: 24),

                // ── Estimated Time ───────────────────────────
                if (order.estimatedDelivery != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(
                                  order.estimatedDelivery!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Delivery Address ─────────────────────────
                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Address',
                  content: order.deliveryAddress.fullAddress,
                ),
                const SizedBox(height: 12),

                // ── Order Items ──────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Order Items',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Text('📦')),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w600),
                                    ),
                                    Text(
                                      '${item.quantity} × ${formatCurrency(item.price)}',
                                      style: const TextStyle(
                                        color:
                                            AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatCurrency(item.total),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formatCurrency(order.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Payment Info ─────────────────────────────
                _InfoCard(
                  icon: Icons.payment_outlined,
                  title: 'Payment',
                  content: order.paymentMethod == 'cash'
                      ? 'Cash on Delivery'
                      : order.paymentMethod == 'mpesa'
                          ? 'M-Pesa'
                          : 'Card',
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final String currentStatus;

  const _TrackingTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (AppConstants.orderPending, '🕐', 'Order Placed',
          'We received your order'),
      (AppConstants.orderConfirmed, '✅', 'Order Confirmed',
          'Your order is confirmed'),
      (AppConstants.orderPreparing, '👨‍🍳', 'Preparing',
          'Getting your items ready'),
      (AppConstants.orderOutForDelivery, '🚴', 'Out for Delivery',
          'On the way to you'),
      (AppConstants.orderDelivered, '🎉', 'Delivered',
          'Enjoy your items!'),
    ];

    final statusOrder = [
      AppConstants.orderPending,
      AppConstants.orderConfirmed,
      AppConstants.orderPreparing,
      AppConstants.orderOutForDelivery,
      AppConstants.orderDelivered,
    ];
    final currentIndex = statusOrder.indexOf(currentStatus);

    return Column(
      children: steps.asMap().entries.map((e) {
        final index = e.key;
        final step = e.value;
        final isDone = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.primary
                        : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? Text(step.$2,
                            style: const TextStyle(fontSize: 18))
                        : Icon(Icons.circle_outlined,
                            color: AppColors.textHint, size: 16),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone && index < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.$3,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontSize: isCurrent ? 15 : 14,
                      ),
                    ),
                    Text(
                      step.$4,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
