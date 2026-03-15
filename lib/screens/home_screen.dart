import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:mini_e_commerce/models/banner_item.dart';
import 'package:mini_e_commerce/models/category.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/product_provider.dart';
import 'package:mini_e_commerce/providers/ui_provider.dart';
import 'package:mini_e_commerce/widgets/cart_badge.dart';
import 'package:mini_e_commerce/widgets/product_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.93,
  );

  Timer? _bannerTimer;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchInitialProducts();
      _startBannerAutoPlay();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final shouldHighlight = _scrollController.offset > 10;
    if (shouldHighlight != _isScrolled) {
      setState(() {
        _isScrolled = shouldHighlight;
      });
    }

    final provider = context.read<ProductProvider>();
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      provider.fetchMoreProducts();
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final banners = context.read<ProductProvider>().banners;
      if (!_bannerController.hasClients || banners.isEmpty) {
        return;
      }

      final uiProvider = context.read<UiProvider>();
      final nextIndex = (uiProvider.currentBannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOut,
      );
    });
  }

  IconData _iconFromName(String iconName) {
    switch (iconName) {
      case 'smartphone':
        return Icons.smartphone_rounded;
      case 'checkroom':
        return Icons.checkroom_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'chair':
        return Icons.chair_alt_rounded;
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'shopping_basket':
        return Icons.shopping_basket_rounded;
      case 'diamond':
        return Icons.diamond_outlined;
      case 'movie_ticket':
        return Icons.movie_outlined;
      case 'food':
        return Icons.fastfood_rounded;
      case 'loyalty':
        return Icons.workspace_premium_rounded;
      case 'coupon':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.category_outlined;
    }
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

  String _formatSold(int count) {
    if (count >= 1000) {
      final kValue = count / 1000;
      final text = kValue >= 10
          ? kValue.toStringAsFixed(0)
          : kValue.toStringAsFixed(1);
      return 'Đã bán ${text}k';
    }
    return 'Đã bán $count';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final uiProvider = context.watch<UiProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: uiProvider.selectedBottomTab,
        onDestinationSelected: (index) {
          uiProvider.setBottomTab(index);
          if (index == 1) {
            Navigator.of(context).pushNamed(AppRouter.cart);
          }
          if (index == 2) {
            Navigator.of(context).pushNamed(AppRouter.orderHistory);
          }
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Orders',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: productProvider.refreshProducts,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              elevation: 0,
              expandedHeight: 120,
              toolbarHeight: 52,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: const Text(
                'TH4 - Nhóm G10',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: <Widget>[
                CartBadge(
                  count: cartProvider.totalItemTypes,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.cart);
                  },
                ),
              ],
              flexibleSpace: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(62),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      readOnly: true,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Camelia Brand',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFD32F2F),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _BannerSection(controller: _bannerController),
            ),
            SliverToBoxAdapter(
              child: _CategorySection(
                categories: productProvider.categories,
                selectedCategoryId: productProvider.selectedCategoryId,
                iconFromName: _iconFromName,
                onSelectCategory: (categoryId) {
                  productProvider.setCategory(categoryId);
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Text(
                  'Gợi ý hôm nay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Cannot load product list'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: productProvider.fetchInitialProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      tag: _resolveTag(product, index),
                      soldText: _formatSold(product.ratingCount),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.productDetail,
                          arguments: product,
                        );
                      },
                      onAddToCart: () {
                        context.read<CartProvider>().addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.title} to cart'),
                          ),
                        );
                      },
                    );
                  }, childCount: productProvider.products.length),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: productProvider.isFetchingMore
                      ? const CircularProgressIndicator()
                      : (!productProvider.hasMore &&
                            productProvider.products.isNotEmpty)
                      ? const Text('You reached the end of product list')
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final uiProvider = context.watch<UiProvider>();
    final banners = productProvider.banners;

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 154,
            child: PageView.builder(
              controller: controller,
              itemCount: banners.length,
              onPageChanged: uiProvider.setBannerIndex,
              itemBuilder: (_, index) {
                final banner = banners[index];
                return _BannerCard(item: banner);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(banners.length, (index) {
              final isActive = index == uiProvider.currentBannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isActive ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFFC4C4C4),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.item});

  final BannerItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(item.imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.iconFromName,
    required this.onSelectCategory,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final IconData Function(String iconName) iconFromName;
  final ValueChanged<String?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 168,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88,
        ),
        itemCount: categories.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            final selected = selectedCategoryId == null;
            return _CategoryTile(
              label: 'Tất cả',
              icon: Icons.grid_view_rounded,
              selected: selected,
              onTap: () => onSelectCategory(null),
            );
          }

          final category = categories[index - 1];
          final selected = selectedCategoryId == category.id;
          return _CategoryTile(
            label: category.name,
            icon: iconFromName(category.icon),
            selected: selected,
            onTap: () {
              onSelectCategory(selected ? null : category.id);
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF1F0) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFFF4F4F4),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : const Color(0xFFD32F2F),
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: const Color(0xFF2A2A2A),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
