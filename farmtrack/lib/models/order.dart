import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    this.status = "placed",
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
