import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/firestore_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: AppTextStyles.headerText,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<CartService>(
          builder: (context, cartService, child) {
            if (cartService.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.quantityStr,
                            style: TextStyle(
                                fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
              color: Theme.of(context).cardColor,
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
                      Text('Total',
                          style: TextStyle(
                              fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      Text('₹ ${cartService.getTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () async {
                      setState(() {
                        _isProcessing = true;
                      });

                      try {
                        final auth = FirebaseAuth.instance;
                        final user = auth.currentUser;
                        
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to checkout'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _isProcessing = false;
                          });
                          return;
                        }

                        final items = cartService.items.map((item) => {
                          'name': item.name,
                          'price': item.price,
                          'quantityStr': item.quantityStr,
                          'quantity': item.quantity,
                          'imageUrl': item.imageUrl,
                        }).toList();

                        final orderData = {
                          'userId': user.uid,
                          'items': items,
                          'totalPrice': cartService.getTotalPrice(),
                          'status': 'placed',
                        };

                        final firestoreService = FirestoreService();
                        
                        try {
                          await firestoreService.addOrder(orderData).timeout(
                            const Duration(seconds: 10),
                            onTimeout: () {
                              throw Exception('Connection timed out. Check your internet or Firebase setup.');
                            },
                          );

                          cartService.clearCart();
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Backend Error: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to validate order: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                           // Ensure processing state is reset if unexpected synchronous throw occurs
                           if (_isProcessing) {
                            setState(() {
                              _isProcessing = false;
                            });
                           }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.grey,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Checkout',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
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
