class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final int stock;
  final String quantity; // Added to match existing UI

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.stock,
    required this.quantity,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      stock: data['stock'] ?? 0,
      quantity: data['quantity'] ?? '1 unit',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'stock': stock,
      'quantity': quantity,
    };
  }
}
