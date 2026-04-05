import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/category_card.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/navigation_provider.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Bakery',
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
      'color': AppColors.categoryBgRed
    },
    {
      'title': 'Breakfast',
      'image': 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?w=200',
      'color': AppColors.categoryBgYellow
    },
    {
      'title': 'Chocolates & Confectionery',
      'image': 'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=200',
      'color': AppColors.categoryBgBlue
    },
    {
      'title': 'Dairy',
      'image': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=200',
      'color': AppColors.categoryBgGreen
    },
    {
      'title': 'Grocery',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
      'color': AppColors.categoryBgYellow
    },
    {
      'title': 'Dry Fruits',
      'image': 'https://images.unsplash.com/photo-1599818816769-cfebff6aae60?w=200',
      'color': AppColors.categoryBgRed
    },
    {
      'title': 'Beverages',
      'image': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=200',
      'color': AppColors.categoryBgBlue
    },
    {
      'title': 'Frozen Foods',
      'image': 'https://images.unsplash.com/photo-1588165171080-c89acfa5ee83?w=200',
      'color': AppColors.categoryBgGreen
    },
    {
      'title': 'Gourmet World',
      'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200',
      'color': AppColors.categoryBgYellow
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: AppTextStyles.sectionTitle,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return CategoryCard(
              title: cat['title'],
              imageUrl: cat['image'],
              backgroundColor: cat['color'],
              onTap: () {
                // Update category and jump to Home tab
                context.read<CategoryProvider>().setCategory(cat['title']);
                context.read<NavigationProvider>().setIndex(0);
              },
            );
          },
        ),
      ),
    );
  }
}
