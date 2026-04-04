import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart' as app_models;
import '../models/cart_item.dart';

class OrderService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrder(List<CartItem> cartItems, double totalPrice) async {
    if (cartItems.isEmpty) return;
    
    final user = _auth.currentUser;
    if (user == null) return; // Must be logged in

    try {
      final docRef = _firestore.collection('orders').doc();
      final newOrder = app_models.Order(
        id: docRef.id,
        userId: user.uid,
        items: List.from(cartItems),
        totalPrice: totalPrice,
        status: 'placed',
        createdAt: DateTime.now(),
      );

      await docRef.set(newOrder.toMap());
      // No need to notifyListeners because we'll use StreamBuilder in the UI
    } catch (e) {
      if (kDebugMode) {
        print("Failed to create order: $e");
      }
    }
  }

  Stream<List<app_models.Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => app_models.Order.fromMap(doc.data(), doc.id)).toList();
        });
  }

  Stream<app_models.Order?> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return app_models.Order.fromMap(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update status: $e");
      }
    }
  }
}
