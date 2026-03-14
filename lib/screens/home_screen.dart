import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_e_commerce/constants/app_theme.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/product_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _bannerImages = <String>[
    'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1200',
    'https://images.unsplash.com/photo-1607083206968-13611e3d76db?w=1200',
    'https://images.unsplash.com/photo-1481437156560-3205f6a55735?w=1200',
    'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=1200',
  ];

  static const List<_CategoryItem> _categories = <_CategoryItem>[
    _CategoryItem(label: 'Deal 1k', icon: Icons.local_fire_department_rounded),
    _CategoryItem(label: 'Shopee Mart', icon: Icons.shopping_basket_rounded),
    _CategoryItem(label: 'Dien thoai', icon: Icons.smartphone_rounded),
    _CategoryItem(label: 'Thoi trang', icon: Icons.checkroom_rounded),
    _CategoryItem(label: 'My pham', icon: Icons.spa_rounded),
    _CategoryItem(label: 'Nha cua', icon: Icons.chair_alt_rounded),
    _CategoryItem(label: 'Do an', icon: Icons.fastfood_rounded),
    _CategoryItem(label: 'The thao', icon: Icons.sports_soccer_rounded),
    _CategoryItem(label: 'Shopee Food', icon: Icons.delivery_dining_rounded),
    _CategoryItem(
      label: 'Shopee xu ly',
      icon: Icons.miscellaneous_services_rounded,
    ),
    _CategoryItem(
      label: 'Khach hang than thiet',
      icon: Icons.workspace_premium_rounded,
    ),
    _CategoryItem(
      label: 'Ma giam gia',
      icon: Icons.confirmation_number_rounded,
    ),
    _CategoryItem(label: 'Xem them', icon: Icons.more_horiz_rounded),
  ];

  static const List<_ShortcutItem> _shortcuts = <_ShortcutItem>[
    _ShortcutItem(
      title: 'ShopeePay',
      subtitle: 'Nhan voucher moi ngay',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _ShortcutItem(
      title: 'Xu 200',
      subtitle: 'Doi qua va uu dai',
      icon: Icons.monetization_on_rounded,
    ),
    _ShortcutItem(
      title: 'SPayLater',
      subtitle: 'Tra sau linh hoat',
      icon: Icons.receipt_long_rounded,
    ),
  ];

  final NumberFormat _moneyFormatter = NumberFormat('#,###', 'vi_VN');
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );

  Timer? _bannerTimer;
  bool _isScrolled = false;
  int _currentBanner = 0;
  int _selectedBottomTab = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.fetchInitialProducts();
      }
    });
    _startBannerAutoPlay();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final shouldHighlightAppBar = _scrollController.offset > 8;
    if (shouldHighlightAppBar != _isScrolled) {
      setState(() {
        _isScrolled = shouldHighlightAppBar;
      });
    }

    final provider = context.read<ProductProvider>();
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      provider.fetchMoreProducts();
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients) {
        return;
      }
      final nextPage = (_currentBanner + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _handleRefresh() {
    return context.read<ProductProvider>().refreshProducts();
  }

  void _addToCart(Product product) {
    context.read<CartProvider>().addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('Da them "${product.title}" vao gio hang'),
      ),
    );
  }

  String _formatPrice(double value) {
    return '${_moneyFormatter.format(value * 26000)}đ';
  }

  String _formatSold(int count) {
    if (count >= 1000) {
      final number = count / 1000;
      return number >= 10
          ? 'Đã bán ${number.toStringAsFixed(0)}k'
          : 'Đã bán ${number.toStringAsFixed(1)}k';
    }
    return 'Đã bán $count';
  }

  String _resolveTag(Product product, int index) {
    if (index % 4 == 0) {
      return 'Mall';
    }
    if (product.rating >= 4.2) {
      return 'Yêu thích';
    }
    if (index % 3 == 0) {
      return 'Giảm 50%';
    }
    return 'Deal hot';
  }

  int _resolveDiscountPercent(int index) {
    return 10 + (index * 7) % 55;
  }

  List<String> _resolvePromoChips(int index) {
    return <String>[
      '15.3',
      'Voucher xtra',
      if (index.isEven) 'Shoppe Mall' else 'Hoan xu',
    ];
  }

  String _resolveShippingText(int index) {
    return index.isEven ? '🚚 2 - 4 ngày' : '🚚 Miễn phí vận chuyển';
  }

  String _resolveLocationText(int index) {
    return switch (index % 3) {
      0 => 'Hà Nội',
      1 => 'TP. Hồ Chí Minh',
      _ => 'Đà Nẵng',
    };
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: const Color(0x1AE53935),
        selectedIndex: _selectedBottomTab,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedBottomTab = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Mall',
          ),
          NavigationDestination(
            icon: Icon(Icons.live_tv_outlined),
            label: 'Live & Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            label: 'Thong bao',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Toi',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              toolbarHeight: 56,
              expandedHeight: 56,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isScrolled
                        ? const <Color>[Color(0xFFE53935), Color(0xFFCC2D2D)]
                        : const <Color>[Colors.transparent, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: const Text(
                'TH4 - Nhóm G10',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Badge(
                      backgroundColor: AppTheme.badgeRed,
                      textColor: Colors.white,
                      isLabelVisible: cartProvider.totalItemTypes > 0,
                      label: Text('${cartProvider.totalItemTypes}'),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Man hinh gio hang dang duoc phat trien',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFFE53935),
                        ),
                        suffixIcon: Icon(Icons.camera_alt_outlined),
                        hintText: 'Camelia Brand',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildTopRedHeader()),
            SliverToBoxAdapter(child: _buildBannerSection()),
            SliverToBoxAdapter(child: _buildPromoCards()),
            SliverToBoxAdapter(child: _buildLiveVideoSection()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 14, 12, 8),
                child: Text(
                  'Goi y hom nay',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (productProvider.isLoading && productProvider.products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (productProvider.errorMessage != null &&
                productProvider.products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Khong the tai danh sach san pham',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            context
                                .read<ProductProvider>()
                                .fetchInitialProducts();
                          },
                          child: const Text('Thu lai'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productProvider.products[index];
                    return _buildProductCard(product, index);
                  }, childCount: productProvider.products.length),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: productProvider.isFetchingMore
                      ? const CircularProgressIndicator()
                      : (!productProvider.hasMore &&
                            productProvider.products.isNotEmpty)
                      ? const Text('Ban da xem het san pham')
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRedHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFE53935), Color(0xFFCC2D2D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List<Widget>.generate(_shortcuts.length, (int index) {
                  final item = _shortcuts[index];
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: index == _shortcuts.length - 1
                            ? null
                            : const Border(
                                right: BorderSide(color: Color(0xFFEDEDED)),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                item.icon,
                                size: 17,
                                color: AppTheme.primaryRed,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6F6F6F),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          _buildCategorySection(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      color: const Color(0xFFF6F6F6),
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 148,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _bannerImages.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentBanner = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.network(_bannerImages[index], fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.38),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 12,
                          bottom: 10,
                          child: Text(
                            'SIEU SALE GIUA THANG',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_bannerImages.length, (int index) {
              final isActive = index == _currentBanner;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryRed : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCards() {
    return SizedBox(
      height: 124,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        scrollDirection: Axis.horizontal,
        children: const <Widget>[
          _PromoCard(
            title: 'Sieu re\n1.000đ',
            subtitle: 'Mua ngay',
            colorA: Color(0xFFFF5D3A),
            colorB: Color(0xFFFF8A50),
          ),
          SizedBox(width: 10),
          _PromoCard(
            title: 'Xe dien\nLen ngoi',
            subtitle: 'Mua ngay',
            colorA: Color(0xFFE63A3A),
            colorB: Color(0xFFFF6B6B),
          ),
          SizedBox(width: 10),
          _PromoCard(
            title: 'Tra sau\n0%',
            subtitle: 'Mua ngay',
            colorA: Color(0xFFC62828),
            colorB: Color(0xFFFF5252),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveVideoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _LiveCard(
              title: 'SHOPEE LIVE',
              imageA:
                  'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
              imageB:
                  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LiveCard(
              title: 'SHOPEE VIDEO',
              imageA:
                  'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=500',
              imageB:
                  'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return SizedBox(
      height: 126,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
        itemCount: _categories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = _categories[index];
          return Container(
            width: 78,
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: AppTheme.primaryRed,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    final tag = _resolveTag(product, index);
    final discountPercent = _resolveDiscountPercent(index);
    final promoChips = _resolvePromoChips(index);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Opacity(opacity: 0.25, child: child),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryRed,
                                    value:
                                        loadingProgress.expectedTotalBytes ==
                                            null
                                        ? null
                                        : loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!,
                                  ),
                                ),
                              ],
                            );
                          },
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFECECEC),
                          child: Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        );
                      },
                    ),
                  ),
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
                      color: AppTheme.primaryRed,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '-$discountPercent%',
                      style: const TextStyle(
                        color: AppTheme.primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: promoChips.map((chip) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: chip == '15.3'
                              ? const Color(0xFFFFC107)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chip,
                          style: TextStyle(
                            color: chip == '15.3'
                                ? const Color(0xFF1A1A1A)
                                : AppTheme.primaryRed,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEFEF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFFD3D3)),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          _formatPrice(product.price),
                          style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatSold(product.ratingCount),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _resolveShippingText(index),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0E9F6E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _resolveLocationText(index),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Bán chạy',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem({required this.label, required this.icon});
}

class _ShortcutItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ShortcutItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.colorA,
    required this.colorB,
  });

  final String title;
  final String subtitle;
  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: <Color>[colorA, colorB]),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.title,
    required this.imageA,
    required this.imageB,
  });

  final String title;
  final String imageA;
  final String imageB;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: Image.network(imageA, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: Image.network(imageB, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
