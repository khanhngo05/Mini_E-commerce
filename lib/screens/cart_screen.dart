import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
// import '../widgets/cart_item_widget.dart'; // Chúng ta sẽ tạo file này ở bước sau

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt làm nổi bật card sản phẩm
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // Dùng Consumer để lắng nghe sự thay đổi từ CartProvider
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.items.values.toList();

          return Column(
            children: [
              // Phần 1: Danh sách sản phẩm (ListView)
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Giỏ hàng của bạn đang trống!'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          // Tạm thời hiển thị Text, lát nữa chúng ta sẽ thay bằng CartItemWidget
                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text('Số lượng: ${item.quantity}'),
                            trailing: Checkbox(
                              value: item.isSelected,
                              onChanged: (_) {
                                cartProvider.toggleItemSelection(item.productId);
                              },
                            ),
                          );
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

  // Tách riêng Widget cho thanh dưới cùng cho code sạch sẽ
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
            offset: const Offset(0, -3), // Bóng đổ lên trên
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Checkbox Chọn tất cả
            Checkbox(
              activeColor: Colors.orange, // Màu chủ đạo Shopee/Lazada
              value: cartProvider.isAllSelected,
              onChanged: (value) {
                if (value != null) {
                  cartProvider.toggleSelectAll(value);
                }
              },
            ),
            const Text('Tất cả'),
            
            const Spacer(), // Đẩy phần tổng tiền sang phải
            
            // Cụm Tổng tiền và Nút Mua hàng
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Tổng thanh toán'),
                Text(
                  // Format hiển thị tiền (có thể viết thêm hàm format chuẩn sau)
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
                // TODO: Xử lý truyền dữ liệu sang trang Checkout của Người 5
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chuyển sang trang Thanh toán...')),
                );
              },
              child: const Text('Mua Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}