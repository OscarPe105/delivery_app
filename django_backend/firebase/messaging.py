"""
Firebase Cloud Messaging para notificaciones push
"""
from firebase_admin import messaging
from .config import firebase_config


class FirebaseMessagingService:
    """
    Servicio para enviar notificaciones push
    """
    
    def __init__(self):
        self.app = firebase_config.app
    
    def send_notification_to_token(self, token, title, body, data=None):
        """
        Enviar notificación a un token específico
        
        Args:
            token: Token FCM del dispositivo
            title: Título de la notificación
            body: Cuerpo de la notificación
            data: Datos adicionales (dict)
        
        Returns:
            bool: True si se envió correctamente
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                token=token
            )
            
            response = messaging.send(message)
            print(f"Notificación enviada exitosamente: {response}")
            return True
            
        except Exception as e:
            print(f"Error enviando notificación: {e}")
            return False
    
    def send_notification_to_topic(self, topic, title, body, data=None):
        """
        Enviar notificación a un tópico
        
        Args:
            topic: Nombre del tópico
            title: Título de la notificación
            body: Cuerpo de la notificación
            data: Datos adicionales (dict)
        
        Returns:
            bool: True si se envió correctamente
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                topic=topic
            )
            
            response = messaging.send(message)
            print(f"Notificación enviada al tópico {topic}: {response}")
            return True
            
        except Exception as e:
            print(f"Error enviando notificación al tópico: {e}")
            return False
    
    def send_notification_to_multiple_tokens(self, tokens, title, body, data=None):
        """
        Enviar notificación a múltiples tokens
        
        Args:
            tokens: Lista de tokens FCM
            title: Título de la notificación
            body: Cuerpo de la notificación
            data: Datos adicionales (dict)
        
        Returns:
            dict: Resultado del envío
        """
        try:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                tokens=tokens
            )
            
            response = messaging.send_multicast(message)
            print(f"Notificaciones enviadas: {response.success_count} exitosas, {response.failure_count} fallidas")
            
            return {
                'success_count': response.success_count,
                'failure_count': response.failure_count,
                'responses': response.responses
            }
            
        except Exception as e:
            print(f"Error enviando notificaciones múltiples: {e}")
            return {'success_count': 0, 'failure_count': len(tokens)}
    
    def send_order_notification(self, customer_token, order_data):
        """
        Enviar notificación de pedido al cliente
        """
        title = "Pedido Confirmado"
        body = f"Tu pedido #{order_data['id']} ha sido confirmado"
        
        data = {
            'type': 'order_update',
            'order_id': str(order_data['id']),
            'status': order_data['status']
        }
        
        return self.send_notification_to_token(customer_token, title, body, data)
    
    def send_business_notification(self, business_token, order_data):
        """
        Enviar notificación de nuevo pedido al negocio
        """
        title = "Nuevo Pedido"
        body = f"Tienes un nuevo pedido de {order_data['customer_name']}"
        
        data = {
            'type': 'new_order',
            'order_id': str(order_data['id']),
            'customer_id': str(order_data['customer_id'])
        }
        
        return self.send_notification_to_token(business_token, title, body, data)
    
    def send_order_status_update(self, customer_token, order_data):
        """
        Enviar notificación de actualización de estado de pedido
        """
        status_messages = {
            'confirmed': 'Pedido confirmado',
            'preparing': 'Preparando tu pedido',
            'ready': 'Tu pedido está listo',
            'in_progress': 'Tu pedido está en camino',
            'delivered': 'Pedido entregado',
            'cancelled': 'Pedido cancelado'
        }
        
        title = "Actualización de Pedido"
        body = status_messages.get(order_data['status'], f"Estado: {order_data['status']}")
        
        data = {
            'type': 'order_status_update',
            'order_id': str(order_data['id']),
            'status': order_data['status']
        }
        
        return self.send_notification_to_token(customer_token, title, body, data)


# Instancia global del servicio
firebase_messaging = FirebaseMessagingService()
