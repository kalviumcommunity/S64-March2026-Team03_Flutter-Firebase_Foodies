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
            // Soft Background Container
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : backgroundColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ] : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.eco_rounded, color: AppColors.primaryGreen.withOpacity(0.5), size: 30);
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
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
