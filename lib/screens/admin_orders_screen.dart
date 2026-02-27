import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../theme.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final filtered = _filterStatus == 'all'
        ? orders.allOrders
        : orders.allOrders
            .where((o) => o.status == _filterStatus)
            .toList();

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              'all',
              AppConstants.orderPending,
              AppConstants.orderConfirmed,
              AppConstants.orderPreparing,
              AppConstants.orderOutForDelivery,
              AppConstants.orderDelivered,
            ].map((status) {
              final isSelected = _filterStatus == status;
              return GestureDetector(
                onTap: () => setState(() => _filterStatus = status),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    status == 'all' ? 'All' : _statusLabel(status),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: orders.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📭', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No orders found',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _AdminOrderCard(order: filtered[i]),
                    ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppConstants.orderPending: return 'Pending';
      case AppConstants.orderConfirmed: return 'Confirmed';
      case AppConstants.orderPreparing: return 'Preparing';
      case AppConstants.orderOutForDelivery: return 'On the Way';
      case AppConstants.orderDelivered: return 'Delivered';
      case AppConstants.orderCancelled: return 'Cancelled';
      default: return status;
    }
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      order.userName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.items.length} item(s) • ${formatCurrency(order.total)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            '📍 ${order.deliveryAddress.fullAddress}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Action buttons
          if (order.status != AppConstants.orderDelivered &&
              order.status != AppConstants.orderCancelled) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                if (order.status != AppConstants.orderCancelled)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, order,
                          AppConstants.orderCancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side:
                            const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateStatus(context, order, _nextStatus(order.status)),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    child: Text(_nextLabel(order.status)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _nextStatus(String current) {
    switch (current) {
      case AppConstants.orderPending: return AppConstants.orderConfirmed;
      case AppConstants.orderConfirmed: return AppConstants.orderPreparing;
      case AppConstants.orderPreparing: return AppConstants.orderOutForDelivery;
      case AppConstants.orderOutForDelivery: return AppConstants.orderDelivered;
      default: return current;
    }
  }

  String _nextLabel(String current) {
    switch (current) {
      case AppConstants.orderPending: return 'Confirm Order';
      case AppConstants.orderConfirmed: return 'Start Preparing';
      case AppConstants.orderPreparing: return 'Out for Delivery';
      case AppConstants.orderOutForDelivery: return 'Mark Delivered';
      default: return 'Update';
    }
  }

  Future<void> _updateStatus(
      BuildContext context, OrderModel order, String newStatus) async {
    await context
        .read<OrdersProvider>()
        .updateOrderStatus(order.id, newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order updated to ${newStatus.replaceAll('_', ' ')}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
