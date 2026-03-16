import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/price_text.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (!cartProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = cartProvider.items;

          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Giỏ hàng của bạn đang trống!'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return CartItemWidget(item: cartItems[index]);
                        },
                      ),
              ),
              _buildBottomSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Checkbox(
              activeColor: Colors.orange,
              value: cartProvider.isAllSelected,
              onChanged: (value) {
                if (value != null) {
                  cartProvider.toggleSelectAll(value);
                }
              },
            ),
            const Text('Tất cả'),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Tổng thanh toán'),
                PriceText(
                  cartProvider.totalAmount,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: cartProvider.hasSelectedItems
                  ? () {
                      Navigator.of(context).pushNamed(
                        AppRouter.checkout,
                        arguments: cartProvider.selectedItems,
                      );
                    }
                  : null,
              child: const Text(
                'Mua Hàng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
