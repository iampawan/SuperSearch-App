class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String brand;
  final double rating;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    required this.rating,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      brand: json['brand'],
      rating: json['rating'].toDouble(),
      inStock: json['in_stock'],
    );
  }
}
