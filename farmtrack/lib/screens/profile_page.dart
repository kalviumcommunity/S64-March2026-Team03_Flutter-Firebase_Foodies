import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: AppTextStyles.headerText,
        ),
        backgroundColor: AppColors.backgroundWhite,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Avatar ID Card
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.categoryBgGreen,
                      child: Icon(Icons.person,
                          size: 50, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jane Doe',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '+91 98765 43210',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Settings List
              _buildProfileOption(Icons.shopping_bag_outlined, 'My Orders', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(Icons.location_on_outlined, 'Delivery Addresses'),
              const Divider(height: 1),
              _buildProfileOption(Icons.account_balance_wallet_outlined, 'Payment Methods'),
              const Divider(height: 1),
              _buildProfileOption(Icons.notifications_outlined, 'Notifications'),
              const Divider(height: 1),
              _buildProfileOption(Icons.settings_outlined, 'Settings'),
              const Divider(height: 1),
              _buildProfileOption(Icons.help_outline, 'Help & Support'),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                  },
                  icon: const Icon(Icons.logout, color: AppColors.alertRed),
                  label: const Text('Log Out',
                      style: TextStyle(color: AppColors.alertRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.alertRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
