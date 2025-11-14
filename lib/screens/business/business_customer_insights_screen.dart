import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer_insight.dart';
import '../../providers/business_provider.dart';
import '../../themes/app_colors.dart';

class BusinessCustomerInsightsScreen extends StatefulWidget {
  const BusinessCustomerInsightsScreen({super.key});

  @override
  State<BusinessCustomerInsightsScreen> createState() => _BusinessCustomerInsightsScreenState();
}

class _BusinessCustomerInsightsScreenState extends State<BusinessCustomerInsightsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _statusFilter = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      if (provider.customerInsights.isEmpty) {
        provider.refreshCustomerInsights();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final insights = provider.customerInsights;
    final filtered = _applyFilters(insights);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes del negocio'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () async {
              await provider.loadOrders();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadOrders(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _buildSummary(insights),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildFilterChips(insights),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ...filtered.map(_buildCustomerCard),
          ],
        ),
      ),
    );
  }

  List<CustomerInsight> _applyFilters(List<CustomerInsight> insights) {
    return insights.where((insight) {
      final matchesSearch = _searchTerm.isEmpty
          ? true
          : insight.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              (insight.email?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);

      final matchesStatus = _statusFilter == 'todos'
          ? true
          : insight.loyaltyLevel.toLowerCase() == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildSummary(List<CustomerInsight> insights) {
    final totalCustomers = insights.length;
    final excellentCount = insights.where((e) => e.isExcellentClient).length;
    final atRiskCount = insights
        .where((e) => e.loyaltyLevel.toLowerCase() == 'en observación')
        .length;
    final totalSpent = insights.fold<double>(0.0, (sum, item) => sum + item.totalSpent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de clientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMiniStatCard(
              title: 'Clientes activos',
              value: totalCustomers.toString(),
              icon: Icons.people_alt_outlined,
              color: AppColors.primary,
            ),
            _buildMiniStatCard(
              title: 'Excelentes',
              value: excellentCount.toString(),
              icon: Icons.emoji_events_outlined,
              color: Colors.green,
            ),
            _buildMiniStatCard(
              title: 'En observación',
              value: atRiskCount.toString(),
              icon: Icons.warning_amber,
              color: Colors.redAccent,
            ),
            _buildMiniStatCard(
              title: 'Ingresos acumulados',
              value: ' 24${totalSpent.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar por nombre o correo',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value.trim();
        });
      },
    );
  }

  Widget _buildFilterChips(List<CustomerInsight> insights) {
    final statuses = <String>{'todos'}
      ..addAll(insights.map((e) => e.loyaltyLevel.toLowerCase()));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = _statusFilter == status;
          String display;
          if (status == 'todos') {
            display = 'Todos';
          } else if (status == 'cliente vip') {
            display = 'Cliente VIP';
          } else {
            display = status[0].toUpperCase() + status.substring(1);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(display),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() {
                  _statusFilter = status;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerInsight insight) {
    final cancellationPercentage = (insight.cancellationRate * 100).clamp(0, 100);
    final subtitle = StringBuffer()
      ..write('${insight.completedOrders} pedidos completados')
      ..write(' · ')
      ..write('${insight.cancelledOrders} cancelaciones');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    insight.profileImage != null && insight.profileImage!.isNotEmpty
                        ? NetworkImage(insight.profileImage!)
                        : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: (insight.profileImage == null || insight.profileImage!.isEmpty)
                    ? Text(
                        insight.name.isNotEmpty ? insight.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (insight.email != null && insight.email!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    insight.email!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _buildStatusPill(insight.loyaltyLevel),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildMetricTag(
                          icon: Icons.attach_money,
                          label: 'Gastado',
                          value: ' 24${insight.totalSpent.toStringAsFixed(2)}',
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTag(
                          icon: Icons.percent,
                          label: 'Cancelación',
                          value: '${cancellationPercentage.toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                    if (insight.lastOrderAt != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            'Último pedido: ${_formatDate(insight.lastOrderAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String loyaltyLevel) {
    Color background;
    Color textColor;

    switch (loyaltyLevel.toLowerCase()) {
      case 'cliente vip':
        background = Colors.purple.withValues(alpha: 0.12);
        textColor = Colors.purple;
        break;
      case 'excelente cliente':
        background = Colors.green.withValues(alpha: 0.12);
        textColor = Colors.green[700]!;
        break;
      case 'en observación':
        background = Colors.red.withValues(alpha: 0.12);
        textColor = Colors.redAccent;
        break;
      case 'cliente frecuente':
        background = Colors.blueGrey.withValues(alpha: 0.12);
        textColor = Colors.blueGrey;
        break;
      default:
        background = AppColors.primary.withValues(alpha: 0.12);
        textColor = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        loyaltyLevel,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricTag({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Sin resultados',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'No encontramos clientes con los filtros aplicados. Ajusta la búsqueda o intenta actualizar la información.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
