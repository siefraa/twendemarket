import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';
import 'admin_products.dart';
import 'admin_orders.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwendeColors.adminBg,
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(),
          const AdminOrdersScreen(),
          const AdminProductsScreen(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: TwendeColors.adminCard,
        selectedItemColor: TwendeColors.adminAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
            const Text('TwendeMarket Control Center', style: TextStyle(color: Colors.white38, fontFamily: 'DM Sans')),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, dynamic>>(
              future: FirebaseService.getDashboardStats(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: TwendeColors.adminAccent));
                }
                final stats = snap.data!;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard('Total Orders', '${stats['totalOrders']}', Icons.receipt_long, TwendeColors.adminAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard('Users', '${stats['totalUsers']}', Icons.people, TwendeColors.info)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard('Products', '${stats['totalProducts']}', Icons.inventory_2, TwendeColors.warning)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard('Revenue', 'TZS ${(stats['revenue'] as double).toStringAsFixed(0)}', Icons.payments, Colors.purple)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard('Delivered', '${stats['delivered']}', Icons.check_circle, TwendeColors.adminAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard('Pending', '${stats['pending']}', Icons.pending, TwendeColors.accent)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            StreamBuilder<List<Order>>(
              stream: FirebaseService.getAllOrders(),
              builder: (context, snap) {
                final orders = (snap.data ?? []).take(5).toList();
                if (orders.isEmpty) return const Text('No orders yet', style: TextStyle(color: Colors.white38));
                return Column(
                  children: orders.map((o) => _RecentOrderTile(order: o)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TwendeColors.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'DM Sans')),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: TwendeColors.adminCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('${order.items.length} items • TZS ${order.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'DM Sans')),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: TwendeColors.adminAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(order.status.label, style: const TextStyle(color: TwendeColors.adminAccent, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(radius: 44, backgroundColor: TwendeColors.adminAccent.withOpacity(0.15),
              child: const Icon(Icons.admin_panel_settings, size: 44, color: TwendeColors.adminAccent)),
            const SizedBox(height: 12),
            Text(auth.user?.name ?? 'Admin', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(auth.user?.email ?? '', style: const TextStyle(color: Colors.white38, fontFamily: 'DM Sans')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: TwendeColors.adminAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('Administrator', style: TextStyle(color: TwendeColors.adminAccent, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => auth.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: TwendeColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
