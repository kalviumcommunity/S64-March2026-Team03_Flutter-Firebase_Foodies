import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'orders_page.dart';
import 'settings_screen.dart';
import 'address/address_screen.dart';
import 'payment/saved_payments_screen.dart';

import 'notifications_page.dart';
import 'chat/chat_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final avatarBg = Theme.of(context).primaryColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: AppTextStyles.headerText,
        ),
        backgroundColor: bgColor,
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: avatarBg,
                          child: const Icon(Icons.person,
                              size: 50, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Settings List
              _buildProfileOption(context, Icons.shopping_bag_outlined, 'My Orders', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(context, Icons.location_on_outlined, 'Delivery Addresses', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(context, Icons.account_balance_wallet_outlined, 'Payment Methods', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedPaymentsScreen()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(context, Icons.notifications_outlined, 'Notifications', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(context, Icons.settings_outlined, 'Settings', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }),
              const Divider(height: 1),
              _buildProfileOption(context, Icons.help_outline, 'Help & Support', onTap: () {
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userId: user.uid,
                        userName: 'FarmFresh Support',
                      ),
                    ),
                  );
                }
              }),
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

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
