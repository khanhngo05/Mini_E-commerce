import 'package:flutter/material.dart';
import 'package:mini_e_commerce/models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const List<String> _sizes = <String>['S', 'M', 'L', 'XL'];
  static const List<String> _colors = <String>['Red', 'Blue', 'Black'];

  late final PageController _pageController;
  late final List<String> _detailImages;

  int _currentImageIndex = 0;
  String _selectedSize = _sizes[1];
  String _selectedColor = _colors[0];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _detailImages = List<String>.filled(4, widget.product.imageUrl);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final salePrice = product.price;
    final originalPrice = salePrice * 1.5;
    final normalizedCategory = product.category.toLowerCase();
    final isJewelryCategory = normalizedCategory.contains('jewel');
    final isFashionCategory =
        normalizedCategory.contains('clothing') ||
        normalizedCategory.contains('fashion') ||
        normalizedCategory.contains('thoi trang');
    final showSizeSelector = isFashionCategory && !isJewelryCategory;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 760
                ? 760.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: Stack(
                            children: <Widget>[
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _detailImages.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final imageWidget = Image.network(
                                    _detailImages[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const ColoredBox(
                                        color: Color(0xFFF0F0F0),
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 40,
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (index == 0) {
                                    return Hero(
                                      tag: product.id,
                                      child: imageWidget,
                                    );
                                  }

                                  return imageWidget;
                                },
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                    _detailImages.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: _currentImageIndex == index
                                          ? 18
                                          : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.55,
                                              ),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                product.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFA000),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${product.ratingCount} reviews)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '\$${salePrice.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '\$${originalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF6B6B6B),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (showSizeSelector) ...<Widget>[
                                Text(
                                  'Size',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _sizes.map((size) {
                                    final isSelected = _selectedSize == size;
                                    return ChoiceChip(
                                      label: Text(size),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedSize = size;
                                        });
                                      },
                                      selectedColor: const Color(0xFFD32F2F),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF3A3A3A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                'Color',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _colors.map((colorName) {
                                  final isSelected =
                                      _selectedColor == colorName;
                                  return ChoiceChip(
                                    label: Text(colorName),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedColor = colorName;
                                      });
                                    },
                                    selectedColor: const Color(0xFF1F1F1F),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF3A3A3A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Description',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'More specification blocks will be added in a later commit.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
