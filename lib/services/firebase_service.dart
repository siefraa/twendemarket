import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Stream<User?> get authStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<void> signOut() => _auth.signOut();

  static Future<void> createUser(AppUser user) =>
      _db.collection('users').doc(user.id).set(user.toMap());

  static Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  static Stream<List<Product>> getProducts({String? category}) {
    Query query = _db.collection('products').where('isAvailable', isEqualTo: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((s) =>
        s.docs.map((d) => Product.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  static Stream<List<Product>> getAllProducts() => _db
      .collection('products')
      .snapshots()
      .map((s) => s.docs.map((d) => Product.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());

  static Future<void> addProduct(Product p) =>
      _db.collection('products').add(p.toMap());

  static Future<void> updateProduct(Product p) =>
      _db.collection('products').doc(p.id).update(p.toMap());

  static Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  static Future<String> placeOrder(Order order) async {
    final ref = await _db.collection('orders').add(order.toMap());
    return ref.id;
  }

  static Stream<List<Order>> getUserOrders(String userId) => _db
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Order.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());

  static Stream<List<Order>> getAllOrders() => _db
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Order.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());

  static Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _db.collection('orders').doc(orderId).update({'status': status.name});

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final orders = await _db.collection('orders').get();
    final users = await _db.collection('users').where('role', isEqualTo: 'user').get();
    final products = await _db.collection('products').get();
    double revenue = 0;
    int delivered = 0;
    int pending = 0;
    for (final doc in orders.docs) {
      final data = doc.data();
      revenue += (data['total'] ?? 0).toDouble();
      if (data['status'] == 'delivered') delivered++;
      if (data['status'] == 'pending') pending++;
    }
    return {
      'totalOrders': orders.size,
      'totalUsers': users.size,
      'totalProducts': products.size,
      'revenue': revenue,
      'delivered': delivered,
      'pending': pending,
    };
  }
}
