import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'admin_home_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final double horizontalPadding = 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F1),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Background Header as a Sliver
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Green Background
                Container(
                  height: 250, // Fixed height for header area
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
                
                // Content inside the Header
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
                        // The Card partially overlapping the bottom
                        _buildInsightsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Clear spacing to avoid overlap with the green curve
          const SliverToBoxAdapter(child: SizedBox(height: 110)), // Significant height to move title out of curve area

          // 3. Operational Tools Title
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Operational Tools',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50), // Contrasting dark text
                ),
              ),
            ),
          ),

          // 4. Grid of Tools
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95, // Ensuring labels aren't cut off
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

  Widget _buildInsightsCard() {
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
                _buildMiniStat('SALES', '₹ 4.2k', Colors.blue),
                _buildMiniStat('VISITS', '1.8k', Colors.orange),
                _buildMiniStat('ALERTS', '2', Colors.red),
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title dashboard coming soon!'), behavior: SnackBarBehavior.floating),
              );
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
