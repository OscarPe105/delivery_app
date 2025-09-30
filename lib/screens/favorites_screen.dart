/**
 * ❤️ PANTALLA DE FAVORITOS
 * 
 * Pantalla para mostrar negocios y productos favoritos del usuario
 * con animaciones y efectos visuales modernos
 * 
 * @author Sistema de Delivery Comunitario
 * @version 2.0.0
 */

import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/material.dart' as material show IconButton;
import '../widgets/improved_buttons.dart';
import '../widgets/animated_components.dart';
import '../models/business.dart';

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
  final List<Business> _favoriteBusinesses = [
    Business(
      id: '1',
      name: 'Pizza Express',
      category: 'Pizzería',
      address: 'Calle Principal 123',
      latitude: 13.6929,
      longitude: -89.2182,
      rating: 4.5,
      isOpen: true,
    ),
    Business(
      id: '2',
      name: 'Burger King',
      category: 'Hamburguesas',
      address: 'Avenida Central 456',
      latitude: 13.6929,
      longitude: -89.2182,
      rating: 4.2,
      isOpen: true,
    ),
    Business(
      id: '3',
      name: 'Sushi Master',
      category: 'Japonés',
      address: 'Plaza Mayor 789',
      latitude: 13.6929,
      longitude: -89.2182,
      rating: 4.8,
      isOpen: false,
    ),
  ];

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
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
                  // Header personalizado
                  _buildHeader(),
                  
                  // Tabs de navegación
                  _buildTabBar(),
                  
                  // Contenido principal
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  '${_favoriteBusinesses.length} negocios guardados',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
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
        color: Colors.white.withOpacity(0.2),
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
              color: isSelected ? const Color(0xFF667eea) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF667eea) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 'negocios') {
      return _buildBusinessesList();
    } else {
      return _buildProductsList();
    }
  }

  Widget _buildBusinessesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _favoriteBusinesses.length,
      itemBuilder: (context, index) {
        final business = _favoriteBusinesses[index];
        return AnimatedCard(
          delayMilliseconds: index * 100,
          child: _buildBusinessCard(business),
        );
      },
    );
  }

  Widget _buildBusinessCard(Business business) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen del negocio
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Efecto de partículas
                Positioned.fill(
                  child: ParticleEffect(
                    particleCount: 15,
                    particleColor: Colors.white.withOpacity(0.2),
                    child: Container(),
                  ),
                ),
                // Contenido
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                // Estado del negocio
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                // Icono del negocio
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
                        // TODO: Implementar quitar de favoritos
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
                        onPressed: () {
                          // TODO: Navegar al menú del negocio
                        },
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
    );
  }

  Widget _buildProductsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay productos favoritos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora productos y agrégalos a tus favoritos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryGradientButton(
            text: 'Explorar Productos',
            icon: Icons.explore,
            onPressed: () {
              // TODO: Navegar a explorar productos
            },
          ),
        ],
      ),
    );
  }
}
