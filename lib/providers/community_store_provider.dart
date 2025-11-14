import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/map_service.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/promotion.dart';
import '../config/category_config.dart';

class CommunityStoreProvider with ChangeNotifier {
  List<Business> _businesses = [];
  List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  List<Category> _categories = [];
  final List<String> _favorites = [];
  final List<String> _favoriteProductIds = [];
  final List<Promotion> _promotions = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _showOnlyAvailable = false;
  bool _showOnlyPopular = false;
  
  // Constantes para SharedPreferences
  static const String _cartKey = 'cart_items';
  static const String _favoritesKey = 'favorites';
  static const String _favoriteProductsKey = 'favorite_products';
  
  // Constructor - cargar datos persistentes al inicializar
  CommunityStoreProvider() {
    _loadCart();
    _loadFavorites();
  }
  
  // Getters
  List<Business> get businesses => _businesses;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<Category> get categories => _categories;
  List<String> get favorites => _favorites;
  List<String> get favoriteProducts => _favoriteProductIds;
  List<Promotion> get promotions => List.unmodifiable(_promotions);
  List<Promotion> get activePromotions => _promotions
      .where((promotion) => promotion.isCurrentlyActive)
      .toList();

  Promotion? getPromotionForProduct(String productId) {
    final now = DateTime.now();
    Promotion? bestPromotion;
    for (final promotion in _promotions) {
      if (promotion.productId != productId) continue;
      if (!promotion.isActive) continue;
      if (promotion.startDate != null && promotion.startDate!.isAfter(now)) {
        continue;
      }
      if (promotion.endDate != null && promotion.endDate!.isBefore(now)) {
        continue;
      }
      if (bestPromotion == null ||
          promotion.discountPercent > bestPromotion.discountPercent) {
        bestPromotion = promotion;
      }
    }
    return bestPromotion;
  }

  Product _applyPromotionToProduct(Product product, {Promotion? promotion}) {
    final effectivePromotion = promotion ?? getPromotionForProduct(product.id);
    return product.copyWith(
      promotionalPrice: effectivePromotion?.promotionalPrice,
      promotionalDiscountPercent: effectivePromotion?.discountPercent,
      promotionId: effectivePromotion?.id,
      promotionEndDate: effectivePromotion?.endDate,
    );
  }
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get showOnlyAvailable => _showOnlyAvailable;
  bool get showOnlyPopular => _showOnlyPopular;
  
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Método faltante - getBusinessById
  Business? getBusinessById(String businessId) {
    try {
      return _businesses.firstWhere((business) => business.id == businessId);
    } catch (e) {
      return null;
    }
  }

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  // Filtros
  List<Business> get filteredBusinesses {
    final lowerQuery = _searchQuery.toLowerCase();

    final filtered = _businesses.where((business) {
      final matchesCategory = _selectedCategory == 'all' || _businessMatchesCategory(business, _selectedCategory);
      if (!matchesCategory) return false;

      if (lowerQuery.isEmpty) return true;

      final nameMatch = business.name.toLowerCase().contains(lowerQuery);
      final descriptionMatch = business.description?.toLowerCase().contains(lowerQuery) ?? false;
      final tagsMatch = business.tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false;

      return nameMatch || descriptionMatch || tagsMatch;
    }).toList();

    return filtered;
  }
  
  List<Product> get filteredProducts {
    List<Product> filtered = _products;
    
    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Filtro por precio
    filtered = filtered.where((product) {
      return product.price >= _minPrice && product.price <= _maxPrice;
    }).toList();
    
    // Filtro por disponibilidad
    if (_showOnlyAvailable) {
      filtered = filtered.where((product) => product.available).toList();
    }
    
    // Filtro por popularidad
    if (_showOnlyPopular) {
      filtered = filtered.where((product) => product.isPopular).toList();
    }
    
    return filtered;
  }

  bool _businessMatchesCategory(Business business, String categoryId) {
    if (categoryId == 'all') return true;
    final normalizedCategory = categoryId.toLowerCase().trim();

    final categories = <String>{
      business.category.toLowerCase().trim(),
      CategoryConfig.getMainCategory(business.category).toLowerCase(),
    };

    final tags = business.tags ?? const [];
    for (final tag in tags) {
      categories.add(tag.toLowerCase().trim());
      categories.add(CategoryConfig.getMainCategory(tag).toLowerCase());
    }

    return categories.contains(normalizedCategory);
  }
  
  List<Product> getProductsByBusiness(String businessId) {
    final business = getBusinessById(businessId);
    final ownerId = business?.ownerId;

    return _products.where((product) {
      if (product.businessId == businessId) {
        return true;
      }
      if (ownerId != null && ownerId.isNotEmpty && product.businessId == ownerId) {
        return true;
      }
      return false;
    }).toList();
  }
  
  // Método loadData (alias para loadBusinesses)
  Future<void> loadData() async {
    await loadBusinesses();
    await loadPromotions();
  }
  
  // Métodos principales
  Future<void> loadBusinesses() async {
    debugPrint('🚀 CommunityStoreProvider.loadBusinesses - INICIO');
    _isLoading = true;
    notifyListeners();
    
    List<Business> allBusinesses = [];
    
    _products = [];
    final firestore = FirebaseFirestore.instance;

    // Cargar desde Firestore
    try {
      debugPrint('📞 Intentando cargar desde Firestore...');
      final querySnapshot = await firestore.collection('businesses').get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final firestoreBusinesses = querySnapshot.docs.map((doc) {
          final data = doc.data();
          GeoPoint? geoPoint;
          final locationField = data['location'];
          if (locationField is GeoPoint) {
            geoPoint = locationField;
          }
          final latitude = _extractLatitude(data) ?? geoPoint?.latitude;
          final longitude = _extractLongitude(data) ?? geoPoint?.longitude;
          return Business(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? data['category_name'] ?? '',
            description: data['description'],
            address: data['address'],
            phone: data['phone'],
            latitude: latitude,
            longitude: longitude,
            rating: _nullableDouble(data['rating']),
            imageUrl: data['imageUrl'] ?? data['image_url'],
            isActive: data['isActive'] ?? data['is_active'] ?? true,
            isOpen: data['isOpen'] ?? data['is_open'] ?? true,
            tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
            ownerId: data['ownerId']?.toString() ??
                data['ownerUid']?.toString() ??
                data['owner_uid']?.toString(),
          );
        }).toList();
        
        // Combinar negocios de API y Firestore (sin duplicados)
        final existingIds = allBusinesses.map((b) => b.id).toSet();
        final newBusinesses = firestoreBusinesses.where((b) => !existingIds.contains(b.id));
        
        if (newBusinesses.isNotEmpty) {
          allBusinesses.addAll(newBusinesses);
          debugPrint('✅ Agregados ${newBusinesses.length} negocios nuevos desde Firestore');
        } else {
          debugPrint('ℹ️ No hay negocios nuevos en Firestore');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error cargando desde Firestore: $e');
    }
    
    // Combinar productos desde Firestore (incluye productos creados desde el panel de negocio)
    try {
      debugPrint('📦 Sincronizando productos desde Firestore...');
      final firestoreInstance = FirebaseFirestore.instance;
      final productSnapshot = await firestoreInstance.collection('products').get();

      final existingProductIds = _products.map((p) => p.id).toSet();
      final Map<String, String> ownerToBusinessId = {};

      for (final business in allBusinesses) {
        final ownerId = business.ownerId;
        if (ownerId != null && ownerId.isNotEmpty) {
          ownerToBusinessId[ownerId] = business.id;
        }
      }

      for (final doc in productSnapshot.docs) {
        try {
          final data = doc.data();
          final ownerUid = data['ownerUid']?.toString();
          String businessId = data['businessId']?.toString() ?? '';

          if (ownerUid != null && ownerToBusinessId.containsKey(ownerUid)) {
            businessId = ownerToBusinessId[ownerUid]!;
          } else if (ownerToBusinessId.containsKey(businessId)) {
            businessId = ownerToBusinessId[businessId]!;
          } else if (businessId.isEmpty && ownerUid != null) {
            businessId = ownerUid;
          }

          final product = Product(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: _safeToDouble(data['price']),
            imageUrl: data['imageUrl'] ?? data['image_url'],
            businessId: businessId,
            available: data['available'] ?? true,
            isPopular: data['isPopular'] ?? data['is_popular'] ?? false,
            stock: _safeToInt(data['stock']),
            firestoreBusinessId: data['businessFirestoreId']?.toString() ?? doc.id,
          );

          if (!existingProductIds.contains(product.id)) {
            _products.add(_applyPromotionToProduct(product));
            existingProductIds.add(product.id);
          }

          // Normalizar el businessId en Firestore si encontramos el documento del negocio
          if (ownerUid != null && ownerToBusinessId.containsKey(ownerUid)) {
            final resolvedBusinessId = ownerToBusinessId[ownerUid]!;
            final updates = <String, dynamic>{};
            if (data['businessId'] != resolvedBusinessId) {
              updates['businessId'] = resolvedBusinessId;
            }
            if ((data['businessFirestoreId']?.toString() ?? doc.id) != product.firestoreBusinessId) {
              updates['businessFirestoreId'] = product.firestoreBusinessId;
            }
            if ((data['ownerUid']?.toString() ?? '') != ownerUid) {
              updates['ownerUid'] = ownerUid;
            }
            if (updates.isNotEmpty) {
              await doc.reference.update(updates);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error parseando producto ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error sincronizando productos desde Firestore: $e');
    }

    // Asignar todos los negocios combinados
    for (var i = 0; i < allBusinesses.length; i++) {
      final business = allBusinesses[i];
      final needsCoordinates = business.latitude == null || business.longitude == null;
      final hasAddress = (business.address?.trim().isNotEmpty ?? false);

      if (needsCoordinates && hasAddress) {
        try {
          final normalizedAddress = MapService.normalizeAddress(business.address!.trim());
          final coords = await MapService.getCoordinatesFromAddress(normalizedAddress);
          if (coords != null) {
            final updatedBusiness = business.copyWith(
              latitude: coords.latitude,
              longitude: coords.longitude,
            );
            allBusinesses[i] = updatedBusiness;
            try {
              await firestore.collection('businesses').doc(business.id).update({
                'latitude': coords.latitude,
                'longitude': coords.longitude,
                'location': GeoPoint(coords.latitude, coords.longitude),
              });
              debugPrint('📍 Coordenadas actualizadas para negocio ${business.id}');
            } catch (e) {
              debugPrint('ℹ️ No se pudo persistir ubicación para ${business.id}: $e');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error obteniendo coordenadas para ${business.id}: $e');
        }
      }
    }

    _businesses = allBusinesses;
    _loadCategories();
    
    debugPrint('📊 Total de negocios cargados: ${_businesses.length}');
    
    _isLoading = false;
    notifyListeners();
    debugPrint('🏁 CommunityStoreProvider.loadBusinesses - FIN');
  }
  
  // Implementación de loadProductsByBusiness
  Future<void> loadProductsByBusiness(String businessId) async {
    _isLoading = true;
    notifyListeners();
    
    final List<Product> combinedProducts = [];
    final existingIds = <String>{};

    void addProduct(Product product) {
      if (existingIds.add(product.id)) {
        combinedProducts.add(product);
      }
    }

    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final business = getBusinessById(businessId);
      final ownerId = business?.ownerId;

      final queries = <QuerySnapshot<Map<String, dynamic>>>[];

      final primary = await firestoreInstance
          .collection('products')
          .where('businessId', isEqualTo: businessId)
          .get();
      queries.add(primary);

      if (ownerId != null && ownerId.isNotEmpty && ownerId != businessId) {
        final ownerQuery = await firestoreInstance
            .collection('products')
            .where('ownerUid', isEqualTo: ownerId)
            .get();
        queries.add(ownerQuery);
      }

      for (final query in queries) {
        for (final doc in query.docs) {
          try {
            final data = doc.data();
            final ownerUid = data['ownerUid']?.toString();
            String resolvedBusinessId = data['businessId']?.toString() ?? businessId;

            if (resolvedBusinessId == businessId) {
              // ok
            } else if (ownerUid != null && ownerUid == ownerId) {
              resolvedBusinessId = businessId;
              if (data['businessId'] != resolvedBusinessId) {
                await doc.reference.update({'businessId': resolvedBusinessId});
              }
            }

            final product = Product(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              price: _safeToDouble(data['price']),
              imageUrl: data['imageUrl'] ?? data['image_url'],
              businessId: resolvedBusinessId,
              available: data['available'] ?? true,
              isPopular: data['isPopular'] ?? data['is_popular'] ?? false,
              stock: _safeToInt(data['stock']),
              firestoreBusinessId: data['businessFirestoreId']?.toString() ?? doc.id,
            );

            addProduct(_applyPromotionToProduct(product));
          } catch (e) {
            debugPrint('⚠️ Error parseando producto ${doc.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cargando productos desde Firestore: $e');
    }

    _products = combinedProducts;
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Método addToCart corregido
  void addToCart(Product product, {int quantity = 1}) {
    final promotion = getPromotionForProduct(product.id);
    final priceToUse = promotion?.promotionalPrice ?? product.price;
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
        price: priceToUse,
      );
    } else {
      _cartItems.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          productName: product.name,
          price: priceToUse,
          quantity: quantity,
          imageUrl: product.imageUrl,
          businessId: product.businessId,
          businessName: getBusinessById(product.businessId)?.name ?? 'Negocio',
            businessFirestoreId: product.firestoreBusinessId,
        ),
      );
    }
    _saveCart(); // Guardar cambios automáticamente
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    _saveCart(); // Guardar cambios automáticamente
    notifyListeners();
  }
  
  void updateCartItemQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }
    
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      _saveCart(); // Guardar cambios automáticamente
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart(); // Guardar cambios
    notifyListeners();
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
  
  // Métodos de persistencia del carrito
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        _cartItems.clear();
        _cartItems.addAll(
          cartList.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        );
        debugPrint('🛒 Carrito cargado desde SharedPreferences: ${_cartItems.length} items');
      }
    } catch (e) {
      debugPrint('❌ Error cargando carrito: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
      debugPrint('💾 Carrito guardado en SharedPreferences: ${_cartItems.length} items');
    } catch (e) {
      debugPrint('❌ Error guardando carrito: $e');
    }
  }

  // Métodos de persistencia de favoritos
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      final favoriteProductsJson = prefs.getString(_favoriteProductsKey);
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        _favorites
          ..clear()
          ..addAll(favoritesList.cast<String>());
        debugPrint('❤️ Favoritos cargados desde SharedPreferences: ${_favorites.length} negocios');
      }

      if (favoriteProductsJson != null) {
        final List<dynamic> favoritesList = json.decode(favoriteProductsJson);
        _favoriteProductIds
          ..clear()
          ..addAll(favoritesList.cast<String>());
        debugPrint('🍽 Productos favoritos cargados: ${_favoriteProductIds.length}');
      }
    } catch (e) {
      debugPrint('❌ Error cargando favoritos: $e');
    }
  }
  
  Future<void> _saveBusinessFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
      debugPrint('💾 Favoritos guardados (negocios): ${_favorites.length}');
    } catch (e) {
      debugPrint('❌ Error guardando favoritos de negocios: $e');
    }
  }

  Future<void> _saveProductFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favoriteProductIds);
      await prefs.setString(_favoriteProductsKey, favoritesJson);
      debugPrint('💾 Favoritos guardados (productos): ${_favoriteProductIds.length}');
    } catch (e) {
      debugPrint('❌ Error guardando favoritos de productos: $e');
    }
  }
  
  // Métodos de favoritos
  void toggleFavorite(String businessId) {
    if (_favorites.contains(businessId)) {
      _favorites.remove(businessId);
    } else {
      _favorites.add(businessId);
    }
    _saveBusinessFavorites(); // Guardar cambios automáticamente
    notifyListeners();
  }
  
  bool isFavorite(String businessId) {
    return _favorites.contains(businessId);
  }

  void toggleProductFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    _saveProductFavorites();
    notifyListeners();
  }

  bool isProductFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }
  
  // Métodos de filtrado
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }
  
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }
  
  void toggleAvailableOnly() {
    _showOnlyAvailable = !_showOnlyAvailable;
    notifyListeners();
  }
  
  void togglePopularOnly() {
    _showOnlyPopular = !_showOnlyPopular;
    notifyListeners();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'all';
    _minPrice = 0;
    _maxPrice = 1000;
    _showOnlyAvailable = false;
    _showOnlyPopular = false;
    notifyListeners();
  }

  double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }

  double? _extractLatitude(Map<String, dynamic> data) {
    final directCandidates = [
      data['latitude'],
      data['lat'],
      data['Latitude'],
      data['Lat'],
      data['latitud'],
      data['location_lat'],
      data['locationLat'],
    ];

    for (final candidate in directCandidates) {
      final value = _nullableDouble(candidate);
      if (value != null) return value;
    }

    final location = data['location'] ?? data['coords'] ?? data['coordinates'];
    return _extractFromLocation(location, isLatitude: true);
  }

  double? _extractLongitude(Map<String, dynamic> data) {
    final directCandidates = [
      data['longitude'],
      data['lng'],
      data['lon'],
      data['long'],
      data['Longitude'],
      data['Lng'],
      data['longitud'],
      data['location_lng'],
      data['locationLong'],
    ];

    for (final candidate in directCandidates) {
      final value = _nullableDouble(candidate);
      if (value != null) return value;
    }

    final location = data['location'] ?? data['coords'] ?? data['coordinates'];
    return _extractFromLocation(location, isLatitude: false);
  }

  double? _extractFromLocation(dynamic location, {required bool isLatitude}) {
    if (location == null) return null;

    if (location is GeoPoint) {
      return isLatitude ? location.latitude : location.longitude;
    }

    if (location is String) {
      final parts = location.split(',');
      if (parts.length >= 2) {
        final first = _nullableDouble(parts[0]);
        final second = _nullableDouble(parts[1]);
        if (first != null && second != null) {
          return isLatitude ? first : second;
        }
      } else {
        final value = _nullableDouble(location);
        if (value != null) {
          return value;
        }
      }
    }

    if (location is List && location.length >= 2) {
      final first = _nullableDouble(location[0]);
      final second = _nullableDouble(location[1]);
      if (first != null && second != null) {
        return isLatitude ? first : second;
      }
    }

    if (location is Map) {
      final lowerCaseMap = location.map(
        (key, value) => MapEntry(key.toString().toLowerCase(), value),
      );

      final candidates = isLatitude
          ? ['latitude', 'lat', '_latitude', 'latitud']
          : ['longitude', 'lng', 'lon', 'long', '_longitude', 'longitud'];

      for (final key in candidates) {
        if (lowerCaseMap.containsKey(key)) {
          final value = _nullableDouble(lowerCaseMap[key]);
          if (value != null) return value;
        }
      }
    }

    return null;
  }
  // Slider de categorias
  void _loadCategories() {
    _categories = [
      Category(
        id: 'all',
        name: 'Todos',
        description: 'Todos los negocios',
        icon: 'assets/images/icons/all.png',
      ),
      Category(
        id: 'food',
        name: 'Comida',
        description: 'Restaurantes y comida',
        icon: 'assets/images/icons/food.png',
      ),
      Category(
        id: 'groceries',
        name: 'Supermercados',
        description: 'Abarrotes y despensa',
        icon: 'assets/images/icons/despensa.png',
      ),
      Category(
        id: 'pharmacy',
        name: 'Farmacias',
        description: 'Medicamentos y salud',
        icon: 'assets/images/icons/farmacia.png',
      ),
      Category(
        id: 'electronics',
        name: 'Electrónicos',
        description: 'Tecnología y gadgets',
        icon: 'assets/images/icons/tienda-online.png',
      ),
      Category(
        id: 'fashion',
        name: 'Moda',
        description: 'Ropa y accesorios',
        icon: 'assets/images/icons/vestido-nuevo.png',
      ),
      Category(
        id: 'home',
        name: 'Hogar',
        description: 'Decoración y muebles',
        icon: 'assets/images/icons/sala-de-estar.png',
      ),
      Category(
        id: 'hardware',
        name: 'Ferretería',
        description: 'Herramientas y materiales',
        icon: 'assets/images/icons/ferreteria.png',
      ),
      Category(
        id: 'beauty',
        name: 'Belleza',
        description: 'Salones y cosmética',
        icon: 'assets/images/icons/salon-de-belleza.png',
      ),
      Category(
        id: 'automotive',
        name: 'Automotriz',
        description: 'Talleres y repuestos',
        icon: 'assets/images/icons/automotriz.png',
      ),
      Category(
        id: 'services',
        name: 'Servicios',
        description: 'Servicios profesionales',
        icon: 'assets/images/icons/servicios.png',
      ),
    ];
  }

  Future<void> loadPromotions() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('promotions').get();

      _promotions
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return Promotion.fromMap(data, doc.id);
        }).where((promotion) => promotion.isCurrentlyActive));

      final Map<String, Promotion> bestPromotionsByProduct = {};
      for (final promotion in _promotions) {
        final existing = bestPromotionsByProduct[promotion.productId];
        if (existing == null || promotion.discountPercent > existing.discountPercent) {
          bestPromotionsByProduct[promotion.productId] = promotion;
        }
      }

      for (var i = 0; i < _products.length; i++) {
        final product = _products[i];
        final promotion = bestPromotionsByProduct[product.id];
        _products[i] = _applyPromotionToProduct(product, promotion: promotion);
      }

      notifyListeners();
      debugPrint('🎯 Promociones activas: ${_promotions.length}');
    } catch (e) {
      debugPrint('❌ Error cargando promociones: $e');
    }
  }
}
