from rest_framework import serializers
from .models import Business, Category
from apps.products.serializers import ProductSerializer


class CategorySerializer(serializers.ModelSerializer):
    """
    Serializer para categorías
    """
    class Meta:
        model = Category
        fields = ('id', 'name', 'icon', 'description', 'is_active')


class BusinessSerializer(serializers.ModelSerializer):
    """
    Serializer para negocios
    """
    category_name = serializers.CharField(source='category.name', read_only=True)
    owner_name = serializers.CharField(source='owner.full_name', read_only=True)
    products = ProductSerializer(many=True, read_only=True)
    is_currently_open = serializers.ReadOnlyField()
    
    class Meta:
        model = Business
        fields = (
            'id', 'name', 'category', 'category_name', 'description',
            'address', 'phone', 'latitude', 'longitude', 'rating',
            'image_url', 'is_active', 'is_open', 'opening_time',
            'closing_time', 'tags', 'owner', 'owner_name',
            'is_currently_open', 'products', 'created_at'
        )
        read_only_fields = ('id', 'created_at', 'owner', 'rating')


class BusinessCreateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear negocios
    """
    class Meta:
        model = Business
        fields = (
            'name', 'category', 'description', 'address', 'phone',
            'latitude', 'longitude', 'image_url', 'opening_time',
            'closing_time', 'tags'
        )
    
    def create(self, validated_data):
        # Asignar el usuario actual como propietario
        validated_data['owner'] = self.context['request'].user
        return super().create(validated_data)
