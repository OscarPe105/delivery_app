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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityStoreProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
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
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      Text(category.icon, style: const TextStyle(fontSize: 24)),
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
                    child: Image.network(
                      business.imageUrl ??
                          'https://via.placeholder.com/400x200?text=Sin+Imagen',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: ThemeProvider.primaryGradient,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Icon(
                            Icons.store,
                            size: 60,
                            color: ThemeProvider.lightTextColor,
                          ),
                        );
                      },
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 18, color: ThemeProvider.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'Negocio Local',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeProvider.primaryColor,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
