import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const List<OrderStatus> _tabStatuses = <OrderStatus>[
    OrderStatus.pendingConfirmation,
    OrderStatus.shipping,
    OrderStatus.delivered,
    OrderStatus.canceled,
  ];

  Future<String?> _showCancelReasonDialog(
    BuildContext context,
    String orderId,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CancelOrderDialog(orderId: orderId);
      },
    );
  }

  bool _canCancelOrder(Order order) {
    return order.status == OrderStatus.pendingConfirmation;
  }

  Future<void> _cancelOrder(BuildContext context, Order order) async {
    final reason = await _showCancelReasonDialog(context, order.id);

    if (reason == null || !context.mounted) {
      return;
    }

    final didCancel = await context.read<OrderProvider>().cancelOrder(
      order.id,
      reason,
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            didCancel
                ? 'Đơn hàng đã được hủy thành công'
                : 'Không thể hủy đơn hàng này',
          ),
        ),
      );
  }

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

  Widget _buildOrderListByStatus(BuildContext context, OrderStatus status) {
    final orders = context.watch<OrderProvider>().orders;
    final filteredOrders = orders
        .where((order) => order.status == status)
        .toList(growable: false);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text('Chưa có đơn ${_statusLabel(status).toLowerCase()}'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final order = filteredOrders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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
            Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
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
                Chip(label: Text('${order.items.length} sản phẩm')),
                if (_canCancelOrder(order))
                  ActionChip(
                    avatar: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Color(0xFFD32F2F),
                    ),
                    label: const Text('Hủy đơn'),
                    labelStyle: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                    ),
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    backgroundColor: const Color(0xFFFFEBEE),
                    onPressed: () => _cancelOrder(context, order),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
            if (order.status == OrderStatus.canceled &&
                order.cancellationReason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Lý do hủy: ${order.cancellationReason}',
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: PriceText(order.totalAmount),
            ),
          ],
        ),
      ),
    );
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
    return DefaultTabController(
      length: _tabStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử đơn hàng'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabStatuses
                .map((status) => Tab(text: _statusLabel(status)))
                .toList(growable: false),
          ),
        ),
        body: TabBarView(
          children: _tabStatuses
              .map((status) => _buildOrderListByStatus(context, status))
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _CancelOrderDialog extends StatefulWidget {
  const _CancelOrderDialog({required this.orderId});

  final String orderId;

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  late final TextEditingController _reasonController;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirmCancel() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hủy đơn hàng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Vui lòng nhập lý do hủy đơn #${widget.orderId}'),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Đổi địa chỉ nhận hàng',
              border: const OutlineInputBorder(),
              errorText: _showError ? 'Bạn cần nhập lý do hủy đơn' : null,
            ),
            onChanged: (_) {
              if (_showError) {
                setState(() {
                  _showError = false;
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Không'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
          ),
          onPressed: _confirmCancel,
          child: const Text('Xác nhận hủy'),
        ),
      ],
    );
  }
}
