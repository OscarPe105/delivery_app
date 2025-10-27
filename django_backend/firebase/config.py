"""
Configuración de Firebase para Django
"""
import os
import json
from django.conf import settings
from decouple import config
import firebase_admin
from firebase_admin import credentials, firestore, storage


class FirebaseConfig:
    """
    Configuración y inicialización de Firebase
    """
    
    def __init__(self):
        self.app = None
        self.db = None
        self.bucket = None
        self._initialize_firebase()
    
    def _initialize_firebase(self):
        """
        Inicializar Firebase Admin SDK
        """
        if not firebase_admin._apps:
            # Opción 1: Usar archivo de credenciales JSON
            service_account_path = os.path.join(
                settings.BASE_DIR, 
                'firebase', 
                'firebase-service-account.json'
            )
            
            if os.path.exists(service_account_path):
                cred = credentials.Certificate(service_account_path)
            else:
                # Opción 2: Usar variables de entorno
                firebase_config = {
                    "type": "service_account",
                    "project_id": config('FIREBASE_PROJECT_ID', default=''),
                    "private_key_id": config('FIREBASE_PRIVATE_KEY_ID', default=''),
                    "private_key": config('FIREBASE_PRIVATE_KEY', default='').replace('\\n', '\n'),
                    "client_email": config('FIREBASE_CLIENT_EMAIL', default=''),
                    "client_id": config('FIREBASE_CLIENT_ID', default=''),
                    "auth_uri": config('FIREBASE_AUTH_URI', default='https://accounts.google.com/o/oauth2/auth'),
                    "token_uri": config('FIREBASE_TOKEN_URI', default='https://oauth2.googleapis.com/token'),
                    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                    "client_x509_cert_url": f"https://www.googleapis.com/robot/v1/metadata/x509/{config('FIREBASE_CLIENT_EMAIL', default='')}"
                }
                
                if firebase_config['project_id']:
                    cred = credentials.Certificate(firebase_config)
                else:
                    raise ValueError("Firebase no está configurado. Verifica las variables de entorno o el archivo de credenciales.")
            
            self.app = firebase_admin.initialize_app(cred, {
                'storageBucket': config('FIREBASE_STORAGE_BUCKET', default='')
            })
        
        # Inicializar servicios
        self.db = firestore.client()
        self.bucket = storage.bucket()


# Instancia global de Firebase
firebase_config = FirebaseConfig()
