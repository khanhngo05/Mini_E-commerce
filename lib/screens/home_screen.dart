import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các tài nguyên của dự án
import '../app_router.dart';
import '../models/banner_item.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(viewportFraction: 0.93);

  Timer? _bannerTimer;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Khởi tạo dữ liệu khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchInitialProducts();
      _startBannerAutoPlay();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

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
      if (!_bannerController.hasClients || banners.isEmpty) return;

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
      case 'smartphone': return Icons.smartphone_rounded;
      case 'checkroom': return Icons.checkroom_rounded;
      case 'spa': return Icons.spa_rounded;
      case 'chair': return Icons.chair_alt_rounded;
      case 'sports_soccer': return Icons.sports_soccer_rounded;
      case 'shopping_basket': return Icons.shopping_basket_rounded;
      case 'diamond': return Icons.diamond_outlined;
      default: return Icons.category_outlined;
    }
  }

  String _resolveTag(Product product, int index) {
    if (index % 4 == 0) return 'Mall';
    if (product.rating >= 4.2) return 'Yêu thích';
    return 'Deal hot';
  }

  String _formatSold(int count) {
    if (count >= 1000) return 'Đã bán ${(count / 1000).toStringAsFixed(1)}k';
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
          if (index == 1) Navigator.of(context).pushNamed(AppRouter.cart);
          if (index == 2) Navigator.of(context).pushNamed(AppRouter.orderHistory);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ hàng'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Đơn hàng'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: productProvider.refreshProducts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              toolbarHeight: 52,
              backgroundColor: _isScrolled ? const Color(0xFFD32F2F) : Colors.transparent,
              centerTitle: false,
              // 👇 ĐÃ SỬA TIÊU ĐỀ KHỚP VỚI UNIT TEST 👇
              title: const Text(
                'TH4 - Nhóm G10', 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w700
                )
              ),
              actions: [
                CartBadge(
                  count: cartProvider.totalItemTypes,
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.cart),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
                onSelectCategory: (id) => productProvider.setCategory(id),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: Text('Gợi ý hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      tag: _resolveTag(product, index),
                      soldText: _formatSold(product.ratingCount),
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.productDetail, arguments: product),
                      onAddToCart: () {
                        context.read<CartProvider>().addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${product.title} vào giỏ hàng!'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                  childCount: productProvider.products.length,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: productProvider.isFetchingMore 
                    ? const CircularProgressIndicator() 
                    : const Text('Bạn đã xem hết sản phẩm rồi', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Các sub-widgets (Giữ nguyên logic chuyên nghiệp)
class _BannerSection extends StatelessWidget {
  final PageController controller;
  const _BannerSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final uiProvider = context.watch<UiProvider>();
    final banners = productProvider.banners;

    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: uiProvider.setBannerIndex,
            itemBuilder: (_, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(banners[index].imageUrl), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == uiProvider.currentBannerIndex ? 16 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: index == uiProvider.currentBannerIndex ? Colors.red : Colors.grey, borderRadius: BorderRadius.circular(4)),
          )),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final IconData Function(String) iconFromName;
  final Function(String?) onSelectCategory;

  const _CategorySection({required this.categories, required this.selectedCategoryId, required this.iconFromName, required this.onSelectCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (ctx, i) => InkWell(
          onTap: () => onSelectCategory(categories[i].id),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: Icon(iconFromName(categories[i].icon), color: Colors.red)),
                const SizedBox(height: 4),
                Text(categories[i].name, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}