from rest_framework import serializers
from .models import Order, OrderItem
from apps.products.models import Product
from apps.users.models import Address


class OrderItemSerializer(serializers.ModelSerializer):
    """
    Serializer para items de pedido
    """
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_image = serializers.CharField(source='product.image_url', read_only=True)
    
    class Meta:
        model = OrderItem
        fields = (
            'id', 'product', 'product_name', 'product_image',
            'quantity', 'price', 'total', 'notes'
        )
        read_only_fields = ('id', 'total', 'price')  # El precio se obtiene del producto


class OrderSerializer(serializers.ModelSerializer):
    """
    Serializer para pedidos
    """
    items = OrderItemSerializer(many=True, read_only=True)
    customer_name = serializers.CharField(source='customer.full_name', read_only=True)
    business_name = serializers.CharField(source='business.name', read_only=True)
    delivery_address_title = serializers.CharField(source='delivery_address.title', read_only=True)
    
    class Meta:
        model = Order
        fields = (
            'id', 'customer', 'customer_name', 'business', 'business_name',
            'delivery_address', 'delivery_address_title', 'status', 'total',
            'subtotal', 'delivery_fee', 'tax', 'notes', 'estimated_delivery_time',
            'delivered_at', 'items', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'customer')


class OrderCreateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear pedidos
    """
    items = OrderItemSerializer(many=True, write_only=True)
    delivery_address = serializers.CharField(write_only=True, required=False)  # Aceptar texto o ID
    
    class Meta:
        model = Order
        fields = (
            'id', 'business', 'delivery_address', 'items', 'notes',
            'subtotal', 'delivery_fee', 'tax'
        )
        read_only_fields = ('id',)
    
    def create(self, validated_data):
        items_data = validated_data.pop('items')
        
        # Manejar delivery_address
        delivery_address_data = validated_data.pop('delivery_address', None)
        print(f"Delivery address data: {delivery_address_data}")
        
        # Obtener o crear usuario anónimo (se usará para customer y address)
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        user = getattr(self.context.get('request'), 'user', None)
        print(f"Request user: {user}, is_authenticated: {user.is_authenticated if user else False}")
        
        # Determinar el usuario a usar (autenticado o anónimo)
        if user and user.is_authenticated:
            target_user = user
            validated_data['customer'] = user
            print(f"Usando usuario autenticado: {user.username}")
        else:
            # Crear un usuario anónimo temporal
            target_user, created = User.objects.get_or_create(
                username='anonymous',
                defaults={'email': 'anonymous@temp.com', 'user_type': 'customer'}
            )
            validated_data['customer'] = target_user
            print(f"Usando usuario anonimo (created: {created}): {target_user.username}")
        
        # Si viene como texto, crear o obtener la Address
        if isinstance(delivery_address_data, str):
            print(f"Creando direccion temporal: {delivery_address_data}")
            # Crear una dirección temporal usando el usuario determinado
            address = Address.objects.create(
                user=target_user,
                title='Entrega',
                full_address=delivery_address_data,
                latitude=0.0,  # Valores por defecto
                longitude=0.0,
                is_default=False,
            )
            validated_data['delivery_address'] = address
            print(f"Direccion creada con ID: {address.id}")
        else:
            validated_data['delivery_address'] = delivery_address_data
        
        # Calcular el total
        subtotal = validated_data.get('subtotal', 0)
        delivery_fee = validated_data.get('delivery_fee', 0)
        tax = validated_data.get('tax', 0)
        total = subtotal + delivery_fee + tax
        print(f"Subtotal: {subtotal}, Delivery: {delivery_fee}, Tax: {tax}, Total: {total}")
        
        if total <= 0:
            raise serializers.ValidationError("El total del pedido debe ser mayor a 0")
        
        validated_data['total'] = total
        
        print(f"Creando pedido con datos: {validated_data}")
        order = Order.objects.create(**validated_data)
        print(f"Pedido creado con ID: {order.id}")
        
        # Crear los items del pedido
        print(f"Creando {len(items_data)} items del pedido...")
        items_created = 0
        for idx, item_data in enumerate(items_data):
            print(f"Item {idx + 1}: {item_data}")
            try:
                # Obtener el precio del producto
                # item_data['product'] puede ser un objeto Product o un ID
                product_id = item_data['product']
                if isinstance(product_id, Product):
                    product = product_id
                else:
                    product = Product.objects.get(id=product_id)
                
                print(f"Producto obtenido: {product.name}, Precio: {product.price}")
                
                # Crear el item del pedido
                OrderItem.objects.create(
                    order=order,
                    product=product,
                    quantity=item_data['quantity'],
                    price=product.price,
                )
                items_created += 1
                print(f"Item {idx + 1} creado exitosamente")
            except Product.DoesNotExist:
                print(f"Error: Producto con ID {item_data['product']} no existe")
            except Exception as e:
                print(f"Error creando item {idx + 1}: {e}")
                import traceback
                traceback.print_exc()
        
        if items_created == 0:
            # Si no se creó ningún item, eliminar el pedido
            order.delete()
            raise serializers.ValidationError("No se pudieron crear items del pedido")
        
        print(f"Pedido {order.id} creado exitosamente con {items_created} items")
        
        # Reload order para obtener items
        order.refresh_from_db()
        return order


class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer para actualizar estado de pedido
    """
    class Meta:
        model = Order
        fields = ('status', 'estimated_delivery_time', 'notes')
