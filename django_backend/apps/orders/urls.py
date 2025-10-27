from django.urls import path
from . import views

urlpatterns = [
    path('', views.OrderListView.as_view(), name='order_list'),
    path('history/', views.CustomerOrderHistoryView.as_view(), name='order_history'),
    path('business/<int:business_id>/', views.BusinessOrderListView.as_view(), name='business_orders'),
    path('statistics/', views.order_statistics, name='order_statistics'),
    path('<int:pk>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('<int:order_id>/update-status/', views.update_order_status, name='update_order_status'),
]
