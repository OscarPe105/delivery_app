from rest_framework import generics, filters, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from .models import Business, Category
from .serializers import BusinessSerializer, BusinessCreateSerializer, CategorySerializer


class CategoryListView(generics.ListAPIView):
    """
    Vista para listar categorías
    """
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]


class BusinessListView(generics.ListCreateAPIView):
    """
    Vista para listar y crear negocios
    """
    permission_classes = [AllowAny]  # Permitir acceso público para GET
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_active', 'is_open']
    search_fields = ['name', 'description', 'address']
    ordering_fields = ['name', 'rating', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        return Business.objects.filter(is_active=True)
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return BusinessCreateSerializer
        return BusinessSerializer


class BusinessDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Vista para obtener, actualizar y eliminar negocios específicos
    """
    permission_classes = [AllowAny]  # GET público, otros métodos requerirán autenticación
    
    def get_queryset(self):
        return Business.objects.filter(is_active=True)
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return BusinessCreateSerializer
        return BusinessSerializer


class UserBusinessListView(generics.ListAPIView):
    """
    Vista para listar negocios del usuario autenticado
    """
    serializer_class = BusinessSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Business.objects.filter(owner=self.request.user)


@api_view(['GET'])
@permission_classes([AllowAny])
def nearby_businesses(request):
    """
    Buscar negocios cercanos por coordenadas
    """
    latitude = request.GET.get('lat')
    longitude = request.GET.get('lng')
    radius = request.GET.get('radius', 10)  # Radio en km por defecto
    
    if not latitude or not longitude:
        return Response(
            {'error': 'Coordenadas lat y lng requeridas'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        lat = float(latitude)
        lng = float(longitude)
        radius = float(radius)
    except ValueError:
        return Response(
            {'error': 'Coordenadas inválidas'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Filtro básico por distancia (simplificado)
    # En producción, usar PostGIS para cálculos más precisos
    businesses = Business.objects.filter(
        is_active=True,
        latitude__isnull=False,
        longitude__isnull=False
    ).extra(
        where=[
            "6371 * acos(cos(radians(%s)) * cos(radians(latitude)) * cos(radians(longitude) - radians(%s)) + sin(radians(%s)) * sin(radians(latitude))) <= %s"
        ],
        params=[lat, lng, lat, radius]
    )
    
    serializer = BusinessSerializer(businesses, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_business_status(request, business_id):
    """
    Activar/desactivar negocio
    """
    try:
        business = Business.objects.get(id=business_id, owner=request.user)
        business.is_active = not business.is_active
        business.save()
        
        status_text = 'activado' if business.is_active else 'desactivado'
        return Response({
            'message': f'Negocio {status_text} exitosamente',
            'is_active': business.is_active
        })
    except Business.DoesNotExist:
        return Response(
            {'error': 'Negocio no encontrado'}, 
            status=status.HTTP_404_NOT_FOUND
        )
