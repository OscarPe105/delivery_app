import React, { createContext, useContext, useState, useEffect } from 'react';

export interface Business {
  id: string;
  name: string;
  description: string;
  image: string;
  category: string;
  rating: number;
  deliveryTime: string;
  deliveryFee: number;
  isLocal: boolean;
  address: string;
  phone: string;
}

export interface Product {
  id: string;
  name: string;
  price: number;
  description: string;
  image: string;
  category: string;
  businessId: string;
  businessName: string;
  available: boolean;
  isPopular: boolean;
}

export interface CartItem extends Product {
  quantity: number;
}

export interface Order {
  id: string;
  items: CartItem[];
  total: number;
  deliveryFee: number;
  status: 'pending' | 'confirmed' | 'preparing' | 'on_way' | 'delivered';
  date: string;
  estimatedTime: string;
  customerInfo: {
    name: string;
    phone: string;
    address: string;
    notes?: string;
  };
}

export interface User {
  id: string;
  name: string;
  phone: string;
  address: string;
}

interface AppContextType {
  user: User | null;
  setUser: (user: User | null) => void;
  businesses: Business[];
  products: Product[];
  cart: CartItem[];
  orders: Order[];
  currentView: string;
  selectedBusiness: Business | null;
  setCurrentView: (view: string) => void;
  setSelectedBusiness: (business: Business | null) => void;
  addToCart: (product: Product) => void;
  removeFromCart: (productId: string) => void;
  updateCartQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  placeOrder: (customerInfo: Order['customerInfo']) => void;
  getProductsByBusiness: (businessId: string) => Product[];
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [currentView, setCurrentView] = useState('home');
  const [selectedBusiness, setSelectedBusiness] = useState<Business | null>(null);

  // Mock businesses data - microempresarios locales
  const businesses: Business[] = [
    {
      id: '1',
      name: 'Doña María - Comida Casera',
      description: 'Comida tradicional preparada con amor, como en casa de la abuela',
      image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
      category: 'Comida Casera',
      rating: 4.9,
      deliveryTime: '30-45 min',
      deliveryFee: 2.50,
      isLocal: true,
      address: 'Barrio Centro, Calle Principal #123',
      phone: '+57 300 123 4567'
    },
    {
      id: '2',
      name: 'Panadería El Amanecer',
      description: 'Pan fresco horneado diariamente desde 1985',
      image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      category: 'Panadería',
      rating: 4.8,
      deliveryTime: '20-30 min',
      deliveryFee: 1.50,
      isLocal: true,
      address: 'Barrio Norte, Carrera 15 #45-67',
      phone: '+57 310 987 6543'
    },
    {
      id: '3',
      name: 'Frutas y Verduras Don Pedro',
      description: 'Productos frescos directos del campo a tu mesa',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      category: 'Frutas y Verduras',
      rating: 4.7,
      deliveryTime: '25-40 min',
      deliveryFee: 2.00,
      isLocal: true,
      address: 'Mercado Municipal, Local 12',
      phone: '+57 320 456 7890'
    },
    {
      id: '4',
      name: 'Empanadas La Abuela',
      description: 'Las mejores empanadas de la ciudad, receta familiar',
      image: 'https://images.unsplash.com/photo-1601314002957-0d5e5e7f41fa?w=400',
      category: 'Comida Rápida',
      rating: 4.9,
      deliveryTime: '15-25 min',
      deliveryFee: 1.00,
      isLocal: true,
      address: 'Barrio Sur, Avenida 8va #23-45',
      phone: '+57 315 234 5678'
    }
  ];

  // Mock products data - productos locales
  const products: Product[] = [
    // Doña María - Comida Casera
    {
      id: '1',
      name: 'Bandeja Paisa Completa',
      price: 15.00,
      description: 'Frijoles, arroz, carne molida, chicharrón, chorizo, huevo, arepa y patacón',
      image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
      category: 'Platos Principales',
      businessId: '1',
      businessName: 'Doña María - Comida Casera',
      available: true,
      isPopular: true
    },
    {
      id: '2',
      name: 'Sancocho de Pollo',
      price: 12.00,
      description: 'Sancocho tradicional con pollo, yuca, plátano y mazorca',
      image: 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400',
      category: 'Sopas',
      businessId: '1',
      businessName: 'Doña María - Comida Casera',
      available: true,
      isPopular: true
    },
    // Panadería El Amanecer
    {
      id: '3',
      name: 'Pan de Bono (6 unidades)',
      price: 3.50,
      description: 'Pan de bono recién horneado, suave y delicioso',
      image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      category: 'Panadería',
      businessId: '2',
      businessName: 'Panadería El Amanecer',
      available: true,
      isPopular: true
    },
    {
      id: '4',
      name: 'Arepa de Huevo',
      price: 2.00,
      description: 'Arepa frita rellena de huevo, especialidad de la casa',
      image: 'https://images.unsplash.com/photo-1619158401819-b8e86ff1b294?w=400',
      category: 'Desayunos',
      businessId: '2',
      businessName: 'Panadería El Amanecer',
      available: true,
      isPopular: false
    },
    // Frutas y Verduras Don Pedro
    {
      id: '5',
      name: 'Canasta de Frutas Tropicales',
      price: 8.00,
      description: 'Mango, piña, papaya, banano y maracuyá frescos',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      category: 'Frutas',
      businessId: '3',
      businessName: 'Frutas y Verduras Don Pedro',
      available: true,
      isPopular: true
    },
    {
      id: '6',
      name: 'Kit de Verduras para Sopa',
      price: 5.00,
      description: 'Zanahoria, apio, cebolla, cilantro y perejil',
      image: 'https://images.unsplash.com/photo-1590779033100-9f60a05a013d?w=400',
      category: 'Verduras',
      businessId: '3',
      businessName: 'Frutas y Verduras Don Pedro',
      available: true,
      isPopular: false
    },
    // Empanadas La Abuela
    {
      id: '7',
      name: 'Empanadas Mixtas (6 unidades)',
      price: 6.00,
      description: 'Empanadas de carne, pollo y queso con ají casero',
      image: 'https://images.unsplash.com/photo-1601314002957-0d5e5e7f41fa?w=400',
      category: 'Comida Rápida',
      businessId: '4',
      businessName: 'Empanadas La Abuela',
      available: true,
      isPopular: true
    }
  ];

  const addToCart = (product: Product) => {
    setCart(prev => {
      const existingItem = prev.find(item => item.id === product.id);
      if (existingItem) {
        return prev.map(item =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      }
      return [...prev, { ...product, quantity: 1 }];
    });
  };

  const removeFromCart = (productId: string) => {
    setCart(prev => prev.filter(item => item.id !== productId));
  };

  const updateCartQuantity = (productId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    setCart(prev =>
      prev.map(item =>
        item.id === productId ? { ...item, quantity } : item
      )
    );
  };

  const clearCart = () => {
    setCart([]);
  };

  const placeOrder = (customerInfo: Order['customerInfo']) => {
    if (cart.length === 0) return;

    const businessDeliveryFees = new Set(cart.map(item => {
      const business = businesses.find(b => b.id === item.businessId);
      return business?.deliveryFee || 0;
    }));
    
    const totalDeliveryFee = Array.from(businessDeliveryFees).reduce((sum, fee) => sum + fee, 0);

    const newOrder: Order = {
      id: Date.now().toString(),
      items: [...cart],
      total: cart.reduce((sum, item) => sum + item.price * item.quantity, 0),
      deliveryFee: totalDeliveryFee,
      status: 'pending',
      date: new Date().toISOString(),
      estimatedTime: '30-45 min',
      customerInfo
    };

    setOrders(prev => [newOrder, ...prev]);
    clearCart();
    setCurrentView('orders');
  };

  const getProductsByBusiness = (businessId: string) => {
    return products.filter(product => product.businessId === businessId);
  };

  return (
    <AppContext.Provider value={{
      user,
      setUser,
      businesses,
      products,
      cart,
      orders,
      currentView,
      selectedBusiness,
      setCurrentView,
      setSelectedBusiness,
      addToCart,
      removeFromCart,
      updateCartQuantity,
      clearCart,
      placeOrder,
      getProductsByBusiness
    }}>
      {children}
    </AppContext.Provider>
  );
};