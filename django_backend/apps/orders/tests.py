from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken
import json

from .models import Order, OrderItem
from apps.businesses.models import Business
from apps.products.models import Product
from apps.businesses.models import Category
from apps.users.models import Address

User = get_user_model()


class OrderAPITestCase(APITestCase):
    """Tests para la API de pedidos"""
    
    def setUp(self):
        """Configuración inicial para cada test"""
        # Crear usuario de prueba
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='customer'
        )
        
        # Crear usuario comerciante
        self.business_owner = User.objects.create_user(
            username='businessowner',
            email='owner@example.com',
            password='testpass123',
            user_type='business'
        )
        
        # Crear categoría
        self.category = Category.objects.create(
            name='Comida',
            description='Comida rápida'
        )
        
        # Crear negocio
        self.business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332
        )
        
        # Crear productos
        self.product1 = Product.objects.create(
            name='Hamburguesa Test',
            description='Hamburguesa de prueba',
            price=15.99,
            business=self.business,
            available=True
        )
        
        self.product2 = Product.objects.create(
            name='Pizza Test',
            description='Pizza de prueba',
            price=18.99,
            business=self.business,
            available=True
        )
        
        # Crear dirección
        self.address = Address.objects.create(
            user=self.user,
            full_address='Calle Test 456',
            latitude=19.4326,
            longitude=-99.1332
        )
        
        # Configurar cliente
        self.client = Client()
    
    def test_create_order_success(self):
        """Test: Crear pedido exitosamente"""
        order_data = {
            'business': self.business.id,
            'delivery_address': 'Calle Test 789',
            'items': [
                {
                    'product': self.product1.id,
                    'quantity': 2
                },
                {
                    'product': self.product2.id,
                    'quantity': 1
                }
            ],
            'subtotal': 50.97,  # (15.99 * 2) + 18.99
            'delivery_fee': 5.00,
            'tax': 5.60,
            'total': 61.57
        }
        
        response = self.client.post(
            '/api/orders/',
            data=json.dumps(order_data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('id', response.data)
        self.assertEqual(response.data['business'], self.business.id)
        self.assertEqual(len(response.data['items']), 2)
    
    def test_create_order_invalid_data(self):
        """Test: Crear pedido con datos inválidos"""
        order_data = {
            'business': 999,  # Negocio inexistente
            'delivery_address': '',
            'items': [],
            'subtotal': 0,
            'delivery_fee': 0,
            'tax': 0,
            'total': 0
        }
        
        response = self.client.post(
            '/api/orders/',
            data=json.dumps(order_data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_get_orders_list(self):
        """Test: Obtener lista de pedidos"""
        # Crear un pedido de prueba
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=15.99,
            delivery_fee=5.00,
            tax=2.10,
            total=23.09,
            status='pending'
        )
        
        OrderItem.objects.create(
            order=order,
            product=self.product1,
            quantity=1,
            price=self.product1.price,
            total=self.product1.price
        )
        
        response = self.client.get('/api/orders/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('count', response.data)
        self.assertIn('results', response.data)
        self.assertGreater(response.data['count'], 0)
    
    def test_get_order_detail(self):
        """Test: Obtener detalle de un pedido específico"""
        # Crear un pedido de prueba
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=15.99,
            delivery_fee=5.00,
            tax=2.10,
            total=23.09,
            status='pending'
        )
        
        OrderItem.objects.create(
            order=order,
            product=self.product1,
            quantity=1,
            price=self.product1.price,
            total=self.product1.price
        )
        
        response = self.client.get(f'/api/orders/{order.id}/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], order.id)
        self.assertEqual(response.data['status'], 'pending')
        self.assertIn('items', response.data)
    
    def test_order_calculation(self):
        """Test: Verificar cálculos de pedido"""
        order_data = {
            'business': self.business.id,
            'delivery_address': 'Calle Test 789',
            'items': [
                {
                    'product': self.product1.id,
                    'quantity': 3
                }
            ],
            'subtotal': 47.97,  # 15.99 * 3
            'delivery_fee': 10.00,
            'tax': 5.80,
            'total': 63.77
        }
        
        response = self.client.post(
            '/api/orders/',
            data=json.dumps(order_data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verificar que el total calculado sea correcto
        created_order = Order.objects.get(id=response.data['id'])
        expected_total = order_data['subtotal'] + order_data['delivery_fee'] + order_data['tax']
        # Usar round para evitar problemas de precisión decimal
        self.assertEqual(round(float(created_order.total), 2), round(expected_total, 2))


class OrderModelTestCase(TestCase):
    """Tests para el modelo Order"""
    
    def setUp(self):
        """Configuración inicial para cada test"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='customer'
        )
        
        self.business_owner = User.objects.create_user(
            username='businessowner',
            email='owner@example.com',
            password='testpass123',
            user_type='business'
        )
        
        self.category = Category.objects.create(
            name='Comida',
            description='Comida rápida'
        )
        
        self.business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332
        )
        
        self.product = Product.objects.create(
            name='Hamburguesa Test',
            description='Hamburguesa de prueba',
            price=15.99,
            business=self.business,
            available=True
        )
        
        self.address = Address.objects.create(
            user=self.user,
            full_address='Calle Test 456',
            latitude=19.4326,
            longitude=-99.1332
        )
    
    def test_order_creation(self):
        """Test: Crear pedido en el modelo"""
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=15.99,
            delivery_fee=5.00,
            tax=2.10,
            total=23.09,
            status='pending'
        )
        
        self.assertEqual(order.customer, self.user)
        self.assertEqual(order.business, self.business)
        self.assertEqual(order.status, 'pending')
        self.assertEqual(float(order.total), 23.09)
    
    def test_order_str_representation(self):
        """Test: Representación string del pedido"""
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=15.99,
            delivery_fee=5.00,
            tax=2.10,
            total=23.09,
            status='pending'
        )
        
        expected_str = f"Pedido #{order.id} - {self.user.username}"
        self.assertEqual(str(order), expected_str)
    
    def test_order_item_creation(self):
        """Test: Crear item de pedido"""
        order = Order.objects.create(
            customer=self.user,
            business=self.business,
            delivery_address=self.address,
            subtotal=15.99,
            delivery_fee=5.00,
            tax=2.10,
            total=23.09,
            status='pending'
        )
        
        order_item = OrderItem.objects.create(
            order=order,
            product=self.product,
            quantity=2,
            price=self.product.price,
            total=self.product.price * 2
        )
        
        self.assertEqual(order_item.order, order)
        self.assertEqual(order_item.product, self.product)
        self.assertEqual(order_item.quantity, 2)
        self.assertEqual(float(order_item.total), 31.98)
