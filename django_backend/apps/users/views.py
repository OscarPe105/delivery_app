from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import User, Address
from .serializers import UserDetailSerializer, AddressSerializer, UserSerializer, UserCreateSerializer


class UserDetailView(generics.RetrieveUpdateAPIView):
    """
    Vista para obtener y actualizar perfil de usuario
    """
    serializer_class = UserDetailSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return self.request.user


class AddressListCreateView(generics.ListCreateAPIView):
    """
    Vista para listar y crear direcciones de usuario
    """
    serializer_class = AddressSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class AddressDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Vista para obtener, actualizar y eliminar direcciones específicas
    """
    serializer_class = AddressSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)


class UserRegistrationView(generics.CreateAPIView):
    """
    Vista para registro de nuevos usuarios
    """
    serializer_class = UserCreateSerializer
    permission_classes = [AllowAny]


class UserListView(generics.ListAPIView):
    """
    Vista para listar usuarios (solo para administradores)
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return User.objects.all()
        return User.objects.none()


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def set_default_address(request, address_id):
    """
    Establecer una dirección como predeterminada
    """
    try:
        address = Address.objects.get(id=address_id, user=request.user)
        address.is_default = True
        address.save()
        return Response({'message': 'Dirección establecida como predeterminada'})
    except Address.DoesNotExist:
        return Response(
            {'error': 'Dirección no encontrada'}, 
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    Endpoint para cambiar contraseña
    """
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')
    
    if not old_password or not new_password:
        return Response(
            {'error': 'Se requieren old_password y new_password'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if not request.user.check_password(old_password):
        return Response(
            {'error': 'Contraseña actual incorrecta'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    request.user.set_password(new_password)
    request.user.save()
    
    return Response({'message': 'Contraseña actualizada correctamente'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    """
    Endpoint para obtener el perfil del usuario autenticado
    """
    serializer = UserDetailSerializer(request.user)
    return Response(serializer.data)
