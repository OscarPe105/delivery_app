from django.db import models
from django.core.validators import MinValueValidator
from apps.users.models import User, Address
from apps.products.models import Product


class Order(models.Model):
    """
    Modelo de pedidos
    Compatible con el modelo Order de Flutter
    """
    STATUS_CHOICES = [
        ('pending', 'Pendiente'),
        ('confirmed', 'Confirmado'),
        ('preparing', 'Preparando'),
        ('ready', 'Listo para Entrega'),
        ('in_progress', 'En Camino'),
        ('delivered', 'Entregado'),
        ('cancelled', 'Cancelado'),
    ]
    
    customer = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='orders',
        verbose_name='Cliente'
    )
    
    business = models.ForeignKey(
        'businesses.Business',
        on_delete=models.CASCADE,
        related_name='orders',
        verbose_name='Negocio'
    )
    
    delivery_address = models.ForeignKey(
        Address,
        on_delete=models.CASCADE,
        related_name='orders',
        verbose_name='Dirección de Entrega'
    )
    
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        verbose_name='Estado'
    )
    
    total = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        verbose_name='Total'
    )
    
    subtotal = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name='Subtotal'
    )
    
    delivery_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name='Costo de Entrega'
    )
    
    tax = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name='Impuestos'
    )
    
    notes = models.TextField(
        blank=True,
        null=True,
        verbose_name='Notas del Pedido'
    )
    
    estimated_delivery_time = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name='Tiempo Estimado de Entrega'
    )
    
    delivered_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name='Entregado en'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Pedido'
        verbose_name_plural = 'Pedidos'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Pedido #{self.id} - {self.customer.username}"


class OrderItem(models.Model):
    """
    Modelo de items individuales en un pedido
    Compatible con el modelo OrderItem de Flutter
    """
    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name='items',
        verbose_name='Pedido'
    )
    
    product = models.ForeignKey(
        Product,
        on_delete=models.CASCADE,
        verbose_name='Producto'
    )
    
    quantity = models.PositiveIntegerField(
        validators=[MinValueValidator(1)],
        verbose_name='Cantidad'
    )
    
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        verbose_name='Precio Unitario'
    )
    
    # Precio total del item (quantity * price)
    total = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        verbose_name='Total del Item'
    )
    
    notes = models.TextField(
        blank=True,
        null=True,
        verbose_name='Notas del Item'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Item del Pedido'
        verbose_name_plural = 'Items del Pedido'
        ordering = ['created_at']
    
    def __str__(self):
        return f"{self.product.name} x{self.quantity} - Pedido #{self.order.id}"
    
    def save(self, *args, **kwargs):
        # Calcular el total automáticamente
        self.total = self.quantity * self.price
        super().save(*args, **kwargs)
