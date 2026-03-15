import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingConfirmation:
        return const Color(0xFFE67E22);
      case OrderStatus.shipping:
        return const Color(0xFF1976D2);
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.canceled:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final order = orders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.createdAt),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: <Widget>[
                            Chip(
                              label: Text(order.status.name),
                              backgroundColor: _statusColor(
                                order.status,
                              ).withValues(alpha: 0.12),
                              labelStyle: TextStyle(
                                color: _statusColor(order.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Chip(label: Text('${order.items.length} items')),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PriceText(order.totalAmount),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
