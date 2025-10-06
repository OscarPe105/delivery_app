import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Añadir importación para Timer
import '../providers/community_store_provider.dart';
import '../models/business.dart';
import 'business_detail_screen.dart';
import 'cart_screen.dart';
import '../providers/theme_provider.dart'; // 🎨 Importa ThemeProvider

class CommunityStoreScreen extends StatefulWidget {
  const CommunityStoreScreen({super.key});

  @override
  State<CommunityStoreScreen> createState() => _CommunityStoreScreenState();
}

class _CommunityStoreScreenState extends State<CommunityStoreScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showHeader = true; // Variable para controlar la visibilidad del header
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late final ScrollController _categoryScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  bool _showSwipeHint = true;

  void _updateCategoryScrollHints() {
    if (!_categoryScrollController.hasClients) return;
    final pos = _categoryScrollController.position;
    final canLeft = pos.pixels > 0;
    final canRight = pos.pixels < pos.maxScrollExtent;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Inicializar controlador de animación
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_headerAnimationController);

    // Agregar listener para manejar el estado de la animación
    _headerAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showHeader = false;
        });
      }
    });

    // Programar la ocultación del header después de 5 segundos
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _headerAnimationController.forward();
      }
    });

    // Inicializar controlador de scroll para categorías
    _categoryScrollController = ScrollController();
    _categoryScrollController.addListener(_updateCategoryScrollHints);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityStoreProvider>(context, listen: false).loadData();

      // Actualizar indicadores de scroll y realizar un pequeño "nudge"
      _updateCategoryScrollHints();
      if (_categoryScrollController.hasClients &&
          _categoryScrollController.position.maxScrollExtent > 0) {
        _categoryScrollController
            .animateTo(24, duration: const Duration(milliseconds: 450), curve: Curves.easeOut)
            .then((_) {
          if (mounted && _categoryScrollController.hasClients) {
            _categoryScrollController.animateTo(0,
                duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
          }
        });
      }

      // Ocultar el hint de swipe automáticamente
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSwipeHint = false);
      });
    });
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: ThemeProvider.primaryGradient,
          ),
        ),
        title: Text(
          'FlowDelivery - Tienda Comunitaria',
          style: TextStyle(
            color: ThemeProvider.lightTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
        elevation: 8,
        shadowColor: ThemeProvider.primaryColor.withOpacity(0.3),
        iconTheme: IconThemeData(color: ThemeProvider.lightTextColor),
        actions: [
          Consumer<CommunityStoreProvider>(builder: (context, provider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: ThemeProvider.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProvider.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color: ThemeProvider.lightTextColor,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                      },
                    ),
                  ),
                  if (provider.cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ThemeProvider.lightTextColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: ThemeProvider.primaryColor, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${provider.cartItemCount}',
                          style: TextStyle(
                            color: ThemeProvider.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Mostrar el header con animación de desvanecimiento
          if (_showHeader) 
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: _buildHeader(),
            ),
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildBusinessList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ThemeProvider.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏪 Apoya a tu Comunidad',
            style: TextStyle(
              color: ThemeProvider.lightTextColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/ui/store_header.jpg',
            height: 100,
            fit: BoxFit.contain,
          ),
          Text(
            'Descubre los mejores productos de microempresarios locales',
            style: TextStyle(
              color: ThemeProvider.lightTextColor,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            color: ThemeProvider.primaryTextColor,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar negocios locales...',
            hintStyle: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: ThemeProvider.secondaryTextColor.withOpacity(0.6),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: ThemeProvider.primaryColor,
                size: 24,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: ThemeProvider.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: ThemeProvider.lightTextColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) {
            Provider.of<CommunityStoreProvider>(context, listen: false)
                .setSearchQuery(value);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<CommunityStoreProvider>(builder: (context, provider, child) {
      return Container(
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Scrollbar(
              controller: _categoryScrollController,
              thumbVisibility: true,
              radius: const Radius.circular(12),
              thickness: 4,
              child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected = provider.selectedCategory == category.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => provider.setCategory(category.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? ThemeProvider.primaryGradient : null,
                          color: isSelected ? null : ThemeProvider.lightTextColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: ThemeProvider.primaryColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? ThemeProvider.primaryColor.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (() {
                              final iconPath = category.icon;
                              if (iconPath.startsWith('assets/')) {
                                return Image.asset(
                                  iconPath,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.category,
                                    size: 24,
                                  ),
                                );
                              }
                              return const Icon(
                                Icons.category,
                                size: 24,
                              );
                            })(),
                            const SizedBox(height: 6),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? ThemeProvider.lightTextColor
                                    : ThemeProvider.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'Roboto',
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
            if (_canScrollLeft)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeProvider.backgroundColor,
                        ThemeProvider.backgroundColor.withOpacity(0.0)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: ThemeProvider.primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
            if (_canScrollRight)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeProvider.backgroundColor,
                        ThemeProvider.backgroundColor.withOpacity(0.0)
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: ThemeProvider.primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
            if (_showSwipeHint)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeProvider.lightTextColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app, size: 16, color: Colors.black87),
                          const SizedBox(width: 6),
                          const Text(
                            'Desliza las categorías',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildBusinessList() {
    return Consumer<CommunityStoreProvider>(builder: (context, provider, child) {
      final businesses = provider.filteredBusinesses;

      if (businesses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: ThemeProvider.infoColor),
              const SizedBox(height: 16),
              Text(
                'No se encontraron negocios',
                style: TextStyle(
                  fontSize: 18,
                  color: ThemeProvider.secondaryTextColor,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          final business = businesses[index];
          return _buildBusinessCard(business, provider);
        },
      );
    });
  }

  Widget _buildBusinessCard(
      Business business, CommunityStoreProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BusinessDetailScreen(business: business),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: (business.imageUrl != null && business.imageUrl!.isNotEmpty)
                        ? (business.imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                business.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/businesses/default_business.jpg',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.network(
                                business.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/businesses/default_business.jpg',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ))
                        : Image.asset(
                            'assets/images/businesses/default_business.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => provider.toggleFavorite(business.id),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeProvider.lightTextColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          provider.isFavorite(business.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: provider.isFavorite(business.id)
                              ? ThemeProvider.primaryColor
                              : Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: ThemeProvider.primaryTextColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: ThemeProvider.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: ThemeProvider.lightTextColor,
                                  size: 18),
                              const SizedBox(width: 4),
                              Text(
                                business.rating.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeProvider.lightTextColor,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      business.description ?? 'Sin descripción disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeProvider.secondaryTextColor,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          business.isOpen ? 'Abierto ahora' : 'Cerrado',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeProvider.secondaryTextColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: const SizedBox.shrink(),
                    ),
                    if (business.tags != null && business.tags!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: business.tags!.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: ThemeProvider.primaryGradient,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeProvider.lightTextColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
