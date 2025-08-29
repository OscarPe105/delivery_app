import { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Search, Heart, Star, Clock, MapPin, Phone, Filter } from 'lucide-react';
import { useApp } from './AppContext';

export const BusinessesView = () => {
  const { businesses, setSelectedBusiness, setCurrentView } = useApp();
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [sortBy, setSortBy] = useState('rating');

  const categories = ['all', ...Array.from(new Set(businesses.map(b => b.category)))];

  const filteredBusinesses = businesses
    .filter(business => {
      const matchesSearch = business.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           business.description.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesCategory = selectedCategory === 'all' || business.category === selectedCategory;
      return matchesSearch && matchesCategory;
    })
    .sort((a, b) => {
      switch (sortBy) {
        case 'rating':
          return b.rating - a.rating;
        case 'delivery-time':
          return parseInt(a.deliveryTime) - parseInt(b.deliveryTime);
        case 'delivery-fee':
          return a.deliveryFee - b.deliveryFee;
        case 'name':
          return a.name.localeCompare(b.name);
        default:
          return 0;
      }
    });

  const handleBusinessClick = (business: any) => {
    setSelectedBusiness(business);
    setCurrentView('business');
  };

  return (
    <div className="min-h-screen py-8">
      <div className="container mx-auto px-4">
        <div className="mb-8">
          <h1 className="text-3xl mb-2">Negocios de Tu Comunidad</h1>
          <p className="text-muted-foreground text-lg">
            Descubre los emprendedores locales que hacen especial tu barrio
          </p>
        </div>

        {/* Filters */}
        <div className="bg-white p-6 rounded-lg border mb-8 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <Filter className="h-5 w-5 text-orange-600" />
            <h2 className="text-lg">Encuentra tu negocio ideal</h2>
          </div>
          <div className="grid md:grid-cols-3 gap-4">
            {/* Search */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-muted-foreground" />
              <Input
                placeholder="Buscar negocios..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 py-3 text-base"
              />
            </div>

            {/* Category */}
            <Select value={selectedCategory} onValueChange={setSelectedCategory}>
              <SelectTrigger className="py-3 text-base">
                <SelectValue placeholder="Tipo de negocio" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Todos los tipos</SelectItem>
                {categories.filter(cat => cat !== 'all').map(category => (
                  <SelectItem key={category} value={category}>
                    {category}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Sort */}
            <Select value={sortBy} onValueChange={setSortBy}>
              <SelectTrigger className="py-3 text-base">
                <SelectValue placeholder="Ordenar por" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="rating">Mejor Calificación</SelectItem>
                <SelectItem value="delivery-time">Tiempo de Entrega</SelectItem>
                <SelectItem value="delivery-fee">Costo de Domicilio</SelectItem>
                <SelectItem value="name">Nombre</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Results */}
        <div className="mb-6">
          <p className="text-muted-foreground text-lg">
            {filteredBusinesses.length} negocios disponibles en tu zona
          </p>
        </div>

        {/* Businesses Grid */}
        <div className="grid lg:grid-cols-2 gap-6">
          {filteredBusinesses.map((business) => (
            <Card 
              key={business.id} 
              className="hover:shadow-xl transition-all duration-300 cursor-pointer border-2 hover:border-orange-200"
              onClick={() => handleBusinessClick(business)}
            >
              <div className="flex h-full">
                {/* Image */}
                <div className="w-1/3">
                  <div className="aspect-square overflow-hidden rounded-l-lg relative">
                    <ImageWithFallback
                      src={business.image}
                      alt={business.name}
                      className="w-full h-full object-cover hover:scale-105 transition-transform"
                    />
                    {business.isLocal && (
                      <Badge className="absolute top-2 left-2 bg-orange-500 text-xs">
                        <Heart className="h-3 w-3 mr-1" />
                        Local
                      </Badge>
                    )}
                  </div>
                </div>

                {/* Content */}
                <div className="flex-1 p-6">
                  <div className="flex justify-between items-start mb-3">
                    <CardTitle className="text-xl leading-tight pr-2">{business.name}</CardTitle>
                    <Badge variant="secondary" className="text-sm whitespace-nowrap">
                      {business.category}
                    </Badge>
                  </div>
                  
                  <CardDescription className="mb-4 text-base leading-relaxed">
                    {business.description}
                  </CardDescription>

                  {/* Business Info */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <Star className="h-4 w-4 fill-yellow-400 text-yellow-400 mr-1" />
                        <span className="font-medium text-base">{business.rating}</span>
                        <span className="text-sm text-muted-foreground ml-1">(50+ reseñas)</span>
                      </div>
                      <div className="flex items-center text-muted-foreground">
                        <Clock className="h-4 w-4 mr-1" />
                        <span className="text-sm">{business.deliveryTime}</span>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center text-sm text-muted-foreground">
                        <MapPin className="h-4 w-4 mr-1" />
                        <span>Domicilio: ${business.deliveryFee}</span>
                      </div>
                      <Button size="sm" className="px-4">
                        Ver Menú
                      </Button>
                    </div>

                    <div className="flex items-center text-sm text-muted-foreground">
                      <Phone className="h-4 w-4 mr-1" />
                      <span>{business.phone}</span>
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>

        {filteredBusinesses.length === 0 && (
          <div className="text-center py-12">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Search className="h-10 w-10 text-gray-400" />
            </div>
            <p className="text-xl text-muted-foreground mb-4">
              No encontramos negocios que coincidan con tu búsqueda
            </p>
            <p className="text-muted-foreground mb-6">
              Intenta con otros términos o revisa los filtros
            </p>
            <Button onClick={() => {
              setSearchTerm('');
              setSelectedCategory('all');
            }}>
              Limpiar filtros
            </Button>
          </div>
        )}

        {/* Call to action for business owners */}
        <div className="mt-16 bg-orange-50 rounded-lg p-8 text-center">
          <h3 className="text-2xl mb-4">¿Tienes un negocio local?</h3>
          <p className="text-muted-foreground mb-6 text-lg leading-relaxed">
            Únete a nuestra comunidad de emprendedores y lleva tus productos a más hogares de tu barrio
          </p>
          <Button size="lg" className="px-8 py-4 text-lg h-auto">
            Registrar Mi Negocio
          </Button>
        </div>
      </div>
    </div>
  );
};