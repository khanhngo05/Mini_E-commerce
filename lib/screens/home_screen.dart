import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các tài nguyên của dự án
import '../app_router.dart';
import '../models/banner_item.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
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
  final PageController _bannerController = PageController(
    viewportFraction: 0.93,
  );

  Timer? _bannerTimer;

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

  // Xử lý hiệu ứng khi cuộn trang
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Tự động load thêm sản phẩm khi cuộn gần hết (Lazy Loading)
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

  // Hàm chuyển đổi tên icon từ server sang IconData của Flutter
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
      default:
        return Icons.category_outlined;
    }
  }

  // Gắn tag cho sản phẩm dựa trên các tiêu chí (Logic UI)
  String _resolveTag(Product product, int index) {
    if (index % 4 == 0) return 'Mall';
    if (product.rating >= 4.2) return 'Yêu thích';
    return 'Deal hot';
  }

  // Định dạng số lượng đã bán
  String _formatSold(int count) {
    if (count >= 1000) return 'Đã bán ${(count / 1000).toStringAsFixed(1)}k';
    return 'Đã bán $count';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final uiProvider = context.watch<UiProvider>();
    final cartProvider = context
        .watch<CartProvider>(); // Lắng nghe Cart để update Badge

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: uiProvider.selectedBottomTab,
        onDestinationSelected: (index) async {
          uiProvider.setBottomTab(index);
          if (index == 1) {
            await Navigator.of(context).pushNamed(AppRouter.cart);
            if (!context.mounted) {
              return;
            }
            context.read<UiProvider>().setBottomTab(0);
          }
          if (index == 2) {
            await Navigator.of(context).pushNamed(AppRouter.orderHistory);
            if (!context.mounted) {
              return;
            }
            context.read<UiProvider>().setBottomTab(0);
          }
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Giỏ hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Đơn hàng',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: productProvider.refreshProducts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // AppBar có chứa Badge Giỏ hàng của Người 4
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              toolbarHeight: 52,
              backgroundColor: const Color(0xFFD32F2F),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text(
                'TH4 - G10',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.login,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  tooltip: 'Đăng xuất',
                ),
                CartBadge(
                  count: cartProvider
                      .totalItemTypes, // Sử dụng getter mới chúng ta vừa thêm
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouter.cart),
                ),
              ],
            ),

            // Phần Banner Quảng cáo
            SliverToBoxAdapter(
              child: _BannerSection(controller: _bannerController),
            ),

            // Phần Danh mục sản phẩm (Categories)
            SliverToBoxAdapter(
              child: _CategorySection(
                categories: productProvider.categories,
                selectedCategoryId: productProvider.selectedCategoryId,
                iconFromName: _iconFromName,
                onSelectCategory: (id) => productProvider.setCategory(id),
              ),
            ),

            // Tiêu đề phần gợi ý
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: Text(
                  'Gợi ý hôm nay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Grid hiển thị sản phẩm
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRouter.productDetail, arguments: product),

                    // LOGIC QUAN TRỌNG CỦA NGƯỜI 4: Thêm vào giỏ hàng
                    onAddToCart: () {
                      context.read<CartProvider>().addProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm ${product.title} vào giỏ hàng!',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                }, childCount: productProvider.products.length),
              ),
            ),

            // Loading indicator khi cuộn trang
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: productProvider.isFetchingMore
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Bạn đã xem hết sản phẩm rồi',
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Các sub-widgets hỗ trợ (Banner, Category Tiles...) - Giữ nguyên logic UI của nhóm
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
            itemBuilder: (_, index) => _BannerCard(item: banners[index]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index == uiProvider.currentBannerIndex ? 16 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index == uiProvider.currentBannerIndex
                    ? Colors.red
                    : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerItem item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final IconData Function(String) iconFromName;
  final Function(String?) onSelectCategory;

  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.iconFromName,
    required this.onSelectCategory,
  });

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
                CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    iconFromName(categories[i].icon),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categories[i].name,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
