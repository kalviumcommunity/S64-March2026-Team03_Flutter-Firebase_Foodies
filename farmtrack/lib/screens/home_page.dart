import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../providers/category_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'All',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
      'color': AppColors.categoryBgGreen
    },
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

  @override
  void initState() {
    super.initState();
    _productService.seedInitialProducts();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final selectedCategory = catProvider.selectedCategory;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            SearchBarWidget(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
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
                  final isSelected = selectedCategory == cat['title'];
                  return CategoryCard(
                    title: cat['title'],
                    imageUrl: cat['image'],
                    backgroundColor: cat['color'],
                    isSelected: isSelected,
                    onTap: () {
                      catProvider.setCategory(cat['title']);
                    },
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
                  Text(
                    selectedCategory == 'All' ? 'Featured This Week 🔥' : '$selectedCategory Items',
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
            StreamBuilder<List<Product>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<Product> products = snapshot.data ?? [];

                // Filter by category
                if (selectedCategory != 'All') {
                  products = products.where((p) => p.category == selectedCategory).toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      return ProductCard(
                        name: prod.name,
                        quantity: prod.quantity,
                        price: prod.price,
                        imageUrl: prod.image,
                        onAdd: () {
                          context.read<CartService>().addToCart(
                            name: prod.name,
                            quantityStr: prod.quantity,
                            price: prod.price,
                            imageUrl: prod.image,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${prod.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
