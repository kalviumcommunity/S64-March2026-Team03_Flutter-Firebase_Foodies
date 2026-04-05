import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/saved_payment_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({Key? key}) : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  SavedPaymentType _selectedType = SavedPaymentType.card;
  bool _isLoading = false;

  // Controllers
  final _cardNoController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _upiIdController = TextEditingController();

  @override
  void dispose() {
    _cardNoController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    _cardHolderController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _saveMethod() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final String label = _selectedType == SavedPaymentType.card
          ? '${_cardHolderController.text} (•••• ${_cardNoController.text.substring(_cardNoController.text.length - 4)})'
          : _upiIdController.text;

      final Map<String, dynamic> data = {
        'type': _selectedType.name,
        'label': label,
        'createdAt': DateTime.now(),
      };

      if (_selectedType == SavedPaymentType.card) {
        data.addAll({
          'lastFour': _cardNoController.text.substring(_cardNoController.text.length - 4),
          'cardHolder': _cardHolderController.text,
          'expiryDate': _expiryController.text,
        });
      } else {
        data.addAll({'upiId': _upiIdController.text});
      }

      await FirestoreService().addPaymentMethod(user.uid, data);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add payment: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Payment', style: AppTextStyles.headerText),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  _typeTab(SavedPaymentType.card, 'Debit/Credit Card', Icons.credit_card),
                  _typeTab(SavedPaymentType.upi, 'UPI ID', Icons.account_balance),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form
            Form(
              key: _formKey,
              child: _selectedType == SavedPaymentType.card ? _buildCardForm() : _buildUpiForm(),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Save Payment Method',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(SavedPaymentType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        _buildTextField(_cardHolderController, 'Card Holder Name', Icons.person_outline, (val) => val == null || val.isEmpty ? 'Required' : null),
        const SizedBox(height: 20),
        _buildTextField(_cardNoController, 'Card Number', Icons.credit_card, (val) => val == null || val.length < 16 ? 'Invalid format' : null, keyboard: TextInputType.number),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(_expiryController, 'MM/YY', Icons.calendar_today, (val) => val == null || val.isEmpty ? 'Required' : null, keyboard: TextInputType.datetime)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField(_cvvController, 'CVV', Icons.lock_outline, (val) => val == null || val.length != 3 ? 'Invalid' : null, keyboard: TextInputType.number, isObscure: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildUpiForm() {
    return Column(
      children: [
        _buildTextField(
          _upiIdController, 
          'UPI ID (e.g. name@bank)', 
          Icons.alternate_email, 
          (val) => val == null || !val.contains('@') ? 'Invalid UPI ID' : null
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Google Pay, PhonePe, and Paytm UPI IDs are supported.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    String? Function(String?) validator, {
    TextInputType keyboard = TextInputType.text,
    bool isObscure = false,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen)),
        filled: true,
        fillColor: theme.cardColor,
      ),
    );
  }
}
