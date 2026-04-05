import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Bakery',
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      'icon': Icons.bakery_dining_rounded,
      'items': '24 items'
    },
    {
      'title': 'Breakfast',
      'image': 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?w=400',
      'icon': Icons.breakfast_dining_rounded,
      'items': '18 items'
    },
    {
      'title': 'Dairy',
      'image': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400',
      'icon': Icons.local_drink_rounded,
      'items': '32 items'
    },
    {
      'title': 'Beverages',
      'image': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
      'icon': Icons.coffee_rounded,
      'items': '45 items'
    },
    {
      'title': 'Frozen Foods',
      'image': 'https://images.unsplash.com/photo-1588165171080-c89acfa5ee83?w=400',
      'icon': Icons.ac_unit_rounded,
      'items': '12 items'
    },
    {
      'title': 'Grocery',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      'icon': Icons.shopping_basket_rounded,
      'items': '150+ items'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Explore Categories',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: const Color(0xFF1B3022),
            letterSpacing: -1.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              radius: 18,
              child: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // 1. Focused Featured Category Card
              _buildFeaturedCard(context),
              
              const SizedBox(height: 32),
              
              // 2. Focused Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Departments',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B3022),
                    ),
                  ),
                  Text(
                    'View Patterns',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 3. Immersive 2-column Grid
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryCard(context, cat);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CategoryProvider>().setCategory('Grocery');
        context.read<NavigationProvider>().setIndex(0);
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1542838132-92c53300491e?w=800'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Featured Collection',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Organic Farm Fresh\nEveryday Essentials',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        context.read<CategoryProvider>().setCategory(cat['title']);
        context.read<NavigationProvider>().setIndex(0);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBF9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
        ),
        child: Column(
          children: [
            // Image with focused padding
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: NetworkImage(cat['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Minimalist Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(cat['icon'], size: 14, color: AppColors.primaryGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cat['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B3022),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['items'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
