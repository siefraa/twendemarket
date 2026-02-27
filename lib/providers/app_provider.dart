import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../models/user.dart';

class AppProvider extends ChangeNotifier {
  AppUser? _currentUser;
  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';

  AppUser? get currentUser => _currentUser;
  List<CartItem> get cart => _cart;
  String get selectedCategory => _selectedCategory;

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.total);

  bool get isLoggedIn => _currentUser != null;

  void login(String name, String email, String phone) {
    _currentUser = AppUser(id: '1', name: name, email: email, phone: phone);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addToCart(Product product) {
    final existing = _cart.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    final item = _cart.firstWhere((i) => i.product.id == productId);
    if (qty <= 0) {
      _cart.remove(item);
    } else {
      item.quantity = qty;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ── Sample Data ──────────────────────────────────────────

  final List<Vendor> vendors = [
    Vendor(id: 'v1', name: 'Mama Pima Fresh Produce', description: 'Fresh vegetables and fruits straight from the farm.', imageUrl: 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400', location: 'Kariakoo Market, Dar es Salaam', category: 'Vegetables & Fruits', rating: 4.8, productCount: 45, isVerified: true),
    Vendor(id: 'v2', name: 'Baba Kuku Butchery', description: 'Fresh meat, chicken and fish daily.', imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400', location: 'Ilala Market, Dar es Salaam', category: 'Meat & Fish', rating: 4.5, productCount: 20, isVerified: true),
    Vendor(id: 'v3', name: 'Zanzibar Spice House', description: 'Authentic Zanzibar spices and herbs.', imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400', location: 'Stone Town, Zanzibar', category: 'Spices', rating: 4.9, productCount: 60, isVerified: true),
    Vendor(id: 'v4', name: 'Kanga & Kitenge Fashion', description: 'Beautiful African fabrics and ready-made clothes.', imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=400', location: 'Mwananyamala, Dar es Salaam', category: 'Fashion', rating: 4.3, productCount: 80),
    Vendor(id: 'v5', name: 'Mapema Electronics', description: 'Quality electronics and accessories.', imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', location: 'Kariakoo, Dar es Salaam', category: 'Electronics', rating: 4.1, productCount: 35),
    Vendor(id: 'v6', name: 'Asali Natural Honey', description: 'Pure natural honey from Tanzania highlands.', imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400', location: 'Arusha, Tanzania', category: 'Natural Products', rating: 4.7, productCount: 15, isVerified: true),
  ];

  List<Product> get products => [
    Product(id: 'p1', name: 'Fresh Tomatoes (1kg)', description: 'Ripe, juicy tomatoes fresh from the farm. Perfect for cooking.', price: 2500, imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400', category: 'Vegetables & Fruits', vendorId: 'v1', vendorName: 'Mama Pima Fresh Produce', rating: 4.8, reviewCount: 124),
    Product(id: 'p2', name: 'Sukuma Wiki Bundle', description: 'Fresh green sukuma wiki, cleaned and ready to cook.', price: 1000, imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400', category: 'Vegetables & Fruits', vendorId: 'v1', vendorName: 'Mama Pima Fresh Produce', rating: 4.6, reviewCount: 89),
    Product(id: 'p3', name: 'Sweet Mango (5pcs)', description: 'Sweet Alphonso mangoes, perfectly ripe.', price: 3000, imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400', category: 'Vegetables & Fruits', vendorId: 'v1', vendorName: 'Mama Pima Fresh Produce', rating: 4.9, reviewCount: 210),
    Product(id: 'p4', name: 'Chicken (Whole)', description: 'Free-range chicken, freshly slaughtered. Approximately 1.5kg.', price: 18000, imageUrl: 'https://images.unsplash.com/photo-1612170153139-6f881ff067e0?w=400', category: 'Meat & Fish', vendorId: 'v2', vendorName: 'Baba Kuku Butchery', rating: 4.5, reviewCount: 67),
    Product(id: 'p5', name: 'Fresh Tilapia Fish', description: 'Lake Victoria tilapia, fresh catch of the day.', price: 12000, imageUrl: 'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400', category: 'Meat & Fish', vendorId: 'v2', vendorName: 'Baba Kuku Butchery', rating: 4.4, reviewCount: 45),
    Product(id: 'p6', name: 'Pilipili Hoho (Red Pepper)', description: 'Authentic Zanzibar red peppers, aromatic and flavourful.', price: 4500, imageUrl: 'https://images.unsplash.com/photo-1583119022894-919a68a3d0e3?w=400', category: 'Spices', vendorId: 'v3', vendorName: 'Zanzibar Spice House', rating: 4.9, reviewCount: 302),
    Product(id: 'p7', name: 'Cardamom (50g)', description: 'Pure Zanzibar cardamom with rich, sweet aroma.', price: 8000, imageUrl: 'https://images.unsplash.com/photo-1599909631359-8a0a9f65b0f0?w=400', category: 'Spices', vendorId: 'v3', vendorName: 'Zanzibar Spice House', rating: 5.0, reviewCount: 178),
    Product(id: 'p8', name: 'Kitenge Fabric (2m)', description: 'Beautiful colourful kitenge fabric, 100% cotton.', price: 15000, imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400', category: 'Fashion', vendorId: 'v4', vendorName: 'Kanga & Kitenge Fashion', rating: 4.3, reviewCount: 55),
    Product(id: 'p9', name: 'Wireless Earbuds', description: 'Quality wireless earbuds with noise cancellation.', price: 45000, imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400', category: 'Electronics', vendorId: 'v5', vendorName: 'Mapema Electronics', rating: 4.1, reviewCount: 33),
    Product(id: 'p10', name: 'Pure Honey (500g)', description: 'Raw unprocessed honey from Tanzania highlands bees.', price: 22000, imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400', category: 'Natural Products', vendorId: 'v6', vendorName: 'Asali Natural Honey', rating: 4.7, reviewCount: 91),
    Product(id: 'p11', name: 'Avocado (3pcs)', description: 'Creamy ripe avocados, perfect for salads or eating plain.', price: 3500, imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400', category: 'Vegetables & Fruits', vendorId: 'v1', vendorName: 'Mama Pima Fresh Produce', rating: 4.7, reviewCount: 150),
    Product(id: 'p12', name: 'USB-C Charging Cable', description: 'Fast-charging 2m USB-C cable, braided and durable.', price: 8500, imageUrl: 'https://images.unsplash.com/photo-1588345921523-c2dcdb7f1dcd?w=400', category: 'Electronics', vendorId: 'v5', vendorName: 'Mapema Electronics', rating: 4.0, reviewCount: 28),
  ];

  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') return products;
    return products.where((p) => p.category == _selectedCategory).toList();
  }

  List<String> get categories => ['All', 'Vegetables & Fruits', 'Meat & Fish', 'Spices', 'Fashion', 'Electronics', 'Natural Products'];
}
