/**
 * 🔔 PANTALLA DE NOTIFICACIONES
 * 
 * Pantalla para mostrar notificaciones del usuario con diferentes tipos
 * y animaciones modernas
 * 
 * @author Sistema de Delivery Comunitario
 * @version 2.0.0
 */

import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/material.dart' as material show IconButton;
import '../widgets/improved_buttons.dart';
import '../widgets/animated_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'todas';
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': '¡Pedido Confirmado!',
      'message': 'Tu pedido de Pizza Express ha sido confirmado y está siendo preparado.',
      'type': 'order',
      'time': 'Hace 5 minutos',
      'isRead': false,
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'id': '2',
      'title': 'Descuento Especial',
      'message': '¡20% de descuento en Burger King! Válido hasta mañana.',
      'type': 'promotion',
      'time': 'Hace 1 hora',
      'isRead': false,
      'icon': Icons.local_offer,
      'color': Colors.orange,
    },
    {
      'id': '3',
      'title': 'Tu repartidor está en camino',
      'message': 'Carlos está en camino con tu pedido. Llegará en 15 minutos.',
      'type': 'delivery',
      'time': 'Hace 2 horas',
      'isRead': true,
      'icon': Icons.delivery_dining,
      'color': Colors.blue,
    },
    {
      'id': '4',
      'title': 'Nuevo negocio cerca de ti',
      'message': 'Sushi Master ha abierto cerca de tu ubicación. ¡Échale un vistazo!',
      'type': 'business',
      'time': 'Hace 3 horas',
      'isRead': true,
      'icon': Icons.store,
      'color': Colors.purple,
    },
    {
      'id': '5',
      'title': 'Pedido Entregado',
      'message': 'Tu pedido ha sido entregado exitosamente. ¡Disfruta tu comida!',
      'type': 'order',
      'time': 'Ayer',
      'isRead': true,
      'icon': Icons.done_all,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header personalizado
                  _buildHeader(),
                  
                  // Filtros
                  _buildFilters(),
                  
                  // Lista de notificaciones
                  Expanded(
                    child: _buildNotificationsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          material.IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0 
                    ? '$unreadCount notificaciones nuevas'
                    : 'Todas las notificaciones leídas',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterButton('todas', 'Todas')),
          Expanded(child: _buildFilterButton('no_leidas', 'No leídas')),
          Expanded(child: _buildFilterButton('pedidos', 'Pedidos')),
          Expanded(child: _buildFilterButton('ofertas', 'Ofertas')),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF667eea) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();
    
    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return AnimatedCard(
          delayMilliseconds: index * 100,
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final color = notification['color'] as Color;
    final icon = notification['icon'] as IconData;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isRead ? null : Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono de la notificación
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Botón de acción
                material.IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    _showNotificationOptions(notification);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te notificaremos cuando tengas nuevas actualizaciones',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'no_leidas':
        return _notifications.where((n) => !n['isRead']).toList();
      case 'pedidos':
        return _notifications.where((n) => n['type'] == 'order' || n['type'] == 'delivery').toList();
      case 'ofertas':
        return _notifications.where((n) => n['type'] == 'promotion').toList();
      default:
        return _notifications;
    }
  }

  void _showNotificationOptions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: Color(0xFF667eea)),
              title: const Text('Marcar como leída'),
              onTap: () {
                setState(() {
                  notification['isRead'] = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar'),
              onTap: () {
                setState(() {
                  _notifications.remove(notification);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
