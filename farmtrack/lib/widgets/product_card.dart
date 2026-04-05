import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String quantity;
  final double price;
  final String imageUrl;
  final VoidCallback onAdd;

  const ProductCard({
    Key? key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if image fails to load
                    return Icon(Icons.fastfood, size: 50, color: Colors.grey[300]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product Name
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Quantity
            Text(
              quantity,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // Price and Add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹ ${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
