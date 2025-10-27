from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from apps.users.models import User, Address
from apps.businesses.models import Business, Category
from apps.products.models import Product
from apps.orders.models import Order, OrderItem


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """
    Admin personalizado para el modelo User
    """
    list_display = ('username', 'email', 'full_name', 'user_type', 'is_active', 'date_joined')
    list_filter = ('user_type', 'is_active', 'is_staff', 'date_joined')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('-date_joined',)
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Información Adicional', {
            'fields': ('user_type', 'phone', 'profile_image', 'is_verified')
        }),
    )


@admin.register(Address)
class AddressAdmin(admin.ModelAdmin):
    """
    Admin para direcciones de usuarios
    """
    list_display = ('user', 'title', 'full_address', 'is_default', 'created_at')
    list_filter = ('is_default', 'created_at')
    search_fields = ('user__username', 'title', 'full_address')
    ordering = ('-created_at',)


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """
    Admin para categorías
    """
    list_display = ('name', 'icon', 'is_active', 'created_at')
    list_filter = ('is_active', 'created_at')
    search_fields = ('name', 'description')
    ordering = ('name',)


@admin.register(Business)
class BusinessAdmin(admin.ModelAdmin):
    """
    Admin para negocios
    """
    list_display = ('name', 'owner', 'category', 'is_active', 'is_open', 'rating', 'created_at')
    list_filter = ('category', 'is_active', 'is_open', 'created_at')
    search_fields = ('name', 'description', 'address', 'owner__username')
    ordering = ('-created_at',)
    
    fieldsets = (
        ('Información Básica', {
            'fields': ('owner', 'name', 'category', 'description')
        }),
        ('Contacto y Ubicación', {
            'fields': ('address', 'phone', 'latitude', 'longitude')
        }),
        ('Configuración', {
            'fields': ('image_url', 'opening_time', 'closing_time', 'tags')
        }),
        ('Estado', {
            'fields': ('is_active', 'is_open', 'rating')
        }),
    )


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    """
    Admin para productos
    """
    list_display = ('name', 'business', 'price', 'available', 'is_popular', 'stock_quantity', 'created_at')
    list_filter = ('business', 'available', 'is_popular', 'created_at')
    search_fields = ('name', 'description', 'business__name')
    ordering = ('-created_at',)


class OrderItemInline(admin.TabularInline):
    """
    Inline admin para items de pedido
    """
    model = OrderItem
    extra = 0
    readonly_fields = ('total',)


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    """
    Admin para pedidos
    """
    list_display = ('id', 'customer', 'business', 'status', 'total', 'created_at')
    list_filter = ('status', 'created_at', 'business')
    search_fields = ('customer__username', 'business__name', 'delivery_address__title')
    ordering = ('-created_at',)
    inlines = [OrderItemInline]
    
    fieldsets = (
        ('Información del Pedido', {
            'fields': ('customer', 'business', 'status')
        }),
        ('Dirección de Entrega', {
            'fields': ('delivery_address',)
        }),
        ('Totales', {
            'fields': ('subtotal', 'delivery_fee', 'tax', 'total')
        }),
        ('Información Adicional', {
            'fields': ('notes', 'estimated_delivery_time', 'delivered_at')
        }),
    )


@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    """
    Admin para items de pedido
    """
    list_display = ('order', 'product', 'quantity', 'price', 'total', 'created_at')
    list_filter = ('created_at', 'order__business')
    search_fields = ('order__id', 'product__name')
    ordering = ('-created_at',)
