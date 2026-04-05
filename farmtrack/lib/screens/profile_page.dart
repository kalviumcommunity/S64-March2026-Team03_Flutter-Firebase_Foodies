import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: user != null ? FirestoreService().getUser(user.uid) : Future.value(null),
                  builder: (context, snapshot) {
                    final userData = snapshot.data;
                    final displayName = userData?['name']?.toString() ?? user?.displayName ?? user?.email ?? 'Guest User';
                    final displayPhone = userData?['phone']?.toString() ?? user?.phoneNumber ?? (user?.uid != null ? 'UID: ${user!.uid}' : 'No UID/Phone');

                    return Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.categoryBgGreen,
                          child: Icon(Icons.person,
                              size: 50, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
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
