class CartItem {
  final String name;
  final String quantityStr;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.name,
    required this.quantityStr,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantityStr': quantityStr,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] ?? '',
      quantityStr: map['quantityStr'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 1,
    );
  }
}
