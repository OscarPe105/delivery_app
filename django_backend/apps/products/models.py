from django.db import models
from django.core.validators import MinValueValidator
from apps.businesses.models import Business


class Product(models.Model):
    """
    Modelo de productos
    Compatible con el modelo Product de Flutter
    """
    business = models.ForeignKey(
        Business,
        on_delete=models.CASCADE,
        related_name='products',
        verbose_name='Negocio'
    )
    
    name = models.CharField(
        max_length=200,
        verbose_name='Nombre del Producto'
    )
    
    description = models.TextField(
        verbose_name='Descripción'
    )
    
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        verbose_name='Precio'
    )
    
    image_url = models.ImageField(
        upload_to='products/',
        verbose_name='Imagen del Producto'
    )
    
    available = models.BooleanField(
        default=True,
        verbose_name='Disponible'
    )
    
    is_popular = models.BooleanField(
        default=False,
        verbose_name='Popular'
    )
    
    stock_quantity = models.PositiveIntegerField(
        default=0,
        verbose_name='Cantidad en Stock'
    )
    
    # Campos adicionales para mejor gestión
    sku = models.CharField(
        max_length=50,
        unique=True,
        blank=True,
        null=True,
        verbose_name='SKU'
    )
    
    weight = models.DecimalField(
        max_digits=8,
        decimal_places=2,
        null=True,
        blank=True,
        verbose_name='Peso (kg)'
    )
    
    dimensions = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name='Dimensiones'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Producto'
        verbose_name_plural = 'Productos'
        ordering = ['-is_popular', '-created_at']
    
    def __str__(self):
        return f"{self.name} - {self.business.name}"
    
    def save(self, *args, **kwargs):
        # Generar SKU automáticamente si no se proporciona
        if not self.sku:
            import uuid
            self.sku = f"{self.business.id}-{uuid.uuid4().hex[:8]}"
        super().save(*args, **kwargs)
