import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
// Đảm bảo import đúng file AppRouter của nhóm để chuyển trang Checkout
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
      // Sử dụng Consumer để tự động cập nhật UI khi giỏ hàng thay đổi
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Lấy danh sách item (hiện tại đã là List từ Provider)
          final cartItems = cartProvider.items;

          return Column(
            children: [
              // Phần 1: Danh sách sản phẩm
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Giỏ hàng của bạn đang trống!', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          // Truyền từng CartItem vào Widget con
                          return CartItemWidget(item: cartItems[index]);
                        },
                      ),
              ),
              // Phần 2: Thanh Bottom Summary (Tổng tiền & Mua hàng)
              _buildBottomSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  // Thanh điều khiển dưới cùng
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
            // Checkbox Chọn tất cả - Tự động đồng bộ với trạng thái các item
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
            
            // Cụm hiển thị Tổng tiền
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(fontSize: 12)),
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
            
            // Nút Mua hàng - Chuyển sang màn hình của Người 5
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: cartProvider.items.isEmpty 
                ? null // Vô hiệu hóa nút nếu giỏ hàng trống
                : () {
                    // Điều hướng sang trang Checkout sử dụng router chung của nhóm
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