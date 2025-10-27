from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.db.models import Q
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderCreateSerializer, OrderStatusUpdateSerializer


class OrderListView(generics.ListCreateAPIView):
    """
    Vista para listar y crear pedidos
    """
    permission_classes = [AllowAny]  # Temporalmente permitir crear pedidos sin autenticación
    
    def get_queryset(self):
        user = self.request.user
        
        # Si el usuario no está autenticado, retornar queryset vacío
        if not user.is_authenticated:
            return Order.objects.none()
        
        # Los clientes ven sus pedidos, los comerciantes ven pedidos de sus negocios
        if hasattr(user, 'user_type') and user.user_type == 'customer':
            return Order.objects.filter(customer=user)
        else:
            return Order.objects.filter(business__owner=user)
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return OrderCreateSerializer
        return OrderSerializer
    
    def create(self, request, *args, **kwargs):
        """
        Crear pedido y retornar con items
        """
        response = super().create(request, *args, **kwargs)
        
        # Si la creación fue exitosa, retornar con OrderSerializer completo
        if response.status_code == status.HTTP_201_CREATED:
            # El serializer devuelve el objeto order creado
            order = response.data
            # Obtener el pedido completo de la base de datos
            full_order = Order.objects.get(id=order['id'])
            serializer = OrderSerializer(full_order)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return response


class OrderDetailView(generics.RetrieveUpdateAPIView):
    """
    Vista para obtener y actualizar pedidos específicos
    """
    permission_classes = [AllowAny]  # Temporalmente para testing
    
    def get_queryset(self):
        # Temporalmente retornar todos los pedidos para testing
        return Order.objects.all()
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return OrderStatusUpdateSerializer
        return OrderSerializer


class CustomerOrderHistoryView(generics.ListAPIView):
    """
    Vista para historial de pedidos del cliente
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Order.objects.filter(
            customer=self.request.user
        ).order_by('-created_at')


class BusinessOrderListView(generics.ListAPIView):
    """
    Vista para pedidos de un negocio específico
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        business_id = self.kwargs['business_id']
        return Order.objects.filter(
            business_id=business_id,
            business__owner=self.request.user
        ).order_by('-created_at')


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_order_status(request, order_id):
    """
    Actualizar estado de un pedido
    """
    try:
        order = Order.objects.get(id=order_id)
        
        # Verificar permisos
        if request.user.user_type == 'customer':
            if order.customer != request.user:
                return Response(
                    {'error': 'No tienes permisos para modificar este pedido'}, 
                    status=status.HTTP_403_FORBIDDEN
                )
        else:
            if order.business.owner != request.user:
                return Response(
                    {'error': 'No tienes permisos para modificar este pedido'}, 
                    status=status.HTTP_403_FORBIDDEN
                )
        
        serializer = OrderStatusUpdateSerializer(order, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    except Order.DoesNotExist:
        return Response(
            {'error': 'Pedido no encontrado'}, 
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_statistics(request):
    """
    Estadísticas de pedidos para comerciantes
    """
    if request.user.user_type != 'business':
        return Response(
            {'error': 'Solo los comerciantes pueden ver estadísticas'}, 
            status=status.HTTP_403_FORBIDDEN
        )
    
    from django.db.models import Count, Sum
    from datetime import datetime, timedelta
    
    # Pedidos de los últimos 30 días
    thirty_days_ago = datetime.now() - timedelta(days=30)
    recent_orders = Order.objects.filter(
        business__owner=request.user,
        created_at__gte=thirty_days_ago
    )
    
    stats = {
        'total_orders': recent_orders.count(),
        'total_revenue': recent_orders.aggregate(
            total=Sum('total')
        )['total'] or 0,
        'orders_by_status': recent_orders.values('status').annotate(
            count=Count('id')
        ),
        'pending_orders': recent_orders.filter(status='pending').count(),
        'completed_orders': recent_orders.filter(status='delivered').count(),
    }
    
    return Response(stats)
