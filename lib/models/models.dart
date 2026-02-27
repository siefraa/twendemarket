// ─── User Model ───────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'user' | 'admin'
  final String? photoUrl;
  final List<String> addresses;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'user',
    this.photoUrl,
    this.addresses = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) => AppUser(
        id: id,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        role: map['role'] ?? 'user',
        photoUrl: map['photoUrl'],
        addresses: List<String>.from(map['addresses'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'photoUrl': photoUrl,
        'addresses': addresses,
      };

  bool get isAdmin => role == 'admin';
}

// ─── Product Model ────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) => Product(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        category: map['category'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        isAvailable: map['isAvailable'] ?? true,
        rating: (map['rating'] ?? 0).toDouble(),
        reviewCount: map['reviewCount'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'rating': rating,
        'reviewCount': reviewCount,
      };
}

// ─── Cart Item ────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}

// ─── Order Model ──────────────────────────────────────────────
enum OrderStatus { pending, confirmed, preparing, onTheWay, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.onTheWay: return 'On the Way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
  String get emoji {
    switch (this) {
      case OrderStatus.pending: return 'clock';
      case OrderStatus.confirmed: return 'check';
      case OrderStatus.preparing: return 'cook';
      case OrderStatus.onTheWay: return 'bike';
      case OrderStatus.delivered: return 'party';
      case OrderStatus.cancelled: return 'cross';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: m['productId'],
        productName: m['productName'],
        price: (m['price'] ?? 0).toDouble(),
        quantity: m['quantity'] ?? 1,
        imageUrl: m['imageUrl'] ?? '',
      );
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double total;
  final String address;
  final OrderStatus status;
  final DateTime createdAt;
  final String? deliveryNote;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.total,
    required this.address,
    required this.status,
    required this.createdAt,
    this.deliveryNote,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) => Order(
        id: id,
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        items: (map['items'] as List? ?? []).map((e) => OrderItem.fromMap(e)).toList(),
        total: (map['total'] ?? 0).toDouble(),
        address: map['address'] ?? '',
        status: OrderStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => OrderStatus.pending,
        ),
        createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
        deliveryNote: map['deliveryNote'],
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'address': address,
        'status': status.name,
        'createdAt': createdAt,
        'deliveryNote': deliveryNote,
      };
}
