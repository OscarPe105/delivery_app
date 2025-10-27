from django.urls import path
from . import views

urlpatterns = [
    # Usuarios
    path('profile/', views.UserDetailView.as_view(), name='user_profile'),
    path('profile/detail/', views.user_profile, name='user_profile_detail'),
    path('register/', views.UserRegistrationView.as_view(), name='user_register'),
    path('list/', views.UserListView.as_view(), name='user_list'),
    path('change-password/', views.change_password, name='change_password'),
    
    # Direcciones
    path('addresses/', views.AddressListCreateView.as_view(), name='address_list'),
    path('addresses/<int:address_id>/', views.AddressDetailView.as_view(), name='address_detail'),
    path('addresses/<int:address_id>/set-default/', views.set_default_address, name='set_default_address'),
]
