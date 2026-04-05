import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onChanged;
  final String? hintText;

  const SearchBarWidget({
    Key? key, 
    this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? 'Search farm fresh items...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryGreen.withOpacity(0.7),
              size: 24,
            ),
            suffixIcon: Icon(
              Icons.tune_rounded, // Filter icon mock
              color: AppColors.primaryGreen.withOpacity(0.7),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),
    );
  }
}
