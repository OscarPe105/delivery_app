import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';

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
    _isLoading = true;
    notifyListeners();
    
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    
    _loadMockBusinesses();
    _loadProducts();
    _loadCategories();
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Implementación de loadProductsByBusiness
  Future<void> loadProductsByBusiness(String businessId) async {
    _isLoading = true;
    notifyListeners();
    
    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Los productos ya están cargados en _products, solo notificamos cambios
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
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        category: 'restaurant',
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
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
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
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
        category: 'fruits',
        address: 'Avenida 20 #12-34, Barrio Sur',
        phone: '+57 302 345 6789',
        rating: 4.7,
        latitude: 14.0623,
        longitude: -87.2168,
        tags: ['Frutas Tropicales', 'Verduras Orgánicas', 'Jugos Naturales'],
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
    ];
  }

  void _loadCategories() {
    _categories = [
      Category(
        id: 'all',
        name: 'Todos',
        description: 'Todos los productos',
        icon: '🛒', // Cambiado de 'assets/icons/all.png'
      ),
      Category(
        id: 'food',
        name: 'Comida',
        description: 'Platos preparados y alimentos',
        icon: '🍽️', // Cambiado de 'assets/icons/food.png'
      ),
      Category(
        id: 'groceries',
        name: 'Abarrotes',
        description: 'Productos básicos y despensa',
        icon: '🛒', // Cambiado de 'assets/icons/groceries.png'
      ),
      Category(
        id: 'bakery',
        name: 'Panadería',
        description: 'Panes y pasteles frescos',
        icon: '🍞', // Cambiado de 'assets/icons/bakery.png'
      ),
      Category(
        id: 'fruits',
        name: 'Frutas y Verduras',
        description: 'Productos frescos',
        icon: '🍎', // Cambiado de 'assets/icons/fruits.png'
      ),
    ];
  }
}