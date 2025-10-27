"""
Firebase Storage para manejo de archivos
"""
import os
import uuid
from django.core.files.uploadedfile import InMemoryUploadedFile
from firebase_admin import storage
from .config import firebase_config


class FirebaseStorageService:
    """
    Servicio para manejar archivos en Firebase Storage
    """
    
    def __init__(self):
        self.bucket = firebase_config.bucket
    
    def upload_file(self, file, folder_path, filename=None):
        """
        Subir archivo a Firebase Storage
        
        Args:
            file: Archivo a subir (InMemoryUploadedFile o File)
            folder_path: Ruta de la carpeta en Storage
            filename: Nombre del archivo (opcional)
        
        Returns:
            str: URL pública del archivo subido
        """
        try:
            # Generar nombre único si no se proporciona
            if not filename:
                file_extension = os.path.splitext(file.name)[1]
                filename = f"{uuid.uuid4()}{file_extension}"
            
            # Ruta completa en Storage
            blob_path = f"{folder_path}/{filename}"
            blob = self.bucket.blob(blob_path)
            
            # Subir archivo
            if isinstance(file, InMemoryUploadedFile):
                file.seek(0)  # Ir al inicio del archivo
                blob.upload_from_string(file.read(), content_type=file.content_type)
            else:
                blob.upload_from_filename(file.path)
            
            # Hacer el archivo público
            blob.make_public()
            
            return blob.public_url
            
        except Exception as e:
            print(f"Error subiendo archivo a Firebase Storage: {e}")
            return None
    
    def delete_file(self, file_url):
        """
        Eliminar archivo de Firebase Storage
        
        Args:
            file_url: URL del archivo a eliminar
        
        Returns:
            bool: True si se eliminó correctamente
        """
        try:
            # Extraer nombre del blob de la URL
            blob_name = file_url.split('/o/')[-1].split('?')[0]
            blob_name = blob_name.replace('%2F', '/')
            
            blob = self.bucket.blob(blob_name)
            blob.delete()
            
            return True
            
        except Exception as e:
            print(f"Error eliminando archivo de Firebase Storage: {e}")
            return False
    
    def upload_user_profile_image(self, file, user_id):
        """
        Subir imagen de perfil de usuario
        """
        return self.upload_file(file, f"users/{user_id}/profile", "profile.jpg")
    
    def upload_business_image(self, file, business_id):
        """
        Subir imagen de negocio
        """
        return self.upload_file(file, f"businesses/{business_id}", "business.jpg")
    
    def upload_product_image(self, file, product_id):
        """
        Subir imagen de producto
        """
        return self.upload_file(file, f"products/{product_id}", "product.jpg")
    
    def upload_order_document(self, file, order_id):
        """
        Subir documento de pedido (recibo, etc.)
        """
        return self.upload_file(file, f"orders/{order_id}/documents")
    
    def get_signed_url(self, file_path, expiration_hours=24):
        """
        Obtener URL firmada para acceso temporal
        
        Args:
            file_path: Ruta del archivo en Storage
            expiration_hours: Horas de expiración (por defecto 24)
        
        Returns:
            str: URL firmada
        """
        try:
            from datetime import datetime, timedelta
            
            blob = self.bucket.blob(file_path)
            expiration_time = datetime.utcnow() + timedelta(hours=expiration_hours)
            
            url = blob.generate_signed_url(
                expiration=expiration_time,
                method='GET'
            )
            
            return url
            
        except Exception as e:
            print(f"Error generando URL firmada: {e}")
            return None


# Instancia global del servicio
firebase_storage = FirebaseStorageService()
