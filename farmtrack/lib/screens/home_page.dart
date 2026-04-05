import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Reliable stable images from wikimedia commons to ensure they load
  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Bakery',
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
      'color': AppColors.categoryBgGreen
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
      'color': AppColors.categoryBgRed
    },
    {
      'title': 'Grocery',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
      'color': AppColors.categoryBgGreen
    },
    {
      'title': 'Dry Fruits',
      'image': 'https://images.unsplash.com/photo-1599818816769-cfebff6aae60?w=200',
      'color': AppColors.categoryBgYellow
    },
  ];

  final List<Map<String, dynamic>> _products = const [
    {
      'name': 'Almarai Orange Juice 100% Pure',
      'quantity': '1L',
      'price': 300.00,
      'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=300',
    },
    {
      'name': 'Almarai Treats Strawberry Flavour Milk',
      'quantity': '200ML',
      'price': 75.00,
      'image': 'https://images.unsplash.com/photo-1563636619-e9143ef3082a?w=300',
    },
    {
      'name': 'Organic Brown Bread Slice',
      'quantity': '400g',
      'price': 60.00,
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300',
    },
    {
      'name': 'Fresh Organic Bananas',
      'quantity': '1 Dozen',
      'price': 80.00,
      'image': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and BottomNavigationBar from here since MainScreen handles it.
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SearchBarWidget(),
            const PromoBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: AppTextStyles.sectionTitle,
                  ),
                  Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return CategoryCard(
                    title: cat['title'],
                    imageUrl: cat['image'],
                    backgroundColor: cat['color'],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured This Week 🔥',
                    style: AppTextStyles.sectionTitle,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemBuilder: (context, index) {
                  final prod = _products[index];
                  return ProductCard(
                    name: prod['name'],
                    quantity: prod['quantity'],
                    price: prod['price'],
                    imageUrl: prod['image'],
                    onAdd: () {
                      context.read<CartService>().addToCart(
                        name: prod['name'],
                        quantityStr: prod['quantity'],
                        price: prod['price'],
                        imageUrl: prod['image'],
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${prod['name']} added to cart!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
