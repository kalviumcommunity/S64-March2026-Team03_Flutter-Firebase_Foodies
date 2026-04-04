import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference string for ease of use
  final String _ordersCollection = 'orders';

  /// Adds a new order to Firestore.
  /// Generates an ID and includes a server timestamp.
  Future<String> addOrder(Map<String, dynamic> orderData) async {
    try {
      // Add server-side timestamp for consistent ordering
      if (!orderData.containsKey('createdAt')) {
        orderData['createdAt'] = FieldValue.serverTimestamp();
      }

      DocumentReference docRef = await _db.collection(_ordersCollection).add(orderData);
      return docRef.id;
    } catch (e) {
      print('Error in addOrder: $e');
      throw Exception('Failed to add order to backend.');
    }
  }

  /// Gets a real-time stream of all orders.
  /// Typically, you would filter this by userId or restaurantId depending on the app's needs.
  Stream<QuerySnapshot<Map<String, dynamic>>> getOrders() {
    try {
      return _db
          .collection(_ordersCollection)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error in getOrders: $e');
      // Streams don't throw exceptions in the same way Futures do, but handling query setup errors
      throw Exception('Failed to fetch orders stream.');
    }
  }

  /// Gets a real-time stream for a specific order by its document ID.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getOrderById(String id) {
    try {
      return _db.collection(_ordersCollection).doc(id).snapshots();
    } catch (e) {
      print('Error in getOrderById: $e');
      throw Exception('Failed to fetch order stream.');
    }
  }

  /// Updates the status field of a specific order.
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _db.collection(_ordersCollection).doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error in updateOrderStatus: $e');
      throw Exception('Failed to update order status.');
    }
  }
}
