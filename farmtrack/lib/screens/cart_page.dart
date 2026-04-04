import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: AppTextStyles.headerText,
        ),
        backgroundColor: AppColors.backgroundWhite,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<CartService>(
          builder: (context, cartService, child) {
            if (cartService.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: cartService.items.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = cartService.items[index];
                return Row(
                  children: [
                    // Item Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.fastfood, color: AppColors.primaryGreen),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Item Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.quantityStr,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹ ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                    // Quantity controls
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            cartService.decreaseQuantity(item);
                          },
                          icon: const Icon(Icons.remove_circle_outline)
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        IconButton(
                          onPressed: () {
                            cartService.increaseQuantity(item);
                          },
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primaryGreen)
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.items.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textSecondary)),
                      Text('₹ ${cartService.getTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final orderProvider = Provider.of<OrderService>(context, listen: false);
                      orderProvider.createOrder(cartService.items, cartService.getTotalPrice());
                      cartService.clearCart();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Checkout',
                        style: TextStyle(fontSize: 16, color: AppColors.textLight)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
