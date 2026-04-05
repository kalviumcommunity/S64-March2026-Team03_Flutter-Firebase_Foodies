import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/payment_method.dart';
import '../../services/payment_service.dart';
import '../../services/cart_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import './order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Icon for each payment type ──────────────────────────────────────────
  IconData _iconFor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cashOnDelivery:
        return Icons.money;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.upi:
        return Icons.account_balance;
    }
  }

  // ── Accent colour per method ────────────────────────────────────────────
  Color _accentFor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cashOnDelivery:
        return const Color(0xFF4CAF50); // green
      case PaymentMethodType.card:
        return const Color(0xFF5C6BC0); // indigo
      case PaymentMethodType.upi:
        return const Color(0xFF7C4DFF); // deep purple
    }
  }

  // ── Place order ─────────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    // Proactively unfocus to avoid "inactive element" focus errors on Web
    FocusManager.instance.primaryFocus?.unfocus();

    final paymentService =
        Provider.of<PaymentService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);

    if (!paymentService.hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to place an order'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final items = cartService.items
          .map((item) => {
                'name': item.name,
                'price': item.price,
                'quantityStr': item.quantityStr,
                'quantity': item.quantity,
                'imageUrl': item.imageUrl,
              })
          .toList();

      final orderData = {
        'userId': user.uid,
        'items': items,
        'totalPrice': cartService.getTotalPrice(),
        'status': 'placed',
        'paymentMethod': paymentService.selectedMethod!.firestoreKey,
      };

      final firestoreService = FirestoreService();
      final orderId = await firestoreService.addOrder(orderData).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
                'Connection timed out. Check your internet connection.'),
          );

      // Clear cart before any navigation
      cartService.clearCart();

      if (mounted) {
        setState(() => _isProcessing = false);

        // Capture necessary data before clearing state
        final selectedMethodLabel = paymentService.selectedMethod!.label;
        final totalPrice = cartService.getTotalPrice();

        // Replace checkout flow with confirmation screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderId: orderId,
              totalPrice: totalPrice,
              paymentMethod: selectedMethodLabel,
            ),
          ),
          (route) => false,
        );

        // clearSelection safely after the navigation capture
        paymentService.clearSelection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Payment', style: AppTextStyles.headerText),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select how you\'d like to pay for your order',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Payment options
              ...PaymentMethodType.values.map(
                (type) => _buildPaymentTile(type, isDark, theme),
              ),

              const SizedBox(height: 16),

              // Order summary
              _buildOrderSummary(theme),
            ],
          ),
        ),
      ),

      // Bottom bar — Place Order button
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Payment option tile ─────────────────────────────────────────────────
  Widget _buildPaymentTile(
      PaymentMethodType type, bool isDark, ThemeData theme) {
    return Consumer<PaymentService>(
      builder: (context, paymentService, _) {
        final isSelected = paymentService.selectedMethod == type;
        final accent = _accentFor(type);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => paymentService.selectMethod(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withOpacity(isDark ? 0.15 : 0.07)
                    : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade200),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent.withOpacity(isDark ? 0.3 : 0.15)
                          : (isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconFor(type),
                      color: isSelected
                          ? accent
                          : theme.colorScheme.onSurfaceVariant,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Label + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? accent
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Radio indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? accent
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Order summary ───────────────────────────────────────────────────────
  Widget _buildOrderSummary(ThemeData theme) {
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _summaryRow(
                  'Items', '${cartService.items.length}', theme),
              const SizedBox(height: 8),
              _summaryRow(
                'Total',
                '₹ ${cartService.getTotalPrice().toStringAsFixed(2)}',
                theme,
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold
                  ? AppColors.primaryGreen
                  : theme.colorScheme.onSurface,
            )),
      ],
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────
  // NOTE: theme is read fresh inside the Consumer so it's never stale.
  Widget _buildBottomBar() {
    return Consumer<PaymentService>(
      builder: (context, paymentService, _) {
        final barTheme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: barTheme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    (_isProcessing || !paymentService.hasSelection)
                        ? null
                        : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor:
                      AppColors.primaryGreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        paymentService.hasSelection
                            ? 'Place Order — ${paymentService.selectedMethod!.label}'
                            : 'Select a payment method',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}


