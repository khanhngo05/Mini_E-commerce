import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    // Người 4: Đảm bảo chỉ những món được tick chọn mới được đưa vào đơn hàng
    // (Hoặc nếu nhóm quy định đặt toàn bộ giỏ thì giữ nguyên cartProvider.items)
    final selectedItems = cartProvider.items.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm trong giỏ hàng để thanh toán')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      items: selectedItems, // Truyền danh sách đã chọn
      shippingAddress: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
      status: OrderStatus.pendingConfirmation,
      createdAt: DateTime.now(),
    );

    orderProvider.addOrder(order);
    
    // Xóa những món ĐÃ ĐẶT khỏi giỏ hàng
    for (var item in selectedItems) {
      cartProvider.removeItem(item.id);
    }

    if (!mounted) return;

    // Chuyển hướng về lịch sử đơn hàng
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.orderHistory,
      (route) => route.settings.name == AppRouter.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch để cập nhật tổng tiền realtime
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ nhận hàng',
              hintText: 'Nhập số nhà, tên đường, phường/xã...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _paymentMethod, // Dùng value thay cho initialValue để state nhạy hơn
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'COD', child: Text('Thanh toán khi nhận hàng (COD)')),
              DropdownMenuItem(value: 'Card', child: Text('Thẻ tín dụng / Ghi nợ')),
            ],
            decoration: const InputDecoration(
              labelText: 'Phương thức thanh toán',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _paymentMethod = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Tổng cộng thanh toán',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          // Sử dụng widget hiển thị tiền của nhóm
          PriceText(cartProvider.totalAmount),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _placeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('ĐẶT HÀNG NGAY', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}