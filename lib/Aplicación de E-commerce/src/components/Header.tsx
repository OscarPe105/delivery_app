import { ShoppingCart, User, Heart, MapPin, Menu, X } from 'lucide-react';
import { useState } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { useApp } from './AppContext';

export const Header = () => {
  const { user, cart, currentView, setCurrentView } = useApp();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const cartItemsCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  const navigationItems = [
    { id: 'home', label: 'Inicio', icon: null },
    { id: 'businesses', label: 'Negocios Locales', icon: null },
    ...(user ? [{ id: 'orders', label: 'Mis Pedidos', icon: null }] : [])
  ];

  return (
    <header className="border-b bg-white sticky top-0 z-50 shadow-sm">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-20">
          {/* Logo */}
          <div className="flex items-center space-x-3">
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-gradient-to-r from-orange-400 to-orange-600 rounded-full flex items-center justify-center">
                <Heart className="h-6 w-6 text-white" />
              </div>
              <div>
                <h1 
                  className="text-xl font-bold text-orange-600 cursor-pointer leading-tight"
                  onClick={() => setCurrentView('home')}
                >
                  Mi Barrio
                </h1>
                <p className="text-xs text-muted-foreground leading-tight">Delivery Comunitario</p>
              </div>
            </div>
          </div>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-2">
            {navigationItems.map((item) => (
              <Button
                key={item.id}
                variant={currentView === item.id ? 'default' : 'ghost'}
                onClick={() => setCurrentView(item.id)}
                className="px-6 py-3 h-auto text-base"
              >
                {item.label}
              </Button>
            ))}
          </nav>

          {/* Right side */}
          <div className="flex items-center space-x-3">
            {/* Location indicator */}
            <div className="hidden sm:flex items-center text-sm text-muted-foreground">
              <MapPin className="h-4 w-4 mr-1" />
              <span>Centro</span>
            </div>

            {/* Cart */}
            <Button
              variant="ghost"
              size="lg"
              className="relative px-4 py-3 h-auto"
              onClick={() => setCurrentView('cart')}
            >
              <ShoppingCart className="h-6 w-6" />
              {cartItemsCount > 0 && (
                <Badge 
                  variant="destructive" 
                  className="absolute -top-1 -right-1 h-6 w-6 flex items-center justify-center p-0 text-sm"
                >
                  {cartItemsCount}
                </Badge>
              )}
              <span className="ml-2 hidden sm:inline">Carrito</span>
            </Button>

            {/* User */}
            {user ? (
              <div className="flex items-center space-x-2">
                <div className="hidden sm:block text-right">
                  <p className="text-sm font-medium leading-tight">¡Hola!</p>
                  <p className="text-sm text-muted-foreground leading-tight">{user.name}</p>
                </div>
                <Button
                  variant="ghost"
                  size="lg"
                  onClick={() => setCurrentView('profile')}
                  className="px-3 py-3 h-auto"
                >
                  <User className="h-6 w-6" />
                </Button>
              </div>
            ) : (
              <Button 
                onClick={() => setCurrentView('auth')}
                className="px-6 py-3 h-auto text-base"
              >
                Iniciar Sesión
              </Button>
            )}

            {/* Mobile menu button */}
            <Button 
              variant="ghost" 
              size="lg" 
              className="md:hidden px-3 py-3 h-auto"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </Button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden border-t bg-white pb-4">
            <nav className="flex flex-col space-y-2 pt-4">
              {navigationItems.map((item) => (
                <Button
                  key={item.id}
                  variant={currentView === item.id ? 'default' : 'ghost'}
                  onClick={() => {
                    setCurrentView(item.id);
                    setIsMobileMenuOpen(false);
                  }}
                  className="justify-start px-4 py-4 h-auto text-base"
                >
                  {item.label}
                </Button>
              ))}
              <div className="flex items-center px-4 py-2 text-sm text-muted-foreground">
                <MapPin className="h-4 w-4 mr-2" />
                <span>Entregamos en: Barrio Centro</span>
              </div>
            </nav>
          </div>
        )}
      </div>
    </header>
  );
};