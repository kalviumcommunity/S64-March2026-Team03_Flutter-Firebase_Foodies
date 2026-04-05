import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text('Business Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          final orders = snapshot.data?.docs ?? [];
          int delivered = orders.where((doc) => (doc.data())['status'] == 'delivered').length;
          int pending = orders.length - delivered;
          double totalRevenue = orders.fold(0.0, (sum, doc) => sum + ((doc.data())['totalPrice'] ?? 0.0));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Performance Snapshot',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 24),
                
                // Revenue Hero Card
                _buildRevenueCard(totalRevenue),
                
                const SizedBox(height: 24),
                
                // Detailed Metrics Grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMetricCard('Total Volume', orders.length.toString(), Icons.shopping_cart_rounded, Colors.blue),
                    _buildMetricCard('Successful', delivered.toString(), Icons.check_circle_rounded, Colors.green),
                    _buildMetricCard('In Progress', pending.toString(), Icons.pending_actions_rounded, Colors.orange),
                    _buildMetricCard('Avg Value', '₹ ${(orders.isEmpty ? 0 : totalRevenue / orders.length).toStringAsFixed(1)}', Icons.analytics_rounded, Colors.purple),
                  ],
                ),
                
                const Spacer(),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Advanced charts and predictive insights are under development.',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL GROSS REVENUE',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            '₹ ${revenue.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            val,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
