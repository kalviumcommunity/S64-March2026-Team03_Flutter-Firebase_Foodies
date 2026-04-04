import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return 0;
      case 'packed':
        return 1;
      case 'out for delivery':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    final shortId = order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Order Details', style: AppTextStyles.headerText),
        backgroundColor: AppColors.backgroundWhite,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(shortId, dateStr),
              const SizedBox(height: 24),
              
              const Text('Track Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildTimelineCard(),
              const SizedBox(height: 24),

              const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildItemsCard(),
              const SizedBox(height: 24),

              const Text('Delivery Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildDeliveryInfoCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String shortId, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order ID', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('#$shortId', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Date', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white30, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              Text('₹${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final stages = [
      {'title': 'Order Placed', 'icon': Icons.receipt_long},
      {'title': 'Packed', 'icon': Icons.inventory_2_outlined},
      {'title': 'Out for Delivery', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivered', 'icon': Icons.check_circle_outline},
    ];
    int currentIndex = _getStepIndex(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          return _buildTimelineStage(
            title: stages[index]['title'] as String,
            icon: stages[index]['icon'] as IconData,
            isCompleted: index <= currentIndex,
            isCurrent: index == currentIndex,
            isLast: index == stages.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineStage({
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryGreen : Colors.white,
                shape: BoxShape.circle,
                border: isCompleted 
                    ? null 
                    : Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: isCurrent 
                    ? [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] 
                    : null,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey.shade400,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              if (isCurrent)
                Text(
                  'In Progress',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: order.items.map((item) {
          final isLast = order.items.last == item;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('₹${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen)),
                ],
              ),
              if (!isLast) const Divider(height: 24, color: Colors.black12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Delivery', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('Today, 4:00 PM - 5:00 PM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farm Transparency', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('Sourced from local farms 🌱', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    SizedBox(height: 2),
                    Text('Freshly harvested this morning to ensure origin quality.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
