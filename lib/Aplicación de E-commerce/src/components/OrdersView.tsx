import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Separator } from './ui/separator';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Package, Truck, CheckCircle, Clock, Phone, MapPin, Heart } from 'lucide-react';
import { useApp } from './AppContext';

const statusConfig = {
  pending: {
    label: 'Recibido',
    icon: Clock,
    color: 'bg-blue-100 text-blue-800',
    description: 'Tu pedido fue recibido'
  },
  confirmed: {
    label: 'Confirmado',
    icon: CheckCircle,
    color: 'bg-green-100 text-green-800',
    description: 'El negocio confirmó tu pedido'
  },
  preparing: {
    label: 'Preparando',
    icon: Package,
    color: 'bg-orange-100 text-orange-800',
    description: 'Preparando tu pedido con amor'
  },
  on_way: {
    label: 'En Camino',
    icon: Truck,
    color: 'bg-purple-100 text-purple-800',
    description: 'Tu pedido viene en camino'
  },
  delivered: {
    label: 'Entregado',
    icon: CheckCircle,
    color: 'bg-green-100 text-green-800',
    description: '¡Disfruta tu pedido!'
  }
};

export const OrdersView = () => {
  const { orders, user, setCurrentView } = useApp();

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Heart className="h-10 w-10 text-orange-600" />
          </div>
          <h2 className="text-2xl mb-4">¡Únete a Nuestra Comunidad!</h2>
          <p className="text-muted-foreground mb-6 text-lg leading-relaxed max-w-md mx-auto">
            Crea tu cuenta para realizar pedidos y apoyar a los microempresarios de tu barrio
          </p>
          <Button 
            onClick={() => setCurrentView('auth')}
            size="lg"
            className="px-8 py-4 text-lg h-auto"
          >
            Iniciar Sesión
          </Button>
        </div>
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Package className="h-10 w-10 text-orange-600" />
          </div>
          <h2 className="text-2xl mb-4">Aún no tienes pedidos</h2>
          <p className="text-muted-foreground mb-6 text-lg leading-relaxed max-w-md mx-auto">
            Explora los negocios locales y haz tu primer pedido para apoyar a tu comunidad
          </p>
          <Button 
            onClick={() => setCurrentView('businesses')}
            size="lg"
            className="px-8 py-4 text-lg h-auto"
          >
            <Heart className="h-5 w-5 mr-2" />
            Explorar Negocios
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen py-8">
      <div className="container mx-auto px-4">
        <div className="mb-8">
          <h1 className="text-3xl mb-2">Mis Pedidos</h1>
          <p className="text-muted-foreground text-lg">
            Sigue el estado de tus pedidos comunitarios
          </p>
        </div>

        <div className="space-y-6">
          {orders.map((order) => {
            const StatusIcon = statusConfig[order.status].icon;
            
            return (
              <Card key={order.id} className="shadow-lg">
                <CardHeader>
                  <div className="flex justify-between items-start">
                    <div>
                      <CardTitle className="flex items-center gap-3 text-xl">
                        <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                          <Heart className="h-4 w-4 text-orange-600" />
                        </div>
                        Pedido #{order.id}
                        <Badge className={statusConfig[order.status].color}>
                          <StatusIcon className="h-3 w-3 mr-1" />
                          {statusConfig[order.status].label}
                        </Badge>
                      </CardTitle>
                      <CardDescription className="text-base mt-2">
                        Realizado el {new Date(order.date).toLocaleDateString('es-ES', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </CardDescription>
                    </div>
                    <div className="text-right">
                      <p className="text-2xl font-bold text-orange-600">${order.total + order.deliveryFee}</p>
                      <p className="text-sm text-muted-foreground">
                        {statusConfig[order.status].description}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        Tiempo estimado: {order.estimatedTime}
                      </p>
                    </div>
                  </div>
                </CardHeader>

                <CardContent>
                  {/* Customer Info */}
                  <div className="mb-6 p-4 bg-orange-50 rounded-lg">
                    <h3 className="font-medium mb-3 flex items-center">
                      <MapPin className="h-4 w-4 mr-2" />
                      Información de entrega
                    </h3>
                    <div className="text-sm space-y-1 text-muted-foreground">
                      <p className="font-medium text-foreground">{order.customerInfo.name}</p>
                      <div className="flex items-center">
                        <Phone className="h-3 w-3 mr-2" />
                        <span>{order.customerInfo.phone}</span>
                      </div>
                      <div className="flex items-center">
                        <MapPin className="h-3 w-3 mr-2" />
                        <span>{order.customerInfo.address}</span>
                      </div>
                      {order.customerInfo.notes && (
                        <p className="text-xs mt-2 p-2 bg-white rounded border">
                          <strong>Notas:</strong> {order.customerInfo.notes}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Order Items */}
                  <div className="space-y-4">
                    <h3 className="font-medium text-lg">
                      Productos ({order.items.length})
                    </h3>
                    {order.items.map((item, index) => (
                      <div key={`${item.id}-${index}`} className="flex items-center space-x-4 p-3 bg-gray-50 rounded-lg">
                        <div className="w-16 h-16 overflow-hidden rounded-lg">
                          <ImageWithFallback
                            src={item.image}
                            alt={item.name}
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="flex-1">
                          <p className="font-medium text-base">{item.name}</p>
                          <p className="text-sm text-muted-foreground">
                            {item.businessName}
                          </p>
                          <p className="text-sm text-muted-foreground">
                            Cantidad: {item.quantity}
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="font-medium text-lg">${item.price * item.quantity}</p>
                          <p className="text-sm text-muted-foreground">
                            ${item.price} c/u
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>

                  <Separator className="my-6" />

                  {/* Order Summary */}
                  <div className="space-y-2 max-w-md ml-auto">
                    <div className="flex justify-between">
                      <span>Subtotal</span>
                      <span>${order.total}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Domicilio</span>
                      <span>${order.deliveryFee}</span>
                    </div>
                    <Separator />
                    <div className="flex justify-between font-medium text-lg">
                      <span>Total</span>
                      <span className="text-orange-600">${order.total + order.deliveryFee}</span>
                    </div>
                  </div>

                  <Separator className="my-6" />

                  {/* Order Progress */}
                  <div className="space-y-4">
                    <h3 className="font-medium">Seguimiento del pedido</h3>
                    <div className="flex items-center justify-between">
                      {Object.entries(statusConfig).map(([status, config], index) => {
                        const Icon = config.icon;
                        const isCompleted = Object.keys(statusConfig).indexOf(order.status) >= index;
                        const isCurrent = order.status === status;
                        
                        return (
                          <div key={status} className="flex flex-col items-center flex-1">
                            <div className={`
                              w-12 h-12 rounded-full flex items-center justify-center transition-colors
                              ${isCompleted 
                                ? isCurrent 
                                  ? 'bg-orange-500 text-white' 
                                  : 'bg-green-500 text-white'
                                : 'bg-gray-200 text-gray-400'
                              }
                            `}>
                              <Icon className="h-6 w-6" />
                            </div>
                            <span className={`
                              text-xs mt-2 text-center leading-tight
                              ${isCompleted ? 'text-foreground font-medium' : 'text-muted-foreground'}
                            `}>
                              {config.label}
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex gap-3 mt-6 pt-4 border-t">
                    <Button variant="outline" size="sm">
                      <Phone className="h-4 w-4 mr-2" />
                      Contactar Negocio
                    </Button>
                    {order.status === 'delivered' && (
                      <Button size="sm">
                        <Heart className="h-4 w-4 mr-2" />
                        Calificar Pedido
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* Community message */}
        <div className="mt-12 bg-orange-50 rounded-lg p-8 text-center">
          <h3 className="text-xl mb-3">¡Gracias por Apoyar tu Comunidad!</h3>
          <p className="text-muted-foreground text-base leading-relaxed mb-4">
            Cada pedido que realizas ayuda a fortalecer la economía local y apoya a las familias emprendedoras de tu barrio.
          </p>
          <Button 
            onClick={() => setCurrentView('businesses')}
            className="px-6 py-3 h-auto"
          >
            <Heart className="h-4 w-4 mr-2" />
            Realizar Otro Pedido
          </Button>
        </div>
      </div>
    </div>
  );
};