from django.urls import path
from . import views

urlpatterns = [
    path('', views.ProductListView.as_view(), name='product_list'),
    path('popular/', views.PopularProductsView.as_view(), name='popular_products'),
    path('business/<int:business_id>/', views.BusinessProductsView.as_view(), name='business_products'),
    path('<int:pk>/', views.ProductDetailView.as_view(), name='product_detail'),
    path('<int:product_id>/toggle-availability/', views.toggle_product_availability, name='toggle_product_availability'),
]
