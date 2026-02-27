import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../theme.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadAllOrders();
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();
    final products = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Admin Header ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.adminPrimary,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🛒 TwendeMarket Admin',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Welcome, ${auth.user?.name.split(' ').first ?? 'Admin'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Sign Out'),
                          content:
                              const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                context.read<AuthProvider>().logout();
                                Navigator.pop(context);
                              },
                              child: const Text('Sign Out',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Tab Bar ──────────────────────────────────────
            Container(
              color: AppColors.adminPrimary,
              child: Row(
                children: [
                  _Tab('Dashboard', 0, Icons.dashboard_outlined),
                  _Tab('Orders', 1, Icons.receipt_outlined),
                  _Tab('Products', 2, Icons.inventory_2_outlined),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _DashboardTab(),
                  const AdminOrdersTab(),
                  const AdminProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _Tab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : Colors.white54,
                  size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dashboard Overview Tab ───────────────────────────────────
class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final products = context.watch<ProductsProvider>();

    final statuses = [
      AppConstants.orderPending,
      AppConstants.orderConfirmed,
      AppConstants.orderPreparing,
      AppConstants.orderOutForDelivery,
      AppConstants.orderDelivered,
      AppConstants.orderCancelled,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stat Cards ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Orders',
                  value: '${orders.totalOrders}',
                  icon: '📦',
                  color: AppColors.adminAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: '${orders.pendingOrders}',
                  icon: '⏳',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Revenue',
                  value: formatCurrency(orders.totalRevenue),
                  icon: '💰',
                  color: AppColors.success,
                  smallText: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Products',
                  value: '${products.products.length}',
                  icon: '🛍️',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Order Status Breakdown ───────────────────────
          const Text(
            'Order Status Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: statuses.map((status) {
                final count = orders.allOrders
                    .where((o) => o.status == status)
                    .length;
                final total = orders.totalOrders;
                final pct = total == 0 ? 0.0 : count / total;
                return _StatusBar(
                    status: status, count: count, percent: pct);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Recent Orders ────────────────────────────────
          SectionHeader(
            title: 'Recent Orders',
            actionText: 'See all',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          ...orders.allOrders.take(5).map(
                (order) => _RecentOrderCard(order: order),
              ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color color;
  final bool smallText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) => Container(
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
                Text(icon, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: smallText ? 16 : 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

class _StatusBar extends StatelessWidget {
  final String status;
  final int count;
  final double percent;

  const _StatusBar({
    required this.status,
    required this.count,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                OrderStatusBadge(status: status),
                const Spacer(),
                Text(
                  '$count orders',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
}

class _RecentOrderCard extends StatelessWidget {
  final OrderModel order;
  const _RecentOrderCard({required this.order});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.adminPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.userName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '#${order.id.substring(0, 8).toUpperCase()} • ${order.items.length} items',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ],
        ),
      );
}
