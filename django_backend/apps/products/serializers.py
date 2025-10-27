from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    """
    Serializer para productos
    """
    business_name = serializers.CharField(source='business.name', read_only=True)
    category_name = serializers.CharField(source='business.category.name', read_only=True)
    
    class Meta:
        model = Product
        fields = (
            'id', 'business', 'business_name', 'name', 'description',
            'price', 'image_url', 'available', 'is_popular', 'stock_quantity',
            'sku', 'weight', 'dimensions', 'category_name', 'created_at'
        )
        read_only_fields = ('id', 'created_at', 'sku')


class ProductCreateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear productos
    """
    class Meta:
        model = Product
        fields = (
            'business', 'name', 'description', 'price', 'image_url',
            'available', 'is_popular', 'stock_quantity', 'weight', 'dimensions'
        )
    
    def create(self, validated_data):
        # Verificar que el usuario sea propietario del negocio
        business = validated_data['business']
        if business.owner != self.context['request'].user:
            raise serializers.ValidationError(
                'No tienes permisos para agregar productos a este negocio'
            )
        return super().create(validated_data)
