"""
Autenticación Firebase para Django
"""
import firebase_admin
from firebase_admin import auth as firebase_auth
from django.contrib.auth import get_user_model
from django.contrib.auth.backends import BaseBackend
from django.conf import settings
from .config import firebase_config

User = get_user_model()


class FirebaseAuthenticationBackend(BaseBackend):
    """
    Backend de autenticación personalizado para Firebase
    """
    
    def authenticate(self, request, token=None, **kwargs):
        """
        Autenticar usuario usando token de Firebase
        """
        if not token:
            return None
        
        try:
            # Verificar token con Firebase
            decoded_token = firebase_auth.verify_id_token(token)
            firebase_uid = decoded_token['uid']
            
            # Buscar o crear usuario en Django
            try:
                user = User.objects.get(firebase_uid=firebase_uid)
            except User.DoesNotExist:
                # Crear nuevo usuario desde Firebase
                firebase_user = firebase_auth.get_user(firebase_uid)
                user = self._create_user_from_firebase(firebase_user)
            
            return user
            
        except firebase_auth.InvalidIdTokenError:
            return None
        except Exception as e:
            print(f"Error en autenticación Firebase: {e}")
            return None
    
    def _create_user_from_firebase(self, firebase_user):
        """
        Crear usuario Django desde datos de Firebase
        """
        user_data = {
            'firebase_uid': firebase_user.uid,
            'email': firebase_user.email,
            'username': firebase_user.email.split('@')[0],
            'first_name': firebase_user.display_name.split(' ')[0] if firebase_user.display_name else '',
            'last_name': ' '.join(firebase_user.display_name.split(' ')[1:]) if firebase_user.display_name else '',
            'is_active': not firebase_user.disabled,
            'is_verified': firebase_user.email_verified,
        }
        
        user = User.objects.create_user(**user_data)
        return user
    
    def get_user(self, user_id):
        """
        Obtener usuario por ID
        """
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None


def verify_firebase_token(token):
    """
    Verificar token de Firebase
    """
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return decoded_token
    except firebase_auth.InvalidIdTokenError:
        return None


def get_firebase_user(firebase_uid):
    """
    Obtener usuario de Firebase por UID
    """
    try:
        return firebase_auth.get_user(firebase_uid)
    except firebase_auth.UserNotFoundError:
        return None


def create_custom_token(uid, additional_claims=None):
    """
    Crear token personalizado para Firebase
    """
    try:
        return firebase_auth.create_custom_token(uid, additional_claims)
    except Exception as e:
        print(f"Error creando token personalizado: {e}")
        return None


def sync_user_to_firebase(django_user):
    """
    Sincronizar usuario Django con Firestore
    """
    try:
        user_data = {
            'uid': django_user.firebase_uid or django_user.id,
            'email': django_user.email,
            'name': django_user.full_name,
            'phone': django_user.phone,
            'userType': django_user.user_type,
            'profileImage': str(django_user.profile_image.url) if django_user.profile_image else None,
            'isVerified': django_user.is_verified,
            'createdAt': django_user.date_joined,
            'updatedAt': django_user.updated_at,
        }
        
        # Actualizar en Firestore
        firebase_config.db.collection('users').document(
            django_user.firebase_uid or str(django_user.id)
        ).set(user_data)
        
        return True
    except Exception as e:
        print(f"Error sincronizando usuario a Firebase: {e}")
        return False
