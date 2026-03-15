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
<<<<<<< HEAD
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
=======
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: cartProvider.allSelected,
                        onChanged: (value) {
                          if (value == null) return;
                          cartProvider.toggleSelectAll(value);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text('Select all'),
                      const Spacer(),
                      Text(
                        '${cartProvider.selectedItems.length}/${cartProvider.totalItemTypes} selected',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: item.isSelected,
                                onChanged: (_) {
                                  cartProvider.toggleSelection(item.id);
                                },
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const ColoredBox(
                                      color: Color(0xFFECECEC),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                    const SizedBox(height: 6),
                                    PriceText(item.product.price),
                                    const SizedBox(height: 8),
                                    QuantityStepper(
                                      value: item.quantity,
                                      onChanged: (next) {
                                        cartProvider.updateQuantity(
                                          item.id,
                                          next,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    cartProvider.removeItem(item.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Selected Total'),
                              PriceText(cartProvider.selectedAmount),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: cartProvider.hasSelectedItems
                              ? () {
                                  Navigator.of(context).pushNamed(
                                    AppRouter.checkout,
                                    arguments: cartProvider.selectedItems,
                                  );
                                }
                              : null,
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
>>>>>>> feature/checkout-screen
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