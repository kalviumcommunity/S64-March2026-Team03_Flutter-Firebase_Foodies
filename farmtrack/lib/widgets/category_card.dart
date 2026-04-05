import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color backgroundColor;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Container
          Expanded(
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
