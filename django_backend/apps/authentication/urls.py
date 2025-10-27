from django.urls import path
from . import views
# from . import firebase_auth  # Temporalmente comentado por error de credenciales Firebase

urlpatterns = [
    # Autenticación tradicional
    path('register/', views.register, name='register'),
    path('login/', views.login_view, name='login'),
    path('refresh/', views.refresh_token, name='refresh_token'),
    
    # Autenticación Firebase (temporalmente deshabilitado)
    # path('firebase/login/', firebase_auth.firebase_login, name='firebase_login'),
    # path('firebase/register/', firebase_auth.firebase_register, name='firebase_register'),
    # path('firebase/refresh/', firebase_auth.firebase_refresh_token, name='firebase_refresh_token'),
    
    # Perfil
    path('profile/', views.user_profile, name='user_profile'),
    path('profile/update/', views.update_profile, name='update_profile'),
]
