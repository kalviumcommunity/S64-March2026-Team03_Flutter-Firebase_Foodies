import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  void _startMarquee() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        if (currentScroll >= maxScroll) {
          // Jump back instantly to create a seamless loop
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + 2); // Move 2 pixels per frame
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, Color(0xFF4A6B2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                "🌿 One Stop Shop For All Your Fresh Farm Needs!!",
                style: AppTextStyles.bannerText.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 80),
              Text(
                "🌿 One Stop Shop For All Your Fresh Farm Needs!!",
                style: AppTextStyles.bannerText.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ),
      ),
    );
  }
}
