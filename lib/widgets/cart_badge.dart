import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({required this.count, required this.onPressed, super.key});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart_outlined),
        onPressed: onPressed,
      ),
    );
  }
}
