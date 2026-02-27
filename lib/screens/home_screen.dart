import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/vendor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final pages = [_buildHome(app), _buildVendors(app), _buildCart(app), _buildProfile(app)];

    return Scaffold(
      body: pages[_bottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textLight,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Vendors'),
          BottomNavigationBarItem(
            icon: Badge(label: Text('${app.cartCount}'), isLabelVisible: app.cartCount > 0, child: const Icon(Icons.shopping_cart_outlined)),
            activeIcon: Badge(label: Text('${app.cartCount}'), isLabelVisible: app.cartCount > 0, child: const Icon(Icons.shopping_cart)),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome(AppProvider app) {
    final filtered = _search.isEmpty
        ? app.filteredProducts
        : app.filteredProducts.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 140,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  const Text('Dar es Salaam, TZ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const Spacer(),
                  if (context.read<AppProvider>().isLoggedIn)
                    Text('Habari, ${context.read<AppProvider>().currentUser!.name.split(' ').first}!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                const Text('TwendeMarket 🛒', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); }) : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: app.categories.length,
              itemBuilder: (ctx, i) {
                final cat = app.categories[i];
                final selected = cat == app.selectedCategory;
                return GestureDetector(
                  onTap: () => app.setCategory(cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade300),
                    ),
                    child: Text(cat, style: TextStyle(color: selected ? Colors.white : AppTheme.textDark, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
        ),

        // Featured Vendors Banner
        if (_search.isEmpty && app.selectedCategory == 'All')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🏪 Top Vendors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: app.vendors.take(4).length,
                    itemBuilder: (ctx, i) {
                      final v = app.vendors[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/vendor', arguments: v),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                              child: Image.network(v.imageUrl, width: 60, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, color: Colors.grey.shade200, child: const Icon(Icons.store))),
                            ),
                            Expanded(child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                if (v.isVerified) Row(children: [const Icon(Icons.verified, color: Colors.blue, size: 12), const SizedBox(width: 2), Text('Verified', style: TextStyle(color: Colors.blue, fontSize: 10))]),
                                Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(children: [const Icon(Icons.star, color: Colors.amber, size: 12), Text(' ${v.rating}', style: const TextStyle(fontSize: 11))]),
                              ]),
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('🛍️ Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
              ]),
            ),
          ),

        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => ProductCard(product: filtered[i]),
              childCount: filtered.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildVendors(AppProvider app) {
    return CustomScrollView(slivers: [
      const SliverAppBar(
        pinned: true,
        title: Text('Vendors & Markets'),
        centerTitle: true,
      ),
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => VendorCard(vendor: app.vendors[i]),
            childCount: app.vendors.length,
          ),
        ),
      ),
    ]);
  }

  Widget _buildCart(AppProvider app) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: app.cart.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Add items from the market!', style: TextStyle(color: Colors.grey)),
            ]))
          : Column(children: [
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: app.cart.length,
                itemBuilder: (ctx, i) {
                  final item = app.cart[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey.shade200)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text(item.product.vendorName, style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('TZS ${item.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ])),
                        Column(children: [
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => app.removeFromCart(item.product.id)),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), iconSize: 20, onPressed: () => app.updateQuantity(item.product.id, item.quantity - 1)),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), iconSize: 20, onPressed: () => app.updateQuantity(item.product.id, item.quantity + 1)),
                          ]),
                        ]),
                      ]),
                    ),
                  );
                },
              )),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))]),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('TZS ${app.cartTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!app.isLoggedIn) {
                          Navigator.pushNamed(context, '/login');
                          return;
                        }
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Order Placed! 🎉'),
                          content: const Text('Your order has been placed successfully. The vendor will contact you shortly.'),
                          actions: [TextButton(onPressed: () { app.clearCart(); Navigator.pop(context); }, child: const Text('OK'))],
                        ));
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Place Order', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }

  Widget _buildProfile(AppProvider app) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: app.isLoggedIn ? Column(children: [
          CircleAvatar(radius: 50, backgroundColor: AppTheme.primary, child: Text(app.currentUser!.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          Text(app.currentUser!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(app.currentUser!.email, style: TextStyle(color: AppTheme.textLight)),
          Text(app.currentUser!.phone, style: TextStyle(color: AppTheme.textLight)),
          const SizedBox(height: 24),
          _profileTile(Icons.shopping_bag_outlined, 'My Orders', () {}),
          _profileTile(Icons.favorite_outline, 'Wishlist', () {}),
          _profileTile(Icons.location_on_outlined, 'Delivery Address', () {}),
          _profileTile(Icons.notifications_outlined, 'Notifications', () {}),
          _profileTile(Icons.help_outline, 'Help & Support', () {}),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () { app.logout(); Navigator.pushReplacementNamed(context, '/login'); },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ]) : Column(children: [
          const SizedBox(height: 40),
          const Icon(Icons.person_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Not signed in', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Sign in to access your profile', style: TextStyle(color: AppTheme.textLight)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Sign In'))),
        ]),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
