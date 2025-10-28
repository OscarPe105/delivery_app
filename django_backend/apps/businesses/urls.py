from django.urls import path
from . import views

urlpatterns = [
    path('categories/', views.CategoryListView.as_view(), name='category_list'),
    path('', views.BusinessListView.as_view(), name='business_list'),
    path('my-business/', views.my_business, name='my_business'),
    path('my-businesses/', views.UserBusinessListView.as_view(), name='user_business_list'),
    path('nearby/', views.nearby_businesses, name='nearby_businesses'),
    path('<int:pk>/', views.BusinessDetailView.as_view(), name='business_detail'),
    path('<int:business_id>/toggle-status/', views.toggle_business_status, name='toggle_business_status'),
]
