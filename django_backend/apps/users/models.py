from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.validators import RegexValidator


class User(AbstractUser):
    """
    Modelo de usuario personalizado que extiende AbstractUser
    Compatible con el modelo User de Flutter
    """
    USER_TYPE_CHOICES = [
        ('customer', 'Cliente'),
        ('business', 'Comerciante'),
        ('admin', 'Administrador'),
    ]
    
    firebase_uid = models.CharField(
        max_length=128,
        unique=True,
        null=True,
        blank=True,
        verbose_name='Firebase UID'
    )
    
    user_type = models.CharField(
        max_length=10,
        choices=USER_TYPE_CHOICES,
        default='customer',
        verbose_name='Tipo de Usuario'
    )
    
    phone = models.CharField(
        max_length=15,
        validators=[RegexValidator(
            regex=r'^\+?1?\d{9,15}$',
            message='El número de teléfono debe tener entre 9 y 15 dígitos'
        )],
        verbose_name='Teléfono'
    )
    
    profile_image = models.ImageField(
        upload_to='profiles/',
        null=True,
        blank=True,
        verbose_name='Imagen de Perfil'
    )
    
    is_verified = models.BooleanField(
        default=False,
        verbose_name='Usuario Verificado'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.username} - {self.get_user_type_display()}"
    
    @property
    def full_name(self):
        """Retorna el nombre completo del usuario"""
        return f"{self.first_name} {self.last_name}".strip()


class Address(models.Model):
    """
    Modelo de direcciones para usuarios
    Compatible con el modelo Address de Flutter
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='addresses',
        verbose_name='Usuario'
    )
    
    title = models.CharField(
        max_length=100,
        verbose_name='Título de la Dirección'
    )
    
    full_address = models.TextField(
        verbose_name='Dirección Completa'
    )
    
    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=8,
        verbose_name='Latitud'
    )
    
    longitude = models.DecimalField(
        max_digits=11,
        decimal_places=8,
        verbose_name='Longitud'
    )
    
    instructions = models.TextField(
        blank=True,
        null=True,
        verbose_name='Instrucciones de Entrega'
    )
    
    is_default = models.BooleanField(
        default=False,
        verbose_name='Dirección por Defecto'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Dirección'
        verbose_name_plural = 'Direcciones'
        ordering = ['-is_default', '-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.title}"
    
    def save(self, *args, **kwargs):
        # Si esta dirección se marca como default, desmarcar las otras
        if self.is_default:
            Address.objects.filter(user=self.user, is_default=True).update(is_default=False)
        super().save(*args, **kwargs)
