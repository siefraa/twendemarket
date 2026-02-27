import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../theme.dart';

// ─── Auth Provider ───────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isAdmin => _user?.role == AppConstants.roleAdmin;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _fetchUser(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _fetchUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      _user = UserModel.fromFirestore(doc);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final newUser = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
      );
      await _db
          .collection(AppConstants.usersCollection)
          .doc(cred.user!.uid)
          .set(newUser.toMap());
      _user = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Invalid email address.';
      default: return 'An error occurred. Please try again.';
    }
  }
}

// ─── Cart Provider ───────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  double get deliveryFee => subtotal > 0 ? (subtotal > 5000 ? 0 : 500) : 0;
  double get total => subtotal + deliveryFee;

  bool containsProduct(String productId) =>
      _items.any((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final item = _items.where((i) => i.product.id == productId);
    return item.isEmpty ? 0 : item.first.quantity;
  }

  void addItem(ProductModel product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
    }
    notifyListeners();
  }

  void deleteItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// ─── Products Provider ───────────────────────────────────────
class ProductsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  List<ProductModel> get products => _filteredProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<ProductModel> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != 'all') {
      list = list.where((p) => p.categoryId == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  List<ProductModel> get featuredProducts =>
      _products.where((p) => p.rating >= 4.0).take(6).toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db
          .collection(AppConstants.productsCollection)
          .where('isAvailable', isEqualTo: true)
          .get();
      _products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final snapshot =
          await _db.collection(AppConstants.categoriesCollection).get();
      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  void setCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Admin: Add / update / delete
  Future<void> addProduct(ProductModel product) async {
    await _db
        .collection(AppConstants.productsCollection)
        .add(product.toMap());
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db
        .collection(AppConstants.productsCollection)
        .doc(product.id)
        .update(product.toMap());
    await loadProducts();
  }

  Future<void> deleteProduct(String productId) async {
    await _db
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .delete();
    await loadProducts();
  }
}

// ─── Orders Provider ─────────────────────────────────────────
class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<OrderModel> _userOrders = [];
  List<OrderModel> _allOrders = [];
  bool _isLoading = false;

  List<OrderModel> get userOrders => _userOrders;
  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;

  // Stats for admin
  int get totalOrders => _allOrders.length;
  int get pendingOrders =>
      _allOrders.where((o) => o.status == AppConstants.orderPending).length;
  double get totalRevenue =>
      _allOrders.where((o) => o.status == AppConstants.orderDelivered)
          .fold(0.0, (sum, o) => sum + o.total);

  Future<String> placeOrder({
    required String userId,
    required String userName,
    required String userPhone,
    required List<CartItem> items,
    required AddressModel deliveryAddress,
    required double subtotal,
    required double deliveryFee,
    required String paymentMethod,
    String? notes,
  }) async {
    final order = OrderModel(
      id: '',
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      items: items
          .map((c) => OrderItem(
                productId: c.product.id,
                productName: c.product.name,
                productImage: c.product.imageUrls.isNotEmpty
                    ? c.product.imageUrls.first
                    : '',
                price: c.product.effectivePrice,
                quantity: c.quantity,
                unit: c.product.unit,
              ))
          .toList(),
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      status: AppConstants.orderPending,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 45)),
    );

    final ref = await _db
        .collection(AppConstants.ordersCollection)
        .add(order.toMap());
    return ref.id;
  }

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _userOrders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true)
          .get();
      _allOrders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status});
    await loadAllOrders();
  }

  Stream<DocumentSnapshot> orderStream(String orderId) =>
      _db.collection(AppConstants.ordersCollection).doc(orderId).snapshots();
}
