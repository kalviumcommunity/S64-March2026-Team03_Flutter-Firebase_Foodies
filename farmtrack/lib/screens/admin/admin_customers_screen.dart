import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text('Customer Base', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
       ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getUsers(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          // Create a more reliable map of UserId -> UserData (email, etc)
          final usersList = userSnapshot.data?.docs ?? [];
          Map<String, Map<String, dynamic>> userMap = {};
          for (var doc in usersList) {
            userMap[doc.id] = doc.data();
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreService.getOrders(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
              }

              final orders = orderSnapshot.data?.docs ?? [];
              
              // Aggregate customer data from orders
              Map<String, Map<String, dynamic>> customerStats = {};
              
              for (var doc in orders) {
                final data = doc.data();
                final String userId = data['userId'] ?? 'unknown';
                
                // Fetch email from the User Map (joined from users collection)
                // Fallback to order's email if missing in user doc, or placeholder
                final String email = userMap[userId]?['email'] ?? 
                                     data['email'] ?? 
                                     'No Email Info';
                
                final double price = (data['totalPrice'] ?? 0.0);

                if (!customerStats.containsKey(userId)) {
                  customerStats[userId] = {
                    'email': email,
                    'orderCount': 0,
                    'totalSpent': 0.0,
                  };
                }
                
                customerStats[userId]!['orderCount'] += 1;
                customerStats[userId]!['totalSpent'] += price;
              }

              final customers = customerStats.values.toList();

              if (customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No active customers yet.',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return _buildCustomerCard(customer);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              (customer['email'] as String).isNotEmpty ? (customer['email'] as String).substring(0, 1).toUpperCase() : '?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1B5E20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['email'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF2C3E50)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${customer['orderCount']} Orders placed',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Spent',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
              ),
              Text(
                '₹ ${customer['totalSpent'].toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2E7D32)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
