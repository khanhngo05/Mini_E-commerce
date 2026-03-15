import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'price_text.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  // Hàm hiển thị hộp thoại xác nhận xóa khi số lượng về 0 hoặc khi vuốt
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy provider để gọi các hàm xử lý logic
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      // Sử dụng item.id làm key duy nhất cho mỗi dòng trong giỏ hàng
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmDialog(context),
      onDismissed: (direction) {
        cartProvider.removeItem(item.id);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 1. Checkbox chọn sản phẩm để tính tiền
              Checkbox(
                activeColor: Colors.orange,
                value: item.isSelected,
                onChanged: (value) {
                  cartProvider.setItemSelection(item.id, value ?? false);
                },
              ),
              // 2. Hiển thị ảnh sản phẩm từ đối tượng product
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage(item.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 3. Thông tin chi tiết sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phân loại: ${item.size}, ${item.color}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriceText(
                          item.lineTotal,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // 4. Bộ đếm số lượng tăng/giảm (+/-)
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (item.quantity > 1) {
                                  cartProvider.updateQuantity(item.id, -1);
                                } else {
                                  bool? confirm = await _showDeleteConfirmDialog(context);
                                  if (confirm == true) {
                                    cartProvider.removeItem(item.id);
                                  }
                                }
                              },
                              child: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                            ),
                            InkWell(
                              onTap: () {
                                cartProvider.updateQuantity(item.id, 1);
                              },
                              child: const Icon(Icons.add_circle_outline, color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}