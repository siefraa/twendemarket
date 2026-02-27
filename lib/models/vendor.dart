class Vendor {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final String category;
  final double rating;
  final int productCount;
  final bool isVerified;

  Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.category,
    this.rating = 4.0,
    this.productCount = 0,
    this.isVerified = false,
  });
}
