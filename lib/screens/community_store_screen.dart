/**
 * 🏪 PANTALLA DE TIENDA COMUNITARIA
 * 
 * Esta pantalla es el centro comercial de la aplicación donde los usuarios
 * pueden explorar y descubrir negocios locales.
 * Funcionalidades principales:
 * - Header promocional con mensaje de apoyo comunitario
 * - Barra de búsqueda de negocios
 * - Filtros por categorías (comida, productos, servicios)
 * - Lista de negocios con información detallada
 * - Sistema de favoritos
 * - Acceso directo al carrito de compras
 * - Navegación a detalles de cada negocio
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart'; // 🛒 Gestión de tienda comunitaria
import '../models/business.dart';                    // 🏪 Modelo de datos de negocio
import 'business_detail_screen.dart';               // 📄 Pantalla de detalles del negocio
import 'cart_screen.dart';                          // 🛒 Pantalla del carrito de compras

class CommunityStoreScreen extends StatefulWidget {
  const CommunityStoreScreen({super.key});

  @override
  State<CommunityStoreScreen> createState() => _CommunityStoreScreenState();
}

class _CommunityStoreScreenState extends State<CommunityStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityStoreProvider>(context, listen: false).loadData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFBF360C), Color(0xFFD84315)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'FlowDelivery - Tienda Comunitaria',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
        elevation: 8,
        shadowColor: const Color(0xFFBF360C).withOpacity(0.3),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<CommunityStoreProvider>(builder: (context, provider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBF360C).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBF360C), width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${provider.cartItemCount}',
                          style: const TextStyle(
                            color: Color(0xFFBF360C),
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
          _buildHeader(),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFBF360C), Color(0xFFD84315)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBF360C).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            '🏪 Apoya a tu Comunidad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Descubre los mejores productos de microempresarios locales',
            style: TextStyle(
              color: Colors.white,
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
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar negocios locales...',
            hintStyle: const TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              color: Colors.grey,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.search,
                color: Color(0xFFBF360C),
                size: 24,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFBF360C), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFBF360C),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? const Color(0xFFBF360C).withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFBF360C),
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
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No se encontraron negocios',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
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
  
  Widget _buildBusinessCard(Business business, CommunityStoreProvider provider) {
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
                      business.imageUrl ?? 'https://via.placeholder.com/400x200?text=Sin+Imagen',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: const Icon(
                            Icons.store,
                            size: 60,
                            color: Colors.white,
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
                          color: Colors.white,
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
                              ? const Color(0xFFBF360C)
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
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                business.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Color(0xFFBF360C)),
                        const SizedBox(width: 6),
                        Text(
                          'Negocio Local',  // Reemplazando business.ownerName que no existe
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBF360C),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBF360C), Color(0xFFD84315)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
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