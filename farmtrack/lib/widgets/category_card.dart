import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Container
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: isSelected 
                    ? Border.all(color: AppColors.primaryGreen, width: 2)
                    : null,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.shopping_basket, color: AppColors.primaryGreen.withOpacity(0.5), size: 40);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label text
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryGreen : Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
