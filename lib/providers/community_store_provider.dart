import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';

class CommunityStoreProvider with ChangeNotifier {
  List<Business> _businesses = [];
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  List<Category> _categories = [];
  List<String> _favorites = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Getters
  List<Business> get businesses => _businesses;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<Category> get categories => _categories;
  List<String> get favorites => _favorites;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Filtros
  List<Business> get filteredBusinesses {
    var filtered = _businesses.where((business) {
      final matchesCategory = _selectedCategory == 'all' || business.category == _selectedCategory;
      final matchesSearch = business.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           business.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    
    return filtered;
  }
  
  List<Product> getProductsByBusiness(String businessId) {
    return _products.where((product) => product.businessId == businessId).toList();
  }
  
  // Métodos principales
  Future<void> loadBusinesses() async {
    _isLoading = true;
    notifyListeners();
    
    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 500));
    _loadBusinesses();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadProductsByBusiness(String businessId) async {
    _isLoading = true;
    notifyListeners();
    
    // Simular carga de productos específicos del negocio
    await Future.delayed(const Duration(milliseconds: 300));
    // Los productos ya están cargados en _loadProducts()
    
    _isLoading = false;
    notifyListeners();
  }
  
  void loadData() {
    _loadCategories();
    _loadBusinesses();
    _loadProducts();
    notifyListeners();
  }
  
  void _loadCategories() {
    _categories = [
      Category(id: 'all', name: 'Todos', icon: '🏪', description: 'Todos los negocios'),
      Category(id: 'food', name: 'Comida Casera', icon: '🍲', description: 'Comida casera y tradicional'),
      Category(id: 'bakery', name: 'Panadería', icon: '🥖', description: 'Pan fresco y repostería'),
      Category(id: 'fruits', name: 'Frutas y Verduras', icon: '🍎', description: 'Productos frescos del campo'),
      Category(id: 'empanadas', name: 'Empanadas', icon: '🥟', description: 'Empanadas artesanales'),
      Category(id: 'drinks', name: 'Bebidas', icon: '🧃', description: 'Jugos naturales y bebidas'),
    ];
  }

  void _loadBusinesses() {
    _businesses = [
      Business(
        id: '1',
        name: 'Cocina de Doña María',
        description: 'Comida casera tradicional con el sabor de siempre',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
        category: 'food',
        address: 'Calle 123 #45-67, Barrio Centro',
        phone: '+57 300 123 4567',
        rating: 4.8,
        specialties: ['Sancocho', 'Bandeja Paisa', 'Ajiaco'],
        ownerName: 'María González',
        story: 'Con más de 20 años de experiencia, Doña María prepara los platos más deliciosos del barrio con recetas familiares.',
        deliveryTime: '30-45 min',
        deliveryFee: 3000.0,
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
        specialties: ['Pan Integral', 'Croissants', 'Tortas'],
        ownerName: 'Carlos Ramírez',
        story: 'Tradición familiar de tres generaciones horneando el mejor pan del barrio.',
        deliveryTime: '20-30 min',
        deliveryFee: 2500.0,
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
        specialties: ['Frutas Tropicales', 'Verduras Orgánicas', 'Jugos Naturales'],
        ownerName: 'Ana Morales',
        story: 'Conectamos directamente a los campesinos con la comunidad, garantizando frescura y precios justos.',
        deliveryTime: '25-35 min',
        deliveryFee: 2000.0,
      ),
      Business(
        id: '4',
        name: 'Empanadas La Tradición',
        description: 'Empanadas artesanales con recetas ancestrales',
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
        category: 'empanadas',
        address: 'Calle 8 #56-78, Barrio Oeste',
        phone: '+57 303 456 7890',
        rating: 4.6,
        specialties: ['Empanadas de Pollo', 'Empanadas de Carne', 'Empanadas Vegetarianas'],
        ownerName: 'Luis Herrera',
        story: 'Recetas familiares transmitidas de generación en generación, cada empanada es una obra de arte.',
        deliveryTime: '15-25 min',
        deliveryFee: 2500.0,
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
      Product(
        id: 'p6',
        name: 'Verduras Orgánicas del Día',
        description: 'Selección de verduras frescas cultivadas sin químicos',
        price: 8000,
        imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
        businessId: '3',
        isPopular: false,
      ),
      // Productos de Empanadas La Tradición
      Product(
        id: 'p7',
        name: 'Empanadas de Pollo (6 unidades)',
        description: 'Empanadas criollas rellenas de pollo desmechado',
        price: 9000,
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
        businessId: '4',
        isPopular: true,
      ),
      Product(
        id: 'p8',
        name: 'Empanadas Vegetarianas (6 unidades)',
        description: 'Empanadas rellenas de verduras y queso',
        price: 8500,
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
        businessId: '4',
        isPopular: false,
      ),
    ];
  }

  // Métodos del carrito - Corregido para aceptar Product y quantity
  void addToCart(Product product, [int quantity = 1]) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      final business = _businesses.firstWhere((b) => b.id == product.businessId);
      _cartItems.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        imageUrl: product.imageUrl,
        businessId: product.businessId,
        businessName: business.name,
      ));
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
  
  // Métodos de filtros
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}