import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CommunityStoreProvider with ChangeNotifier {
  List<Business> _businesses = [];
  List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  List<Category> _categories = [];
  final List<String> _favorites = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _showOnlyAvailable = false;
  bool _showOnlyPopular = false;
  
  // Getters
  List<Business> get businesses => _businesses;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<Category> get categories => _categories;
  List<String> get favorites => _favorites;
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
  
  // Filtros
  List<Business> get filteredBusinesses {
    var filtered = _businesses.where((business) {
      final matchesCategory = _selectedCategory == 'all' || business.category == _selectedCategory;
      final matchesSearch = business.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (business.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
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
  
  List<Product> getProductsByBusiness(String businessId) {
    return _products.where((product) => product.businessId == businessId).toList();
  }
  
  // Método loadData (alias para loadBusinesses)
  Future<void> loadData() async {
    return loadBusinesses();
  }
  
  // Métodos principales
  Future<void> loadBusinesses() async {
    debugPrint('🚀 CommunityStoreProvider.loadBusinesses - INICIO');
    _isLoading = true;
    notifyListeners();
    
    try {
      // Cargar desde Django API SOLAMENTE
      debugPrint('📞 Llamando a ApiService.getBusinesses()...');
      final apiService = ApiService();
      final businesses = await apiService.getBusinesses();
      
      debugPrint('📞 Llamando a ApiService.getProducts()...');
      final products = await apiService.getProducts();
      
      // Asignar datos de la API (incluso si está vacío)
      _businesses = businesses;
      _products = products;
      _loadCategories();
      
      debugPrint('✅ Negocios cargados desde Django: ${businesses.length}');
      debugPrint('✅ Productos cargados desde Django: ${products.length}');
      
      if (businesses.isNotEmpty) {
        debugPrint('📋 Primer negocio: ${businesses.first.name}');
      }
    } catch (e, stackTrace) {
      // Error conectando con Django
      debugPrint('❌ Error cargando desde API: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      // Dejar listas vacías si hay error
      _businesses = [];
      _products = [];
      _loadCategories();
    }
    
    _isLoading = false;
    notifyListeners();
    debugPrint('🏁 CommunityStoreProvider.loadBusinesses - FIN');
  }
  
  // Implementación de loadProductsByBusiness
  Future<void> loadProductsByBusiness(String businessId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final apiService = ApiService();
      final products = await apiService.getProducts(businessId: businessId);
      
      if (products.isNotEmpty) {
        // Filtrar productos del negocio
        _products = products;
      }
    } catch (e) {
      debugPrint('Error cargando productos: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Método addToCart corregido
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      _cartItems.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: quantity,
          imageUrl: product.imageUrl,
          businessId: product.businessId,
          businessName: getBusinessById(product.businessId)?.name ?? 'Negocio',
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
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
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  // Métodos de favoritos
  void toggleFavorite(String businessId) {
    if (_favorites.contains(businessId)) {
      _favorites.remove(businessId);
    } else {
      _favorites.add(businessId);
    }
    notifyListeners();
  }

  bool isFavorite(String businessId) {
    return _favorites.contains(businessId);
  }
  
  // Métodos de filtrado
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setCategory(String category) {
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
  
  // Implementación de métodos privados para cargar datos de ejemplo
  void _loadMockBusinesses() {
    _businesses = [
      Business(
        id: '1',
        name: 'Restaurante Doña María',
        description: 'Comida casera con el sabor de la abuela',
        imageUrl: 'assets/images/businesses/business_restaurante_dona_maria.jpg',
        category: 'food',
        address: 'Calle 10 #45-67, Barrio Centro',
        phone: '+57 300 123 4567',
        rating: 4.8,
        latitude: 14.0723,
        longitude: -87.2068,
        tags: ['Sancocho', 'Bandeja Paisa', 'Ajiaco'],
      ),
      Business(
        id: '2',
        name: 'Panadería El Amanecer',
        description: 'Pan fresco todos los días desde las 5 AM',
        imageUrl: 'assets/images/businesses/business_panaderia_el_amanecer.jpg',
        category: 'bakery',
        address: 'Carrera 15 #23-45, Barrio Norte',
        phone: '+57 301 234 5678',
        rating: 4.9,
        latitude: 14.0823,
        longitude: -87.1968,
        tags: ['Pan Integral', 'Croissants', 'Tortas'],
      ),
      Business(
        id: '3',
        name: 'Frutería La Cosecha',
        description: 'Frutas y verduras frescas directo del campo',
        imageUrl: 'assets/images/businesses/business_fruteria_la_cosecha.jpg',
        category: 'fruits',
        address: 'Avenida 20 #12-34, Barrio Sur',
        phone: '+57 302 345 6789',
        rating: 4.7,
        latitude: 14.0623,
        longitude: -87.2168,
        tags: ['Frutas Tropicales', 'Verduras Orgánicas', 'Jugos Naturales'],
      ),
      Business(
        id: '4',
        name: 'Boutique Alma',
        description: 'Ropa femenina y accesorios',
        imageUrl: 'assets/images/businesses/business_boutique_alma.jpg',
        category: 'fashion',
        address: 'C.C. Central, Local 12',
        phone: '+57 303 111 2222',
        rating: 4.6,
        latitude: 14.0751,
        longitude: -87.2051,
        tags: ['Vestidos', 'Blusas', 'Accesorios'],
      ),
      Business(
        id: '5',
        name: 'Joyas Brillantes',
        description: 'Joyería artesanal y plata',
        imageUrl: 'assets/images/businesses/business_joyas_brillantes.jpg',
        category: 'jewelry',
        address: 'Av. Principal #45',
        phone: '+57 304 222 3333',
        rating: 4.7,
        latitude: 14.0788,
        longitude: -87.2090,
        tags: ['Anillos', 'Collares', 'Pulseras'],
      ),
      Business(
        id: '6',
        name: 'TecnoMundo',
        description: 'Electrónica y gadgets',
        imageUrl: 'assets/images/businesses/business_tecnomundo.jpg',
        category: 'electronics',
        address: 'C.C. Tech Plaza, Local 5',
        phone: '+57 305 333 4444',
        rating: 4.5,
        latitude: 14.0814,
        longitude: -87.2034,
        tags: ['Auriculares', 'Smartphones', 'Accesorios'],
      ),
      Business(
        id: '7',
        name: 'Hogar & Deco',
        description: 'Decoración y artículos para el hogar',
        imageUrl: 'assets/images/businesses/business_hogar_deco.jpg',
        category: 'home',
        address: 'Calle 8 #12-90',
        phone: '+57 306 444 5555',
        rating: 4.4,
        latitude: 14.0799,
        longitude: -87.2005,
        tags: ['Decoración', 'Textiles', 'Organización'],
      ),
      Business(
        id: '8',
        name: 'Belleza Natural',
        description: 'Cosmética y cuidado personal',
        imageUrl: 'assets/images/businesses/business_belleza_natural.jpg',
        category: 'beauty',
        address: 'Pasaje Norte, Local 3',
        phone: '+57 307 666 7777',
        rating: 4.6,
        latitude: 14.0777,
        longitude: -87.2077,
        tags: ['Skincare', 'Maquillaje', 'Belleza'],
      ),
    ];
  }

  void _loadProducts() {
    _products = [
      // Productos de Doña María
      Product(
        id: 'p1',
        name: 'Bandeja Paisa Completa',
        description: 'Frijoles, arroz, carne molida, chicharrón, chorizo, huevo, plátano y arepa',
        price: 18000,
        imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400',
        businessId: '1',
        isPopular: true,
      ),
      Product(
        id: 'p2',
        name: 'Sancocho de Gallina',
        description: 'Sancocho tradicional con gallina criolla y verduras frescas',
        price: 15000,
        imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        businessId: '1',
        isPopular: true,
      ),
      // Productos de Panadería El Amanecer
      Product(
        id: 'p3',
        name: 'Pan Integral Artesanal',
        description: 'Pan integral con semillas, horneado en horno de leña',
        price: 4500,
        imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400',
        businessId: '2',
        isPopular: false,
      ),
      Product(
        id: 'p4',
        name: 'Croissants Franceses',
        description: 'Croissants mantequillosos recién horneados',
        price: 3500,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab794f4afe5e?w=400',
        businessId: '2',
        isPopular: true,
      ),
      // Productos de Frutería La Cosecha
      Product(
        id: 'p5',
        name: 'Canasta de Frutas Tropicales',
        description: 'Mango, piña, papaya, maracuyá y guayaba',
        price: 12000,
        imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400',
        businessId: '3',
        isPopular: true,
      ),

      // Nuevos productos: marketplace
      Product(
        id: 'p6',
        name: 'Vestido Floral',
        description: 'Vestido midi floral, tela ligera',
        price: 85000,
        imageUrl: 'https://images.unsplash.com/photo-1521335629791-ce4aec67dd53?w=400',
        businessId: '4',
        isPopular: true,
      ),
      Product(
        id: 'p7',
        name: 'Collar Plata 925',
        description: 'Collar minimalista de plata 925',
        price: 120000,
        imageUrl: 'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400',
        businessId: '5',
        isPopular: true,
      ),
      Product(
        id: 'p8',
        name: 'Auriculares Bluetooth',
        description: 'Auriculares inalámbricos con cancelación de ruido',
        price: 150000,
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
        businessId: '6',
        isPopular: true,
      ),
      Product(
        id: 'p9',
        name: 'Set de Cojines Decorativos',
        description: 'Set de 2 cojines tejidos',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=400',
        businessId: '7',
        isPopular: false,
      ),
      Product(
        id: 'p10',
        name: 'Serum Vitamina C',
        description: 'Serum iluminador y antioxidante',
        price: 60000,
        imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc0?w=400',
        businessId: '8',
        isPopular: true,
      ),
    ];
  }
//Slider de categorias
  void _loadCategories() {
    _categories = [
      Category(
        id: 'all',
        name: 'Todos',
        description: 'Todos los productos',
        icon: 'assets/images/icons/all.png',
      ),
      Category(
        id: 'food',
        name: 'Comida',
        description: 'Platos preparados y alimentos',
        icon: 'assets/images/icons/food.png',
      ),
      Category(
        id: 'groceries',
        name: 'Abarrotes',
        description: 'Productos básicos y despensa',
        icon: 'assets/images/icons/despensa.png',
      ),
      Category(
        id: 'bakery',
        name: 'Panadería',
        description: 'Panes y pasteles frescos',
        icon: 'assets/images/icons/panadero.png',
      ),
      Category(
        id: 'fruits',
        name: 'Frutas y Verduras',
        description: 'Productos frescos',
        icon: 'assets/images/icons/verduras.png',
      ),

      // Nuevas categorías: marketplace
              Category(
          id: 'fashion',
          name: 'Moda',
          description: 'Ropa y accesorios',
          icon: 'assets/images/icons/vestido-nuevo.png',
        ),
        Category(
          id: 'jewelry',
          name: 'Joyería',
          description: 'Accesorios y joyas',
          icon: 'assets/images/icons/joyeria.png',
        ),
        Category(
          id: 'electronics',
          name: 'Electrónica',
          description: 'Gadgets y tecnología',
          icon: 'assets/images/icons/tienda-online.png',
        ),
        Category(
          id: 'home',
          name: 'Hogar',
          description: 'Decoración y utensilios',
          icon: 'assets/images/icons/sala-de-estar.png',
        ),
        Category(
          id: 'beauty',
          name: 'Belleza',
          description: 'Cosmética y cuidado personal',
          icon: 'assets/images/icons/salon-de-belleza.png',
        ),
    ];
  }
}