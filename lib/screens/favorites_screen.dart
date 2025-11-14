/// ❤️ PANTALLA DE FAVORITOS
/// 
/// Pantalla para mostrar negocios y productos favoritos del usuario
/// con animaciones y efectos visuales modernos
/// 
/// @author Sistema de Delivery Comunitario
/// @version 2.0.0

import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/material.dart' as material show IconButton;
import 'package:provider/provider.dart';

import '../models/business.dart';
import '../models/product.dart';
import '../providers/community_store_provider.dart';
import '../widgets/improved_buttons.dart';
import '../widgets/animated_components.dart';
import '../widgets/optimized_image.dart';
import '../themes/app_colors.dart';
import 'business_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedTab = 'negocios';
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeProvider =
          Provider.of<CommunityStoreProvider>(context, listen: false);
      if (!storeProvider.isLoading && storeProvider.businesses.isEmpty) {
        storeProvider.loadBusinesses();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CommunityStoreProvider>(
        builder: (context, storeProvider, _) {
          final favoriteBusinessIds = storeProvider.favorites;
          final favoriteProductIds = storeProvider.favoriteProducts;

          final favoriteBusinesses = favoriteBusinessIds
              .map((id) => storeProvider.getBusinessById(id))
              .whereType<Business>()
              .toList();

          final favoriteProducts = favoriteProductIds
              .map((id) => storeProvider.getProductById(id))
              .whereType<Product>()
              .toList();

          final businessCount = favoriteBusinessIds.length;
          final productCount = favoriteProductIds.length;

          final isLoadingBusinesses =
              storeProvider.isLoading && storeProvider.businesses.isEmpty;
          final isLoadingProducts =
              storeProvider.isLoading && storeProvider.products.isEmpty;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(businessCount, productCount),
                      _buildTabBar(),
                      Expanded(
                        child: _buildContent(
                          storeProvider,
                          favoriteBusinesses,
                          favoriteProducts,
                          businessCount,
                          productCount,
                          isLoadingBusinesses,
                          isLoadingProducts,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int businessCount, int productCount) {
    final isBusinessTab = _selectedTab == 'negocios';
    final count = isBusinessTab ? businessCount : productCount;
    final hasFavorites = count > 0;
    final subtitle = isBusinessTab
        ? (hasFavorites
            ? '$count negocio${count == 1 ? '' : 's'} guardado${count == 1 ? '' : 's'}'
            : 'Aún no has guardado negocios')
        : (hasFavorites
            ? '$count producto${count == 1 ? '' : 's'} favorito${count == 1 ? '' : 's'}'
            : 'Aún no has guardado productos');
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          material.IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Favoritos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          material.IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implementar búsqueda en favoritos
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('negocios', 'Negocios', Icons.store),
          ),
          Expanded(
            child: _buildTabButton('productos', 'Productos', Icons.restaurant),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    CommunityStoreProvider storeProvider,
    List<Business> favoriteBusinesses,
    List<Product> favoriteProducts,
    int businessCount,
    int productCount,
    bool isLoadingBusinesses,
    bool isLoadingProducts,
  ) {
    if (_selectedTab == 'negocios') {
      return _buildBusinessesList(
        favoriteBusinesses,
        storeProvider,
        businessCount,
        isLoadingBusinesses,
      );
    } else {
      return _buildProductsList(
        favoriteProducts,
        storeProvider,
        productCount,
        isLoadingProducts,
      );
    }
  }

  Widget _buildBusinessesList(
    List<Business> businesses,
    CommunityStoreProvider provider,
    int favoritesCount,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (favoritesCount == 0) {
      return _buildEmptyFavoritesState();
    }

    if (businesses.isEmpty) {
      return _buildEmptyFavoritesState(
        message:
            'Estamos sincronizando tus negocios favoritos.\nIntenta nuevamente en unos segundos.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return AnimatedCard(
          delayMilliseconds: index * 100,
          child: _buildBusinessCard(business, provider),
        );
      },
    );
  }

  Widget _buildBusinessCard(
      Business business, CommunityStoreProvider provider) {
    return GestureDetector(
      onTap: () => _openBusinessDetail(business),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Imagen del negocio
            _buildBusinessImageSection(business),
            // Información del negocio
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                      ),
                      material.IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          provider.toggleFavorite(business.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    business.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        business.rating.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          business.address ?? 'Dirección no disponible',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryGradientButton(
                          text: 'Ver Menú',
                          icon: Icons.restaurant,
                          onPressed: () => _openBusinessDetail(business),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Llamar',
                          icon: Icons.phone,
                          onPressed: () {
                            // TODO: Implementar llamada
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(
    List<Product> products,
    CommunityStoreProvider provider,
    int productCount,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (productCount == 0) {
      return _buildProductsEmptyState();
    }

    if (products.isEmpty) {
      return _buildProductsEmptyState(
        message:
            'Estamos sincronizando tus productos favoritos.\nIntenta nuevamente en unos segundos.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final business = provider.getBusinessById(product.businessId);
        return AnimatedCard(
          delayMilliseconds: index * 100,
          child: _buildProductFavoriteCard(product, business, provider),
        );
      },
    );
  }

  Widget _buildBusinessImageSection(Business business) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    final hasImage =
        business.imageUrl != null && business.imageUrl!.trim().isNotEmpty;

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              OptimizedImage(
                imageUrl: business.imageUrl,
                fit: BoxFit.cover,
                showShimmer: true,
                borderRadius: BorderRadius.zero,
              )
            else
              _buildGradientBackground(),
            // Overlay para sombrear un poco la imagen y mantener legibilidad
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: ParticleEffect(
                particleCount: 15,
                particleColor: Colors.white.withValues(alpha: 0.15),
                child: Container(),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Favorito',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: business.isOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  business.isOpen ? 'Abierto' : 'Cerrado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!hasImage)
              const Center(
                child: Icon(
                  Icons.store,
                  size: 60,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildProductFavoriteCard(
    Product product,
    Business? business,
    CommunityStoreProvider provider,
  ) {
    final businessName = business?.name ?? 'Negocio no disponible';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(
                  imageUrl: product.imageUrl,
                  size: 88,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                          ),
                          material.IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => provider.toggleProductFavorite(product.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.store_mall_directory,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              businessName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          final promotion = provider.getPromotionForProduct(product.id);
                          const currencySymbol = "\$";
                          final originalPrice = '$currencySymbol${product.price.toStringAsFixed(2)}';
                          final double? promotionalValue = promotion?.promotionalPrice;
                          final promoPrice = promotionalValue != null
                              ? '$currencySymbol${promotionalValue.toStringAsFixed(2)}'
                              : null;

                          return Row(
                            children: [
                              if (promoPrice != null)
                                Text(
                                  originalPrice,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (promoPrice != null) const SizedBox(width: 8),
                              Text(
                                promoPrice ?? originalPrice,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: promoPrice != null ? Colors.redAccent : AppColors.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryGradientButton(
                    text: 'Ver negocio',
                    icon: Icons.store,
                    height: 50,
                    onPressed: () {
                      if (business != null) {
                        _openBusinessDetail(business);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'No se encontró información del negocio para este producto'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    text: 'Quitar',
                    icon: Icons.delete_outline,
                    height: 50,
                    borderColor: AppColors.primary,
                    textColor: AppColors.primary,
                    onPressed: () => provider.toggleProductFavorite(product.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
              child: Column(
                children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'No tienes negocios favoritos',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ??
                      'Descubre negocios locales y agrégalos a tu lista para volver más rápido.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryGradientButton(
                  text: 'Explorar negocios',
                  icon: Icons.explore,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsEmptyState({String? message}) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No hay productos favoritos',
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'Encuentra productos deliciosos y márcalos como favoritos para acceder rápido.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryGradientButton(
              text: 'Explorar productos',
              icon: Icons.explore,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openBusinessDetail(Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(business: business),
      ),
    );
  }
}
