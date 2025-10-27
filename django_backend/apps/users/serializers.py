from rest_framework import serializers
from .models import User, Address


class AddressSerializer(serializers.ModelSerializer):
    """
    Serializer para direcciones de usuarios
    """
    class Meta:
        model = Address
        fields = (
            'id', 'title', 'full_address', 'latitude', 
            'longitude', 'instructions', 'is_default', 'created_at'
        )
        read_only_fields = ('id', 'created_at')
    
    def create(self, validated_data):
        # Asignar el usuario actual
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class UserDetailSerializer(serializers.ModelSerializer):
    """
    Serializer detallado para usuarios con direcciones
    """
    addresses = AddressSerializer(many=True, read_only=True)
    full_name = serializers.ReadOnlyField()
    
    class Meta:
        model = User
        fields = (
            'id', 'username', 'email', 'first_name', 'last_name',
            'full_name', 'phone', 'user_type', 'profile_image',
            'is_verified', 'date_joined', 'addresses'
        )
        read_only_fields = ('id', 'date_joined', 'is_verified')


class UserSerializer(serializers.ModelSerializer):
    """Serializer básico para usuarios"""
    full_name = serializers.ReadOnlyField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 
            'full_name', 'user_type', 'phone', 'profile_image', 
            'is_verified', 'firebase_uid', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'firebase_uid']


class UserCreateSerializer(serializers.ModelSerializer):
    """Serializer para crear usuarios"""
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'first_name', 'last_name', 
            'user_type', 'phone', 'password', 'password_confirm'
        ]
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Las contraseñas no coinciden")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user
