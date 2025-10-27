from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from apps.users.models import User


class Category(models.Model):
    """
    Modelo de categorías para productos y negocios
    Compatible con el modelo Category de Flutter
    """
    name = models.CharField(
        max_length=100,
        unique=True,
        verbose_name='Nombre'
    )
    
    icon = models.CharField(
        max_length=50,
        verbose_name='Icono'
    )
    
    description = models.TextField(
        blank=True,
        verbose_name='Descripción'
    )
    
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Categoría'
        verbose_name_plural = 'Categorías'
        ordering = ['name']
    
    def __str__(self):
        return self.name


class Business(models.Model):
    """
    Modelo de negocios/comercios
    Compatible con el modelo Business de Flutter
    """
    owner = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='owned_businesses',
        verbose_name='Propietario'
    )
    
    name = models.CharField(
        max_length=200,
        verbose_name='Nombre del Negocio'
    )
    
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name='businesses',
        verbose_name='Categoría'
    )
    
    description = models.TextField(
        blank=True,
        null=True,
        verbose_name='Descripción'
    )
    
    address = models.TextField(
        blank=True,
        null=True,
        verbose_name='Dirección'
    )
    
    phone = models.CharField(
        max_length=15,
        blank=True,
        null=True,
        verbose_name='Teléfono'
    )
    
    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=8,
        null=True,
        blank=True,
        verbose_name='Latitud'
    )
    
    longitude = models.DecimalField(
        max_digits=11,
        decimal_places=8,
        null=True,
        blank=True,
        verbose_name='Longitud'
    )
    
    rating = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        default=0.0,
        validators=[MinValueValidator(0.0), MaxValueValidator(5.0)],
        verbose_name='Calificación'
    )
    
    image_url = models.ImageField(
        upload_to='businesses/',
        null=True,
        blank=True,
        verbose_name='Imagen del Negocio'
    )
    
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )
    
    is_open = models.BooleanField(
        default=True,
        verbose_name='Abierto'
    )
    
    # Horarios de atención
    opening_time = models.TimeField(
        null=True,
        blank=True,
        verbose_name='Hora de Apertura'
    )
    
    closing_time = models.TimeField(
        null=True,
        blank=True,
        verbose_name='Hora de Cierre'
    )
    
    tags = models.JSONField(
        default=list,
        blank=True,
        verbose_name='Etiquetas'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Negocio'
        verbose_name_plural = 'Negocios'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.name
    
    @property
    def is_currently_open(self):
        """Verifica si el negocio está abierto en el momento actual"""
        if not self.is_open or not self.opening_time or not self.closing_time:
            return self.is_open
        
        from datetime import datetime, time
        now = datetime.now().time()
        
        if self.opening_time <= self.closing_time:
            return self.opening_time <= now <= self.closing_time
        else:  # Horario que cruza medianoche
            return now >= self.opening_time or now <= self.closing_time
