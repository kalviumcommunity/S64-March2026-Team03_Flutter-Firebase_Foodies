import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../utils/constants.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address', style: AppTextStyles.headerText),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter your name',
                icon: Icons.person_outline,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone number',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your phone number';
                  if (value.length < 10) return 'Please enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressLineController,
                label: 'Address Line',
                hint: 'Enter your full address (flat/house no., area)',
                icon: Icons.location_city_outlined,
                maxLines: 3,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your address';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter city',
                      icon: Icons.map_outlined,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter city';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Enter state',
                      isDark: isDark,
                      icon: Icons.flag_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter state';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                hint: 'Enter 6-digit pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter pincode';
                  if (value.length != 6) return 'Please enter a valid 6-digit pincode';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        final newAddress = Address(
                          id: '', // Will be set in the service/firestore
                          name: _nameController.text,
                          phone: _phoneController.text,
                          addressLine: _addressLineController.text,
                          city: _cityController.text,
                          state: _stateController.text,
                          pincode: _pincodeController.text,
                        );
                        
                        await Provider.of<AddressService>(context, listen: false).addAddress(newAddress);
                        
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Address added successfully!'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add address: $e'),
                              backgroundColor: AppColors.alertRed,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'Save Address',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isDark = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryGreen),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
