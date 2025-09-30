/**
 * 👤 PANTALLA DE PERFIL DE USUARIO
 * 
 * Pantalla completa para mostrar y editar el perfil del usuario
 * con animaciones y efectos visuales modernos
 * 
 * @author Sistema de Delivery Comunitario
 * @version 2.0.0
 */

import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/material.dart' as material show IconButton;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/improved_buttons.dart';
import '../widgets/animated_components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Container(
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
                  child: CustomScrollView(
                    slivers: [
                      // App Bar personalizado
                      SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Efecto de partículas de fondo
                                Positioned.fill(
                                  child: ParticleEffect(
                                    particleCount: 20,
                                    particleColor: Colors.white.withOpacity(0.1),
                                    child: Container(),
                                  ),
                                ),
                                // Contenido del header
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Avatar del usuario
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Colors.white, Colors.white70],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(0xFF667eea),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Nombre del usuario
                                      Text(
                                        authProvider.user?.name ?? 'Usuario',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Email del usuario
                                      Text(
                                        authProvider.user?.email ?? 'usuario@email.com',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        leading:           material.IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
                        actions: [
                          material.IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // TODO: Implementar edición de perfil
                            },
                          ),
                        ],
                      ),
                      // Contenido principal
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Tarjeta de información personal
                              AnimatedCard(
                                delayMilliseconds: 200,
                                child: _buildInfoCard(
                                  title: 'Información Personal',
                                  icon: Icons.person_outline,
                                  children: [
                                    _buildInfoRow('Nombre', authProvider.user?.name ?? 'No disponible'),
                                    _buildInfoRow('Email', authProvider.user?.email ?? 'No disponible'),
                                    _buildInfoRow('Teléfono', authProvider.user?.phone ?? 'No disponible'),
                                    _buildInfoRow('Tipo de Usuario', _getUserTypeText(authProvider.userType)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Tarjeta de estadísticas
                              AnimatedCard(
                                delayMilliseconds: 400,
                                child: _buildStatsCard(),
                              ),
                              const SizedBox(height: 20),
                              
                              // Tarjeta de configuraciones
                              AnimatedCard(
                                delayMilliseconds: 600,
                                child: _buildSettingsCard(),
                              ),
                              const SizedBox(height: 20),
                              
                              // Botones de acción
                              AnimatedCard(
                                delayMilliseconds: 800,
                                child: _buildActionButtons(authProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Pedidos', '12', Icons.shopping_bag),
              ),
              Expanded(
                child: _buildStatItem('Favoritos', '8', Icons.favorite),
              ),
              Expanded(
                child: _buildStatItem('Reseñas', '5', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Configuraciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingItem(Icons.notifications, 'Notificaciones', true),
          _buildSettingItem(Icons.location_on, 'Ubicación', true),
          _buildSettingItem(Icons.privacy_tip, 'Privacidad', false),
          _buildSettingItem(Icons.help, 'Ayuda y Soporte', false),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // TODO: Implementar cambio de configuración
            },
            activeColor: const Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          PrimaryGradientButton(
            text: 'Editar Perfil',
            icon: Icons.edit,
            onPressed: () {
              // TODO: Implementar edición de perfil
            },
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            text: 'Cerrar Sesión',
            icon: Icons.logout,
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return 'Cliente';
      case UserType.business:
        return 'Negocio';
    }
  }
}
