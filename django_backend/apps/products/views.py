from rest_framework import generics, filters, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductSerializer, ProductCreateSerializer


class ProductListView(generics.ListCreateAPIView):
    """
    Vista para listar y crear productos
    """
    permission_classes = [AllowAny]  # GET público
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['business', 'available', 'is_popular']
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'price', 'created_at']
    ordering = ['-is_popular', '-created_at']
    
    def get_queryset(self):
        return Product.objects.filter(available=True)
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ProductCreateSerializer
        return ProductSerializer


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Vista para obtener, actualizar y eliminar productos específicos
    """
    permission_classes = [AllowAny]  # GET público
    
    def get_queryset(self):
        return Product.objects.all()
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return ProductCreateSerializer
        return ProductSerializer


class BusinessProductsView(generics.ListAPIView):
    """
    Vista para listar productos de un negocio específico
    """
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'price', 'created_at']
    ordering = ['-is_popular', '-created_at']
    
    def get_queryset(self):
        business_id = self.kwargs['business_id']
        return Product.objects.filter(
            business_id=business_id,
            available=True,
            business__is_active=True
        )


class PopularProductsView(generics.ListAPIView):
    """
    Vista para listar productos populares
    """
    queryset = Product.objects.filter(available=True, is_popular=True)
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_product_availability(request, product_id):
    """
    Activar/desactivar disponibilidad de producto
    """
    try:
        product = Product.objects.get(id=product_id)
        
        # Verificar que el usuario sea propietario del negocio
        if product.business.owner != request.user:
            return Response(
                {'error': 'No tienes permisos para modificar este producto'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        
        product.available = not product.available
        product.save()
        
        status_text = 'disponible' if product.available else 'no disponible'
        return Response({
            'message': f'Producto marcado como {status_text}',
            'available': product.available
        })
    except Product.DoesNotExist:
        return Response(
            {'error': 'Producto no encontrado'}, 
            status=status.HTTP_404_NOT_FOUND
        )
