import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/widgets/price_text.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const List<String> _sizes = <String>['S', 'M', 'L'];
  static const List<String> _colors = <String>['Xanh', 'Đỏ'];

  late final PageController _pageController;
  late final List<String> _detailImages;

  int _currentImageIndex = 0;
  String _selectedSize = _sizes[0];
  String _selectedColor = _colors[0];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _detailImages = List<String>.filled(5, widget.product.imageUrl);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openVariantSelectorSheet({
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
                                'Giá đã chọn',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B6B6B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              PriceText(
                                selectedPrice,
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
                    Text(
                      'Kích cỡ',
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
                    Text(
                      'Màu sắc',
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
                          'Số lượng',
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
                              size: tempSize,
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
                          'Xác nhận',
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
      _selectedSize = selection.size;
      _selectedColor = selection.color;
    });

    context.read<CartProvider>().addProduct(
      widget.product,
      quantity: selection.quantity,
      size: selection.size,
      color: selection.color,
      isSelected: true,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Đã thêm ${selection.quantity} sản phẩm vào giỏ')),
      );
  }

  void _buyNow({required bool showSizeSelector}) {
    final cartItem = CartItem(
      id: 'buy_now_${widget.product.id}_${DateTime.now().microsecondsSinceEpoch}',
      product: widget.product,
      quantity: 1,
      size: showSizeSelector ? _selectedSize : 'M',
      color: _selectedColor,
    );

    Navigator.of(context).pushNamed(AppRouter.checkout, arguments: [cartItem]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartBadgeCount = context.watch<CartProvider>().totalItemTypes;
    final product = widget.product;
    final salePrice = product.price;
    final originalPrice = salePrice * 1.5;
    final normalizedCategory = product.category.toLowerCase();
    final showSizeSelector =
        normalizedCategory.contains('clothing') ||
        normalizedCategory.contains('fashion') ||
        normalizedCategory.contains('thoi trang');

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 760
                ? 760.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
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
                                    '(${product.ratingCount} đánh giá)',
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
                              PriceText(
                                salePrice,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              PriceText(
                                originalPrice,
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _openVariantSelectorSheet(
                                selectedPrice: salePrice,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Chọn kích cỡ, màu sắc',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_selectedSize, $_selectedColor',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: const Color(0xFF6B6B6B),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 28,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ],
                              ),
                            ),
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
                                'Mô tả chi tiết',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ExpandableDescription(
                                text: product.description,
                                maxLines: 5,
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRouter.cart);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.shopping_cart_outlined),
                            ),
                            if (cartBadgeCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    key: ValueKey<int>(cartBadgeCount),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD32F2F),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '$cartBadgeCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _openVariantSelectorSheet(selectedPrice: salePrice);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                            foregroundColor: const Color(0xFFD32F2F),
                            minimumSize: const Size.fromHeight(46),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Thêm vào giỏ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _buyNow(showSizeSelector: showSizeSelector);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Mua liền',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text, required this.maxLines});

  final String text;
  final int maxLines;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final hasOverflow = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: Text(
                widget.text,
                style: textStyle,
                maxLines: _expanded ? null : widget.maxLines,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (hasOverflow) ...<Widget>[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 26),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _expanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CartSelectionDraft {
  const _CartSelectionDraft({
    required this.size,
    required this.color,
    required this.quantity,
  });

  final String size;
  final String color;
  final int quantity;
}
