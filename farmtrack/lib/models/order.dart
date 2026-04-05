import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.status = "placed",
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String documentId) {
    return Order(
      id: documentId,
      userId: map['userId'] ?? '',
      items: List<CartItem>.from(map['items']?.map((x) => CartItem.fromMap(x)) ?? []),
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'placed',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}
