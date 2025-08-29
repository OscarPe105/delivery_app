import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Heart, Star, Clock, Truck, MapPin, Users } from 'lucide-react';
import { useApp } from './AppContext';

export const HomeView = () => {
  const { businesses, products, setCurrentView, setSelectedBusiness, user } = useApp();
  const popularProducts = products.filter(p => p.isPopular).slice(0, 4);
  const featuredBusinesses = businesses.slice(0, 3);

  const handleBusinessClick = (business: any) => {
    setSelectedBusiness(business);
    setCurrentView('business');
  };

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-orange-500 to-red-500 text-white py-16">
        <div className="container mx-auto px-4 text-center">
          <div className="flex justify-center mb-6">
            <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center">
              <Heart className="h-12 w-12 text-white" />
            </div>
          </div>
          <h1 className="text-3xl md:text-5xl mb-4 leading-tight">
            Apoya a Tu Comunidad
          </h1>
          <p className="text-lg md:text-xl mb-8 opacity-90 max-w-2xl mx-auto leading-relaxed">
            Conectamos a los microempresarios de tu barrio contigo. 
            Comida casera, productos frescos y el sabor de lo local.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button 
              size="lg" 
              variant="secondary"
              onClick={() => setCurrentView('businesses')}
              className="px-8 py-4 text-lg h-auto"
            >
              <MapPin className="h-5 w-5 mr-2" />
              Explorar Negocios
            </Button>
            {!user && (
              <Button 
                size="lg" 
                variant="outline"
                className="text-white border-white hover:bg-white hover:text-orange-600 px-8 py-4 text-lg h-auto"
                onClick={() => setCurrentView('auth')}
              >
                Únete a la Comunidad
              </Button>
            )}
          </div>
        </div>
      </section>

      {/* Community Stats */}
      <section className="py-12 bg-orange-50">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-3 gap-8 text-center">
            <div>
              <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Users className="h-8 w-8 text-orange-600" />
              </div>
              <h3 className="text-2xl font-bold text-orange-600 mb-2">50+</h3>
              <p className="text-muted-foreground">Microempresarios Locales</p>
            </div>
            <div>
              <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Heart className="h-8 w-8 text-orange-600" />
              </div>
              <h3 className="text-2xl font-bold text-orange-600 mb-2">1000+</h3>
              <p className="text-muted-foreground">Pedidos Comunitarios</p>
            </div>
            <div>
              <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Truck className="h-8 w-8 text-orange-600" />
              </div>
              <h3 className="text-2xl font-bold text-orange-600 mb-2">30 min</h3>
              <p className="text-muted-foreground">Tiempo Promedio</p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Businesses */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl mb-4">Negocios Destacados de Tu Barrio</h2>
            <p className="text-muted-foreground text-lg">
              Conoce a los emprendedores que hacen especial nuestra comunidad
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {featuredBusinesses.map((business) => (
              <Card 
                key={business.id} 
                className="hover:shadow-xl transition-all duration-300 cursor-pointer border-2 hover:border-orange-200"
                onClick={() => handleBusinessClick(business)}
              >
                <CardHeader className="p-0">
                  <div className="aspect-video overflow-hidden rounded-t-lg relative">
                    <ImageWithFallback
                      src={business.image}
                      alt={business.name}
                      className="w-full h-full object-cover hover:scale-105 transition-transform"
                    />
                    {business.isLocal && (
                      <Badge className="absolute top-3 left-3 bg-orange-500">
                        <Heart className="h-3 w-3 mr-1" />
                        Local
                      </Badge>
                    )}
                  </div>
                </CardHeader>
                <CardContent className="p-6">
                  <div className="flex justify-between items-start mb-3">
                    <CardTitle className="text-xl leading-tight">{business.name}</CardTitle>
                    <Badge variant="secondary" className="text-sm">
                      {business.category}
                    </Badge>
                  </div>
                  <CardDescription className="mb-4 text-base leading-relaxed">
                    {business.description}
                  </CardDescription>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <Star className="h-4 w-4 fill-yellow-400 text-yellow-400 mr-1" />
                        <span className="font-medium">{business.rating}</span>
                      </div>
                      <div className="flex items-center text-sm text-muted-foreground">
                        <Clock className="h-4 w-4 mr-1" />
                        {business.deliveryTime}
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-muted-foreground">
                        Domicilio: ${business.deliveryFee}
                      </span>
                      <Button size="sm" className="px-4">
                        Ver Menú
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="text-center mt-12">
            <Button 
              size="lg"
              onClick={() => setCurrentView('businesses')}
              className="px-8 py-4 text-lg h-auto"
            >
              Ver Todos los Negocios
            </Button>
          </div>
        </div>
      </section>

      {/* Popular Products */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl mb-4">Lo Más Pedido de la Semana</h2>
            <p className="text-muted-foreground text-lg">
              Los favoritos de tu comunidad
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {popularProducts.map((product) => (
              <Card key={product.id} className="hover:shadow-lg transition-shadow">
                <CardHeader className="p-0">
                  <div className="aspect-square overflow-hidden rounded-t-lg">
                    <ImageWithFallback
                      src={product.image}
                      alt={product.name}
                      className="w-full h-full object-cover hover:scale-105 transition-transform"
                    />
                  </div>
                </CardHeader>
                <CardContent className="p-4">
                  <CardTitle className="text-lg mb-2 leading-tight">{product.name}</CardTitle>
                  <p className="text-sm text-muted-foreground mb-3 leading-relaxed">
                    {product.businessName}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="text-xl font-bold text-orange-600">${product.price}</span>
                    <Badge variant="outline" className="text-xs">
                      Popular
                    </Badge>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Community Values */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl mb-4">¿Por Qué Elegir Mi Barrio?</h2>
            <p className="text-muted-foreground text-lg">
              Más que delivery, somos una comunidad
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <Heart className="h-10 w-10 text-orange-600" />
              </div>
              <h3 className="text-xl mb-4">Apoyo Local</h3>
              <p className="text-muted-foreground leading-relaxed">
                Cada pedido ayuda a fortalecer la economía de tu barrio y apoya a familias emprendedoras
              </p>
            </div>
            <div className="text-center">
              <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <Users className="h-10 w-10 text-orange-600" />
              </div>
              <h3 className="text-xl mb-4">Comunidad Cercana</h3>
              <p className="text-muted-foreground leading-relaxed">
                Conoces a quién le compras, productos hechos con amor y tradición familiar
              </p>
            </div>
            <div className="text-center">
              <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <Truck className="h-10 w-10 text-orange-600" />
              </div>
              <h3 className="text-xl mb-4">Delivery Rápido</h3>
              <p className="text-muted-foreground leading-relaxed">
                Al ser local, tus pedidos llegan más rápido y más frescos que nunca
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};