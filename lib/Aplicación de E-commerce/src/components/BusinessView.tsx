import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { ArrowLeft, Star, Clock, MapPin, Phone, ShoppingCart, Heart } from 'lucide-react';
import { useApp } from './AppContext';

export const BusinessView = () => {
  const { selectedBusiness, getProductsByBusiness, addToCart, user, setCurrentView } = useApp();

  if (!selectedBusiness) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-lg mb-4">Negocio no encontrado</p>
          <Button onClick={() => setCurrentView('businesses')}>
            Volver a Negocios
          </Button>
        </div>
      </div>
    );
  }

  const products = getProductsByBusiness(selectedBusiness.id);

  const handleAddToCart = (product: any) => {
    if (!user) {
      setCurrentView('auth');
      return;
    }
    addToCart(product);
  };

  return (
    <div className="min-h-screen">
      {/* Business Header */}
      <div className="relative">
        <div className="h-64 md:h-80 overflow-hidden">
          <ImageWithFallback
            src={selectedBusiness.image}
            alt={selectedBusiness.name}
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-black/40"></div>
        </div>
        
        <Button 
          variant="secondary"
          size="sm"
          className="absolute top-4 left-4 z-10"
          onClick={() => setCurrentView('businesses')}
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          Volver
        </Button>

        {selectedBusiness.isLocal && (
          <Badge className="absolute top-4 right-4 bg-orange-500 text-sm">
            <Heart className="h-3 w-3 mr-1" />
            Negocio Local
          </Badge>
        )}
      </div>

      {/* Business Info */}
      <div className="container mx-auto px-4 -mt-16 relative z-10">
        <Card className="mb-8 shadow-lg">
          <CardContent className="p-8">
            <div className="flex flex-col md:flex-row md:items-start md:justify-between mb-6">
              <div className="mb-4 md:mb-0">
                <div className="flex items-center gap-2 mb-2">
                  <CardTitle className="text-3xl">{selectedBusiness.name}</CardTitle>
                  <Badge variant="secondary" className="text-sm">
                    {selectedBusiness.category}
                  </Badge>
                </div>
                <CardDescription className="text-lg leading-relaxed mb-4">
                  {selectedBusiness.description}
                </CardDescription>
                
                <div className="flex flex-wrap gap-4 text-sm">
                  <div className="flex items-center">
                    <Star className="h-4 w-4 fill-yellow-400 text-yellow-400 mr-1" />
                    <span className="font-medium">{selectedBusiness.rating}</span>
                    <span className="text-muted-foreground ml-1">(50+ reseñas)</span>
                  </div>
                  <div className="flex items-center text-muted-foreground">
                    <Clock className="h-4 w-4 mr-1" />
                    <span>{selectedBusiness.deliveryTime}</span>
                  </div>
                  <div className="flex items-center text-muted-foreground">
                    <MapPin className="h-4 w-4 mr-1" />
                    <span>Domicilio: ${selectedBusiness.deliveryFee}</span>
                  </div>
                </div>
              </div>
              
              <div className="text-right">
                <Button size="lg" className="mb-3 px-6 py-3 h-auto">
                  <Heart className="h-4 w-4 mr-2" />
                  Marcar Favorito
                </Button>
                <div className="text-sm text-muted-foreground">
                  <div className="flex items-center">
                    <Phone className="h-4 w-4 mr-1" />
                    <span>{selectedBusiness.phone}</span>
                  </div>
                  <div className="flex items-center mt-1">
                    <MapPin className="h-4 w-4 mr-1" />
                    <span>{selectedBusiness.address}</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Products Menu */}
        <div className="mb-8">
          <h2 className="text-2xl mb-6">Nuestro Menú</h2>
          
          {products.length === 0 ? (
            <Card className="text-center py-12">
              <CardContent>
                <p className="text-lg text-muted-foreground mb-4">
                  Este negocio aún no ha agregado productos a su menú
                </p>
                <p className="text-muted-foreground">
                  Pronto tendrán deliciosas opciones disponibles
                </p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {products.map((product) => (
                <Card key={product.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader className="p-0">
                    <div className="aspect-video overflow-hidden rounded-t-lg">
                      <ImageWithFallback
                        src={product.image}
                        alt={product.name}
                        className="w-full h-full object-cover hover:scale-105 transition-transform"
                      />
                    </div>
                  </CardHeader>
                  <CardContent className="p-6">
                    <div className="flex justify-between items-start mb-3">
                      <CardTitle className="text-lg leading-tight">{product.name}</CardTitle>
                      {product.isPopular && (
                        <Badge variant="outline" className="text-xs">
                          Popular
                        </Badge>
                      )}
                    </div>
                    <CardDescription className="mb-4 text-base leading-relaxed">
                      {product.description}
                    </CardDescription>
                    <div className="flex items-center justify-between">
                      <span className="text-2xl font-bold text-orange-600">
                        ${product.price}
                      </span>
                      <Button
                        onClick={() => handleAddToCart(product)}
                        disabled={!product.available}
                        size="sm"
                        className="px-4"
                      >
                        <ShoppingCart className="h-4 w-4 mr-2" />
                        {product.available ? 'Agregar' : 'No disponible'}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Business Story Section */}
        <Card className="bg-orange-50 border-orange-200">
          <CardContent className="p-8">
            <h3 className="text-xl mb-4">Conoce Nuestra Historia</h3>
            <p className="text-muted-foreground leading-relaxed mb-6">
              {selectedBusiness.name} es más que un negocio, es parte de la historia de nuestro barrio. 
              Con años de dedicación, hemos construido relaciones con nuestra comunidad basadas 
              en la confianza, la calidad y el amor por lo que hacemos.
            </p>
            <div className="grid md:grid-cols-2 gap-6 text-sm">
              <div>
                <h4 className="font-medium mb-2">Horarios de Atención:</h4>
                <p className="text-muted-foreground">
                  Lunes a Domingo<br />
                  7:00 AM - 8:00 PM
                </p>
              </div>
              <div>
                <h4 className="font-medium mb-2">Métodos de Pago:</h4>
                <p className="text-muted-foreground">
                  Efectivo, Transferencia<br />
                  Tarjetas de crédito y débito
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};