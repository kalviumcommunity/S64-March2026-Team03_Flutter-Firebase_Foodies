import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../utils/constants.dart';
import 'add_address_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<AddressService>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses', style: AppTextStyles.headerText),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // ── StreamBuilder listens directly to Firestore in real-time ──
      body: StreamBuilder<List<Address>>(
        stream: service.addressesStream(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading addresses.\nPlease try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            );
          }

          final addresses = snapshot.data ?? [];

          // User not logged in
          if (FirebaseAuth.instance.currentUser == null) {
            return const Center(child: Text('Please log in to view addresses.'));
          }

          // Empty state
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved addresses yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add New Address" below to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Determine default address id
          final defaultId = addresses
              .firstWhere(
                (a) => a.isDefault,
                orElse: () => addresses.first,
              )
              .id;

          // Address list
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isDefault = address.id == defaultId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: isDefault ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    side: isDefault
                        ? const BorderSide(
                            color: AppColors.primaryGreen, width: 2)
                        : BorderSide.none,
                  ),
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name + badge + menu ──
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      address.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  if (isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  _showDeleteDialog(context, service, address.id);
                                } else if (value == 'set_default') {
                                  try {
                                    await service.setDefaultAddress(address.id);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'set_default',
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_border,
                                          size: 18,
                                          color: AppColors.primaryGreen),
                                      SizedBox(width: 8),
                                      Text('Set as Default'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          size: 18, color: AppColors.alertRed),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.alertRed)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // ── Phone ──
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              address.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── Full address ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${address.addressLine}, ${address.city}, '
                                '${address.state} - ${address.pincode}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add New Address',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, AddressService service, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to remove this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await service.deleteAddress(id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }
}
