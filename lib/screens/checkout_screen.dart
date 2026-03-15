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

  void _placeOrder() {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final selectedItems =
        widget.selectedItems?.toList(growable: false) ??
        cartProvider.selectedItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No selected items for checkout')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter shipping address')),
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

    orderProvider.addOrder(order);

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

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Order Placed'),
          content: const Text('Your order has been placed successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
              },
              child: const Text('Back to Home'),
            ),
          ],
        );
      },
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
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Shipping address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'COD', child: Text('Cash On Delivery')),
              DropdownMenuItem(value: 'Card', child: Text('Credit/Debit Card')),
            ],
            decoration: const InputDecoration(
              labelText: 'Payment method',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _paymentMethod = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Selected Items: ${selectedItems.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Total amount',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          PriceText(selectedTotal),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _placeOrder,
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
