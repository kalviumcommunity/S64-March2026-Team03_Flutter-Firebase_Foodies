import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void createOrder(List<CartItem> cartItems, double totalPrice) {
    if (cartItems.isEmpty) return;

    // We store a copy of the items list so modifying the cart later doesn't alter this placed order
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(cartItems),
      totalPrice: totalPrice,
      status: 'placed',
      createdAt: DateTime.now(),
    );

    _orders.add(newOrder);
    notifyListeners();
  }

  List<Order> getOrders() {
    return _orders;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}
