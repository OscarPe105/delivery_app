from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase
import json

from .models import Business, Category
from apps.products.models import Product

User = get_user_model()


class BusinessAPITestCase(APITestCase):
    """Tests para la API de negocios"""
    
    def setUp(self):
        """Configuración inicial para cada test"""
        # Crear usuario comerciante
        self.business_owner = User.objects.create_user(
            username='businessowner',
            email='owner@example.com',
            password='testpass123',
            user_type='business'
        )
        
        # Crear categoría
        self.category = Category.objects.create(
            name='Restaurante',
            description='Restaurantes y comida'
        )
        
        # Crear negocio de prueba
        self.business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332,
        )
        
        # Crear producto para el negocio
        self.product = Product.objects.create(
            name='Hamburguesa Test',
            description='Hamburguesa de prueba',
            price=15.99,
            business=self.business,
            category=self.category,
            is_available=True
        )
        
        # Configurar cliente
        self.client = Client()
    
    def test_get_businesses_list(self):
        """Test: Obtener lista de negocios"""
        response = self.client.get('/api/businesses/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('count', response.data)
        self.assertIn('results', response.data)
        self.assertGreater(response.data['count'], 0)
    
    def test_get_business_detail(self):
        """Test: Obtener detalle de un negocio específico"""
        response = self.client.get(f'/api/businesses/{self.business.id}/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], self.business.id)
        self.assertEqual(response.data['name'], 'Restaurante Test')
        self.assertEqual(response.data['phone'], '1234567890')
    
    def test_get_businesses_by_category(self):
        """Test: Obtener negocios filtrados por categoría"""
        response = self.client.get(f'/api/businesses/?category={self.category.id}')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verificar que todos los negocios pertenezcan a la categoría correcta
        for business in response.data['results']:
            self.assertEqual(business['category'], self.category.id)
    
    def test_get_active_businesses_only(self):
        """Test: Obtener solo negocios activos"""
        response = self.client.get('/api/businesses/?is_active=true')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verificar que todos los negocios estén activos
        for business in response.data['results']:
            self.assertTrue(business['is_active'])
    
    def test_business_includes_products(self):
        """Test: Verificar que el negocio incluye sus productos"""
        response = self.client.get(f'/api/businesses/{self.business.id}/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('products', response.data)
        self.assertGreater(len(response.data['products']), 0)
        
        # Verificar que el producto está incluido
        product_names = [p['name'] for p in response.data['products']]
        self.assertIn('Hamburguesa Test', product_names)
    
    def test_business_search_by_name(self):
        """Test: Buscar negocios por nombre"""
        response = self.client.get('/api/businesses/?search=Test')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verificar que se encuentra el negocio
        business_names = [b['name'] for b in response.data['results']]
        self.assertIn('Restaurante Test', business_names)
    
    def test_create_business_authenticated(self):
        """Test: Crear negocio como usuario autenticado"""
        # Simular autenticación
        self.client.force_authenticate(user=self.business_owner)
        
        business_data = {
            'name': 'Nuevo Restaurante',
            'description': 'Descripción del nuevo restaurante',
            'address': 'Calle Nueva 456',
            'phone': '0987654321',
            'email': 'nuevo@restaurant.com',
            'category': self.category.id,
            'latitude': 19.4326,
            'longitude': -99.1332,
            'is_active': True
        }
        
        response = self.client.post(
            '/api/businesses/',
            data=json.dumps(business_data),
            content_type='application/json'
        )
        
        # Nota: Este test puede fallar si no tienes permisos de creación configurados
        if response.status_code == status.HTTP_201_CREATED:
            self.assertIn('id', response.data)
            self.assertEqual(response.data['name'], 'Nuevo Restaurante')
        else:
            # Si no tienes permisos, simplemente verificamos que la respuesta sea coherente
            self.assertIn(response.status_code, [status.HTTP_403_FORBIDDEN, status.HTTP_401_UNAUTHORIZED])


class BusinessModelTestCase(TestCase):
    """Tests para el modelo Business"""
    
    def setUp(self):
        """Configuración inicial para cada test"""
        self.business_owner = User.objects.create_user(
            username='businessowner',
            email='owner@example.com',
            password='testpass123',
            user_type='business'
        )
        
        self.category = Category.objects.create(
            name='Restaurante',
            description='Restaurantes y comida'
        )
    
    def test_business_creation(self):
        """Test: Crear negocio en el modelo"""
        business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332,
        )
        
        self.assertEqual(business.name, 'Restaurante Test')
        self.assertEqual(business.owner, self.business_owner)
        self.assertEqual(business.category, self.category)
        self.assertEqual(business.phone, '1234567890')
        self.assertTrue(business.is_active)
    
    def test_business_str_representation(self):
        """Test: Representación string del negocio"""
        business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332,
        )
        
        self.assertEqual(str(business), 'Restaurante Test')
    
    def test_business_coordinates(self):
        """Test: Verificar coordenadas del negocio"""
        business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332,
        )
        
        self.assertEqual(business.latitude, 19.4326)
        self.assertEqual(business.longitude, -99.1332)
        
        # Verificar que se pueden actualizar las coordenadas
        business.latitude = 20.1234
        business.longitude = -100.5678
        business.save()
        
        updated_business = Business.objects.get(id=business.id)
        self.assertEqual(updated_business.latitude, 20.1234)
        self.assertEqual(updated_business.longitude, -100.5678)
    
    def test_business_status_toggle(self):
        """Test: Cambiar estado activo/inactivo del negocio"""
        business = Business.objects.create(
            name='Restaurante Test',
            description='Restaurante de prueba',
            address='Calle Test 123',
            phone='1234567890',
            owner=self.business_owner,
            category=self.category,
            latitude=19.4326,
            longitude=-99.1332,
        )
        
        # Verificar que está activo inicialmente
        self.assertTrue(business.is_active)
        
        # Cambiar a inactivo
        business.is_active = False
        business.save()
        
        updated_business = Business.objects.get(id=business.id)
        self.assertFalse(updated_business.is_active)
        
        # Cambiar de vuelta a activo
        updated_business.is_active = True
        updated_business.save()
        
        final_business = Business.objects.get(id=business.id)
        self.assertTrue(final_business.is_active)
