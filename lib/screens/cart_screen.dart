import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
// Lấy thêm file router từ code của nhóm để làm chức năng chuyển trang
import 'package:mini_e_commerce/app_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

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
          // FIX MỚI: Vì items ở Provider đã đổi thành List, ta gọi trực tiếp luôn
          final cartItems = cartProvider.items;

          return Column(
            children: [
              // Phần 1: Danh sách sản phẩm
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Giỏ hàng của bạn đang trống!'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          // Giao diện siêu đẹp của bạn ở đây
                          return CartItemWidget(item: item);
                        },
                      ),
              ),
              // Phần 2: Thanh Sticky Bottom Bar
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
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3), 
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Checkbox Chọn tất cả
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
            
            // Cụm Tổng tiền
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Tổng thanh toán'),
                Text(
                  '₫${cartProvider.totalAmount.toStringAsFixed(0)}', 
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Nút Mua hàng (Đã được tích hợp lệnh chuyển trang của nhóm)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Code của nhóm: Chuyển sang màn hình Checkout
                Navigator.of(context).pushNamed(AppRouter.checkout);
              },
              child: const Text('Mua Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}