import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Stylized Leaf Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Typographic Logo
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        letterSpacing: -1,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E4D1A), // Deep Forest Green
                          ),
                        ),
                        TextSpan(
                          text: 'Fresh',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen, // Lighter Brand Green
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // User Avatar Placeholder with subtle shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
