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
  bool _isDescriptionExpanded = false;

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

  Future<void> _openVariantSelectorSheet({
    required bool showSizeSelector,
    required double selectedPrice,
  }) async {
    String tempSize = _selectedSize;
    String tempColor = _selectedColor;
    int tempQuantity = 1;

    final selection = await showModalBottomSheet<_CartSelectionDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const ColoredBox(
                                  color: Color(0xFFF0F0F0),
                                  child: Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${selectedPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
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
                          final isSelected = tempSize == size;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                tempSize = size;
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
                        final isSelected = tempColor == colorName;
                        return ChoiceChip(
                          label: Text(colorName),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() {
                              tempColor = colorName;
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
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Text(
                          'Quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD8D8D8)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: tempQuantity > 1
                                    ? () {
                                        setModalState(() {
                                          tempQuantity -= 1;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '$tempQuantity',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempQuantity += 1;
                                  });
                                },
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(
                            _CartSelectionDraft(
                              size: showSizeSelector ? tempSize : null,
                              color: tempColor,
                              quantity: tempQuantity,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selection == null) {
      return;
    }

    setState(() {
      if (selection.size != null) {
        _selectedSize = selection.size!;
      }
      _selectedColor = selection.color;
    });

    // Keep selected variants and quantity ready for CartProvider integration.
    final cartPayload = <String, dynamic>{
      'productId': widget.product.id,
      'size': selection.size,
      'color': selection.color,
      'quantity': selection.quantity,
    };
    if (cartPayload.isNotEmpty) {
      // Intentionally empty; payload is prepared for a later CartProvider commit.
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Product added to cart')));
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
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
                                maxLines: _isDescriptionExpanded ? null : 3,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isDescriptionExpanded =
                                            !_isDescriptionExpanded;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 28),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _isDescriptionExpanded
                                          ? 'Show less'
                                          : 'See more',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _openVariantSelectorSheet(
                        showSizeSelector: showSizeSelector,
                        selectedPrice: salePrice,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      foregroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartSelectionDraft {
  const _CartSelectionDraft({
    required this.size,
    required this.color,
    required this.quantity,
  });

  final String? size;
  final String color;
  final int quantity;
}
