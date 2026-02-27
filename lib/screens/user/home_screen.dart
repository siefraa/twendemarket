import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _search = '';

  final _categories = ['All', 'Groceries', 'Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Drinks', 'Snacks', 'Other'];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: TwendeColors.bg,
      body: IndexedStack(
        index: _tab,
        children: [
          _buildShopTab(cart),
          const OrdersScreen(),
          _buildProfileTab(auth),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: TwendeColors.primary.withOpacity(0.12),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store, color: TwendeColors.primary), label: 'Shop'),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: TwendeColors.primary), label: 'Orders'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: TwendeColors.primary), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildShopTab(CartProvider cart) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: TwendeColors.bg,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TwendeMarket', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: TwendeColors.textDark)),
                const Text('Fresh • Fast • Reliable', style: TextStyle(fontSize: 11, color: TwendeColors.textMid, fontFamily: 'DM Sans')),
              ],
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: TwendeColors.textDark),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                if (cart.count > 0)
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: TwendeColors.accent, shape: BoxShape.circle),
                      child: Text('${cart.count}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(fontFamily: 'DM Sans', color: TwendeColors.textLight),
                prefixIcon: const Icon(Icons.search, color: TwendeColors.textLight),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: TwendeColors.textLight), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                    : null,
              ),
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? TwendeColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? TwendeColors.primary : const Color(0xFFE2EAE9)),
                    ),
                    child: Text(cat, style: TextStyle(
                      color: selected ? Colors.white : TwendeColors.textMid,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                    )),
                  ),
                );
              },
            ),
          ),
        ),

        // Products Grid
        StreamBuilder<List<Product>>(
          stream: FirebaseService.getProducts(category: _selectedCategory),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: TwendeColors.primary)));
            }
            var products = snap.data ?? [];
            if (_search.isNotEmpty) {
              products = products.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();
            }
            if (products.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: TwendeColors.textLight),
                    SizedBox(height: 12),
                    Text('No products found', style: TextStyle(color: TwendeColors.textMid)),
                  ],
                )),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ProductCard(product: products[i]),
                  childCount: products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 44,
              backgroundColor: TwendeColors.primary.withOpacity(0.15),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: TwendeColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(user?.email ?? '', style: const TextStyle(color: TwendeColors.textMid, fontFamily: 'DM Sans')),
            const SizedBox(height: 32),
            _ProfileTile(icon: Icons.phone_outlined, title: 'Phone', value: user?.phone ?? '-'),
            const SizedBox(height: 12),
            _ProfileTile(icon: Icons.location_on_outlined, title: 'Saved Addresses', value: '${user?.addresses.length ?? 0} addresses'),
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ProfileTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: TwendeColors.primary),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: TwendeColors.textLight, fontFamily: 'DM Sans')),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('TZS ${product.price.toStringAsFixed(0)}', style: const TextStyle(color: TwendeColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added to cart'), backgroundColor: TwendeColors.primary, duration: const Duration(seconds: 1)),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), textStyle: const TextStyle(fontSize: 12)),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: TwendeColors.primary.withOpacity(0.08),
    child: const Center(child: Icon(Icons.image_outlined, color: TwendeColors.textLight, size: 40)),
  );
}
