import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
    'placed',
    'packed',
    'dispatched',
    'out_for_delivery',
    'delivered',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order['status'] ?? 'placed';
  }

  // Helper for status colors
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed': return Colors.amber.shade700;
      case 'packed': return Colors.blue.shade700;
      case 'dispatched': return Colors.indigo;
      case 'out_for_delivery': return Colors.orange.shade800;
      case 'delivered': return const Color(0xFF2E7D32);
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await _firestoreService.updateOrderStatus(
        widget.order['id'], 
        _currentStatus, 
        userId: widget.order['userId']
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Status Updated Successfully!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = widget.order['items'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text('Order Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID Card
            _buildInfoCard('Order ID', widget.order['id'], Icons.tag),
            const SizedBox(height: 16),
            _buildInfoCard('Member', widget.order['email'] ?? widget.order['userId'], Icons.person_outline),
            const SizedBox(height: 16),
            _buildInfoCard('Total Value', '₹ ${widget.order['totalPrice']?.toStringAsFixed(2)}', Icons.payments_outlined),
            
            const SizedBox(height: 32),
            
            // Status Transition Section
            Text(
              'Update Workflow Status',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32)),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _getStatusColor(status)),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _currentStatus = val);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Update Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isUpdating 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Commit Update', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 40),

            // Item List Breakdown
            Text(
              'Item Breakdown',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildOrderItemTile(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        children: [
          Text(
            '${item['quantity']}x',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item['name'] ?? 'Generic Item',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '₹ ${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
