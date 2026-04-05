import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Existing Form states
  final _formKeyProfile = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoadingProfile = false;
  bool _isSavingProfile = false;
  bool _isSavingPassword = false;

  // New Local Toggle States
  bool _isHindi = false;
  bool _showFarmDetails = true;
  bool _showDeliveryTimeline = true;
  bool _showHarvestInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user == null) return;
    setState(() => _isLoadingProfile = true);
    try {
      final userData = await FirestoreService().getUser(user!.uid);
      if (userData != null) {
        _nameController.text = userData['name']?.toString() ?? user!.displayName ?? '';
        _phoneController.text = userData['phone']?.toString() ?? '';
      } else {
        _nameController.text = user!.displayName ?? '';
      }
    } catch (e) {
      // Ignore if failed to load
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKeyProfile.currentState!.validate()) return;
    if (user == null) return;

    setState(() => _isSavingProfile = true);
    try {
      await FirestoreService().saveUser(user!.uid, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      await user!.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.primaryGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKeyPassword.currentState!.validate()) return;
    if (user == null) return;

    setState(() => _isSavingPassword = true);
    try {
      await user!.updatePassword(_newPasswordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.primaryGreen),
        );
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
       String message = 'Failed to update password.';
       if (e.code == 'requires-recent-login') {
         message = 'Please log out and log in again to update your password.';
       } else if (e.message != null) {
         message = e.message!;
       }
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(message), backgroundColor: AppColors.alertRed),
         );
       }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // UI Helpers

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias, // Ensures children stay inside rounded corners
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
      activeColor: AppColors.primaryGreen,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKeyProfile,
      child: Column(
        children: [
          if (_isLoadingProfile)
            const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingProfile ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSavingProfile 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 2))
                : Text('Save Profile', style: TextStyle(fontSize: 16, color: Theme.of(context).cardColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKeyPassword,
      child: Column(
        children: [
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a new password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingPassword ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSavingPassword 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 2))
                : Text('Update Password', style: TextStyle(fontSize: 16, color: Theme.of(context).cardColor)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.headerText),
        backgroundColor: bgColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // A. Account Section
          _buildSectionHeader('Account'),
          _buildSettingsCard(context, [
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(Icons.person_outline, color: textSecondary),
                title: Text('Edit Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                iconColor: textColor,
                collapsedIconColor: textSecondary,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: _buildProfileForm(),
                  )
                ],
              ),
            ),
            const Divider(height: 1, indent: 16),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(Icons.lock_outline, color: textSecondary),
                title: Text('Change Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                iconColor: textColor,
                collapsedIconColor: textSecondary,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: _buildPasswordForm(),
                  )
                ],
              ),
            ),
          ]),

          // B. Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSettingsCard(context, [
            _buildToggleTile(
              context,
              icon: Icons.language,
              title: 'Hindi Language',
              value: _isHindi,
              onChanged: (val) => setState(() => _isHindi = val),
            ),
            const Divider(height: 1, indent: 16),
            _buildToggleTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ]),

          // C. Privacy & Security Section
          _buildSectionHeader('Privacy & Security'),
          _buildSettingsCard(context, [
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: textSecondary),
              title: Text('Privacy Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon!'), backgroundColor: AppColors.primaryGreen),
                );
              },
            ),
            const Divider(height: 1, indent: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.alertRed),
              title: const Text('Delete Account', style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.w500)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: textColor)),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.currentUser?.delete();
                            if (context.mounted) {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Authentication needed. Please log in again to delete.'), backgroundColor: AppColors.alertRed),
                              );
                            }
                          }
                        },
                        child: const Text('Delete', style: TextStyle(color: AppColors.alertRed)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),

          // D. Transparency Section
          _buildSectionHeader('Transparency Features'),
          _buildSettingsCard(context, [
            _buildToggleTile(
              context,
              icon: Icons.eco_outlined,
              title: 'Show Farm Details',
              value: _showFarmDetails,
              onChanged: (val) => setState(() => _showFarmDetails = val),
            ),
            const Divider(height: 1, indent: 16),
            _buildToggleTile(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Show Delivery Timeline',
              value: _showDeliveryTimeline,
              onChanged: (val) => setState(() => _showDeliveryTimeline = val),
            ),
            const Divider(height: 1, indent: 16),
            _buildToggleTile(
              context,
              icon: Icons.info_outline,
              title: 'Show Harvest Information',
              value: _showHarvestInfo,
              onChanged: (val) => setState(() => _showHarvestInfo = val),
            ),
          ]),

          // E. Support Section
          _buildSectionHeader('Support'),
          _buildSettingsCard(context, [
            ListTile(
              leading: Icon(Icons.help_outline, color: textSecondary),
              title: Text('Help & Support', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!'), backgroundColor: AppColors.primaryGreen),
                );
              },
            ),
            const Divider(height: 1, indent: 16),
            ListTile(
              leading: Icon(Icons.contact_support_outlined, color: textSecondary),
              title: Text('Contact Us', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact Us coming soon!'), backgroundColor: AppColors.primaryGreen),
                );
              },
            ),
          ]),

          const SizedBox(height: 32),

          // F. Logout Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                if (mounted) {
                   Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.alertRed),
              label: const Text('Log Out', style: TextStyle(color: AppColors.alertRed, fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.alertRed, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
