import 'package:flutter/material.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.tag,
    required this.soldText,
    required this.onTap,
    required this.onAddToCart,
    super.key,
  });

  final Product product;
  final String tag;
  final String soldText;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      final expectedTotalBytes = progress.expectedTotalBytes;
                      final progressValue = expectedTotalBytes == null
                          ? null
                          : progress.cumulativeBytesLoaded / expectedTotalBytes;

                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Opacity(opacity: 0.35, child: child),
                          Container(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          Center(
                            child: CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 2,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(
                        color: Color(0xFFECECEC),
                        child: Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: onAddToCart,
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Color(0xFFD32F2F),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  PriceText(
                    product.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          soldText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: Color(0xFFFF8F00),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
