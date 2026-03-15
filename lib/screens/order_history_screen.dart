import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingConfirmation:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.canceled:
        return 'Đã hủy';
    }
  }

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
      appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
      body: orders.isEmpty
          ? const Center(child: Text('Chưa có đơn hàng nào'))
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
                          'Đơn #${order.id}',
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
                              label: Text(_statusLabel(order.status)),
                              backgroundColor: _statusColor(
                                order.status,
                              ).withValues(alpha: 0.12),
                              labelStyle: TextStyle(
                                color: _statusColor(order.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Chip(
                              label: Text('${order.items.length} sản phẩm'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        if (order.items.isEmpty)
                          const Text(
                            'Không có thông tin sản phẩm trong đơn này',
                            style: TextStyle(color: Color(0xFF757575)),
                          )
                        else
                          Column(
                            children: order.items
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                item.product.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item.size}, ${item.color} - Số lượng: ${item.quantity}',
                                                style: const TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        PriceText(
                                          item.lineTotal,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFD32F2F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PriceText(order.totalAmount),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
