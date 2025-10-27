#!/usr/bin/env python
"""
Script para probar todas las APIs del sistema
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8000/api"

def test_api():
    """Probar todas las APIs del sistema"""
    
    print("Probando APIs del sistema...")
    
    # 1. Probar categorías (no requiere autenticación)
    print("\n1. Probando categorias...")
    try:
        response = requests.get(f"{BASE_URL}/businesses/categories/")
        if response.status_code == 200:
            data = response.json()
            print(f"  OK - Categorias obtenidas: {len(data['results'])}")
            for cat in data['results'][:3]:  # Mostrar solo las primeras 3
                print(f"    - {cat['name']}")
        else:
            print(f"  ERROR - {response.status_code}")
    except Exception as e:
        print(f"  ERROR - {e}")
    
    # 2. Probar registro de usuario
    print("\n2. Probando registro de usuario...")
    user_data = {
        "username": "test_user_api",
        "email": "test_api@example.com",
        "first_name": "Test",
        "last_name": "User",
        "user_type": "customer",
        "phone": "+1234567899",
        "password": "test123456",
        "password_confirm": "test123456"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/users/register/", json=user_data)
        if response.status_code == 201:
            print("  OK - Usuario registrado exitosamente")
        else:
            print(f"  ERROR - {response.status_code}")
            print(f"    {response.text}")
    except Exception as e:
        print(f"  ERROR - {e}")
    
    # 3. Probar login (simulado con credenciales existentes)
    print("\n3. Probando autenticacion...")
    login_data = {
        "username": "cliente_test",
        "password": "test123"
    }
    
    try:
        # Nota: Este endpoint puede no existir, es solo para demostración
        response = requests.post(f"{BASE_URL}/auth/login/", json=login_data)
        if response.status_code == 200:
            print("  OK - Login exitoso")
            token = response.json().get('token')
        else:
            print(f"  WARNING - Login endpoint no disponible: {response.status_code}")
            token = None
    except Exception as e:
        print(f"  WARNING - Login no disponible: {e}")
        token = None
    
    # 4. Probar endpoints que requieren autenticación (simulados)
    if token:
        headers = {"Authorization": f"Bearer {token}"}
    else:
        headers = {}
        print("  WARNING - Continuando sin autenticacion...")
    
    # 5. Probar productos de un negocio específico
    print("\n4. Probando productos...")
    try:
        response = requests.get(f"{BASE_URL}/products/business/1/")
        if response.status_code == 200:
            data = response.json()
            print(f"  OK - Productos obtenidos: {len(data['results'])}")
            for product in data['results'][:2]:  # Mostrar solo los primeros 2
                print(f"    - {product['name']}: ${product['price']}")
        else:
            print(f"  ERROR - {response.status_code}")
    except Exception as e:
        print(f"  ERROR - {e}")
    
    # 6. Probar productos populares
    print("\n5. Probando productos populares...")
    try:
        response = requests.get(f"{BASE_URL}/products/popular/")
        if response.status_code == 200:
            data = response.json()
            print(f"  OK - Productos populares: {len(data['results'])}")
        else:
            print(f"  ERROR - {response.status_code}")
    except Exception as e:
        print(f"  ERROR - {e}")
    
    # 7. Probar negocios cercanos (simulado)
    print("\n6. Probando negocios cercanos...")
    try:
        response = requests.get(f"{BASE_URL}/businesses/nearby/?lat=19.4326&lng=-99.1332&radius=5")
        if response.status_code == 200:
            data = response.json()
            print(f"  OK - Negocios cercanos: {len(data)}")
            for business in data[:2]:  # Mostrar solo los primeros 2
                print(f"    - {business['name']}")
        else:
            print(f"  ERROR - {response.status_code}")
    except Exception as e:
        print(f"  ERROR - {e}")
    
    print("\nPruebas de API completadas!")
    print("\nResumen de endpoints disponibles:")
    print("  GET  /api/businesses/categories/     - Listar categorias")
    print("  GET  /api/products/business/{id}/   - Productos de un negocio")
    print("  GET  /api/products/popular/         - Productos populares")
    print("  GET  /api/businesses/nearby/        - Negocios cercanos")
    print("  POST /api/users/register/           - Registrar usuario")
    print("  GET  /api/users/profile/            - Perfil de usuario (requiere auth)")
    print("  GET  /api/orders/                   - Listar pedidos (requiere auth)")
    print("  POST /api/orders/                    - Crear pedido (requiere auth)")


if __name__ == '__main__':
    test_api()