import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem>? selectedItems;

  const CheckoutScreen({super.key, this.selectedItems});

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

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final selectedItems =
        widget.selectedItems?.toList(growable: false) ??
        cartProvider.selectedItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long chon san pham de thanh toan')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap dia chi giao hang')),
      );
      return;
    }

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      items: List.of(selectedItems),
      shippingAddress: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
      status: OrderStatus.pendingConfirmation,
      createdAt: DateTime.now(),
    );

    await orderProvider.addOrder(order);

    if (widget.selectedItems != null) {
      final selectedIds = selectedItems.map((item) => item.id).toSet();
      cartProvider.setItems(
        cartProvider.items
            .where((item) => !selectedIds.contains(item.id))
            .toList(),
      );
    } else {
      cartProvider.removeSelectedItems();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Dat hang thanh cong')));

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.orderHistory,
      (route) => route.settings.name == AppRouter.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final selectedItems = widget.selectedItems ?? cartProvider.selectedItems;
    final selectedTotal = selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Dia chi nhan hang',
              hintText: 'Nhap so nha, ten duong, phuong/xa...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(
                value: 'COD',
                child: Text('Thanh toan khi nhan hang (COD)'),
              ),
              DropdownMenuItem(
                value: 'Card',
                child: Text('The tin dung / Ghi no'),
              ),
            ],
            decoration: const InputDecoration(
              labelText: 'Phuong thuc thanh toan',
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
          Text(
            'San pham da chon: ${selectedItems.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tong cong thanh toan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          PriceText(selectedTotal),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _placeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text(
              'DAT HANG NGAY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
