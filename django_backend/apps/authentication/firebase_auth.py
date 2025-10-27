"""
Vistas de autenticación con Firebase
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from firebase_admin import auth as firebase_auth
from .serializers import UserSerializer
import sys
import os
# Agregar el directorio raíz al path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from firebase.auth import verify_firebase_token, sync_user_to_firebase

User = get_user_model()


@api_view(['POST'])
@permission_classes([AllowAny])
def firebase_login(request):
    """
    Login con token de Firebase
    """
    firebase_token = request.data.get('firebase_token')
    
    if not firebase_token:
        return Response(
            {'error': 'Token de Firebase requerido'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        # Verificar token con Firebase
        decoded_token = verify_firebase_token(firebase_token)
        if not decoded_token:
            return Response(
                {'error': 'Token de Firebase inválido'}, 
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        firebase_uid = decoded_token['uid']
        
        # Buscar o crear usuario en Django
        try:
            user = User.objects.get(firebase_uid=firebase_uid)
        except User.DoesNotExist:
            # Crear nuevo usuario desde Firebase
            firebase_user = firebase_auth.get_user(firebase_uid)
            user = create_user_from_firebase(firebase_user)
        
        # Generar tokens JWT
        refresh = RefreshToken.for_user(user)
        
        # Sincronizar con Firestore
        sync_user_to_firebase(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Error en autenticación: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def firebase_register(request):
    """
    Registro con datos de Firebase
    """
    firebase_token = request.data.get('firebase_token')
    user_data = request.data.get('user_data', {})
    
    if not firebase_token:
        return Response(
            {'error': 'Token de Firebase requerido'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        # Verificar token con Firebase
        decoded_token = verify_firebase_token(firebase_token)
        if not decoded_token:
            return Response(
                {'error': 'Token de Firebase inválido'}, 
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        firebase_uid = decoded_token['uid']
        
        # Verificar si el usuario ya existe
        if User.objects.filter(firebase_uid=firebase_uid).exists():
            return Response(
                {'error': 'Usuario ya existe'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Crear usuario desde Firebase
        firebase_user = firebase_auth.get_user(firebase_uid)
        user = create_user_from_firebase(firebase_user, user_data)
        
        # Generar tokens JWT
        refresh = RefreshToken.for_user(user)
        
        # Sincronizar con Firestore
        sync_user_to_firebase(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response(
            {'error': f'Error en registro: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def firebase_refresh_token(request):
    """
    Renovar token de Firebase y JWT
    """
    firebase_token = request.data.get('firebase_token')
    
    if not firebase_token:
        return Response(
            {'error': 'Token de Firebase requerido'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        # Verificar token con Firebase
        decoded_token = verify_firebase_token(firebase_token)
        if not decoded_token:
            return Response(
                {'error': 'Token de Firebase inválido'}, 
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        firebase_uid = decoded_token['uid']
        
        try:
            user = User.objects.get(firebase_uid=firebase_uid)
            
            # Generar nuevos tokens JWT
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'tokens': {
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                }
            }, status=status.HTTP_200_OK)
            
        except User.DoesNotExist:
            return Response(
                {'error': 'Usuario no encontrado'}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
    except Exception as e:
        return Response(
            {'error': f'Error renovando token: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def create_user_from_firebase(firebase_user, additional_data=None):
    """
    Crear usuario Django desde datos de Firebase
    """
    additional_data = additional_data or {}
    
    user_data = {
        'firebase_uid': firebase_user.uid,
        'email': firebase_user.email,
        'username': firebase_user.email.split('@')[0],
        'first_name': firebase_user.display_name.split(' ')[0] if firebase_user.display_name else '',
        'last_name': ' '.join(firebase_user.display_name.split(' ')[1:]) if firebase_user.display_name else '',
        'is_active': not firebase_user.disabled,
        'is_verified': firebase_user.email_verified,
        'phone': additional_data.get('phone', ''),
        'user_type': additional_data.get('user_type', 'customer'),
    }
    
    # Remover campos vacíos
    user_data = {k: v for k, v in user_data.items() if v}
    
    user = User.objects.create_user(**user_data)
    return user
