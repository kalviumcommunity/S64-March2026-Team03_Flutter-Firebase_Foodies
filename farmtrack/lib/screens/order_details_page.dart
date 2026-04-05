import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../services/order_service.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Details', style: AppTextStyles.headerText),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: StreamBuilder<Order?>(
          stream: Provider.of<OrderService>(context, listen: false).getOrderStream(order.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }

            final currentOrder = snapshot.data ?? order;

            final dateStr = '${currentOrder.createdAt.day}/${currentOrder.createdAt.month}/${currentOrder.createdAt.year} ${currentOrder.createdAt.hour}:${currentOrder.createdAt.minute.toString().padLeft(2, '0')}';
            final shortId = currentOrder.id.substring(currentOrder.id.length > 6 ? currentOrder.id.length - 6 : 0);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, currentOrder, shortId, dateStr),
                  const SizedBox(height: 24),
                  
                  Text('Track Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildTimelineCard(context, currentOrder),
                  const SizedBox(height: 24),

                  Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildItemsCard(context, currentOrder),
                  const SizedBox(height: 24),

                  Text('Delivery Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildDeliveryInfoCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Order currentOrder, String shortId, String dateStr) {
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
              Text('₹${currentOrder.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Order currentOrder) {
    final stages = [
      {'title': 'Order Placed', 'icon': Icons.receipt_long},
      {'title': 'Packed', 'icon': Icons.inventory_2_outlined},
      {'title': 'Out for Delivery', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivered', 'icon': Icons.check_circle_outline},
    ];
    int currentIndex = _getStepIndex(currentOrder.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          return _buildTimelineStage(
            context: context,
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
    required BuildContext context,
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
                color: isCompleted ? AppColors.primaryGreen : Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: isCompleted 
                    ? null 
                    : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 2),
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
                  color: isCompleted ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (isCurrent)
                const Text(
                  'In Progress',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard(BuildContext context, Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: currentOrder.items.map((item) {
          final isLast = currentOrder.items.last == item;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                        Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('Qty: ${item.quantity}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildDeliveryInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Delivery', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Today, 4:00 PM - 5:00 PM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farm Transparency', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Sourced from local farms 🌱', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    const SizedBox(height: 2),
                    Text('Freshly harvested this morning to ensure origin quality.', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
