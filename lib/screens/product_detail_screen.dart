import 'package:flutter/material.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: Color(0xFFECECEC),
                    child: Icon(Icons.broken_image_outlined, size: 36),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          PriceText(product.price),
          const SizedBox(height: 12),
          Chip(label: Text(product.category)),
          const SizedBox(height: 16),
          Text(product.description),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<CartProvider>().addProduct(product);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Added to cart')));
            },
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add To Cart'),
          ),
        ],
      ),
    );
  }
}
