import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'admin_home_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_placeholder_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final double horizontalPadding = 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F1),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getOrders(),
        builder: (context, orderSnapshot) {
          // Calculate dynamic metrics from orders
          final orders = orderSnapshot.data?.docs ?? [];
          double totalRevenue = 0;
          int alerts = 0;

          for (var doc in orders) {
            final data = doc.data();
            totalRevenue += (data['totalPrice'] ?? 0.0);
            if (data['status'] == 'placed' || data['status'] == 'packed') {
              alerts++;
            }
          }

          // Format revenue for display
          String revenueDisplay = totalRevenue >= 1000 
              ? '₹ ${(totalRevenue / 1000).toStringAsFixed(1)}k' 
              : '₹ ${totalRevenue.toStringAsFixed(0)}';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sleek Background Header
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Control Center',
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'FarmTrack Administrator',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.power_settings_new, color: Colors.white),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Sign Out'),
                                          content: const Text('Close admin session?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) await authService.signOut();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            StreamBuilder<QuerySnapshot>(
                              stream: firestoreService.getUsers(),
                              builder: (context, userSnapshot) {
                                final userCount = userSnapshot.data?.docs.length ?? 0;
                                return _buildInsightsCard(revenueDisplay, userCount, alerts);
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Operational Tools',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildEnhancedToolCard(context, 'Orders', Icons.shopping_cart_checkout_rounded, const Color(0xFF4CAF50)),
                    _buildEnhancedToolCard(context, 'Analytics', Icons.analytics_rounded, const Color(0xFF2196F3)),
                    _buildEnhancedToolCard(context, 'Customers', Icons.groups_rounded, const Color(0xFF9C27B0)),
                    _buildEnhancedToolCard(context, 'Inventory', Icons.warehouse_rounded, const Color(0xFFFF9800)),
                    _buildEnhancedToolCard(context, 'Live Stats', Icons.sensors_rounded, const Color(0xFF607D8B)),
                    _buildEnhancedToolCard(context, 'Support', Icons.help_center_rounded, const Color(0xFFE91E63)),
                  ]),
                ),
              ),
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 6,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text('Action', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInsightsCard(String sales, int customers, int alerts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin&background=E8F5E9&color=2E7D32'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Day, Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Store is 94% efficient today.',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('SALES', sales, Colors.blue),
                _buildMiniStat('CUSTOMERS', customers.toString(), Colors.orange),
                _buildMiniStat('ALERTS', alerts.toString(), Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ],
    );
  }

  Widget _buildEnhancedToolCard(BuildContext context, String title, IconData icon, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == 'Orders') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
            } else if (title == 'Analytics') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAnalyticsScreen()));
            } else if (title == 'Customers') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCustomersScreen()));
            } else if (title == 'Inventory') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPlaceholderScreen(
                title: 'Warehouse Control',
                message: 'Inventory & Stock management coming soon',
                icon: Icons.warehouse_rounded,
              )));
            } else if (title == 'Live Stats') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPlaceholderScreen(
                title: 'Live Telemetry',
                message: 'Real-time store traffic & heatmaps coming soon',
                icon: Icons.sensors_rounded,
              )));
            } else if (title == 'Support') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminChatListScreen()));
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF2C3E50)),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
