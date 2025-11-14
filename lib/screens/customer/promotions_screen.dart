import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/promotion.dart';
import '../../providers/community_store_provider.dart';
import '../../widgets/promotion_card.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CommunityStoreProvider>(
        builder: (context, storeProvider, child) {
          final promotions = storeProvider.activePromotions;

          if (promotions.isEmpty) {
            return _EmptyPromotionsState(onRefresh: storeProvider.loadPromotions);
          }

          return RefreshIndicator(
            onRefresh: () async => storeProvider.loadPromotions(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text(
                  'Encuentra descuentos especiales de los negocios cercanos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                ...promotions.map(
                  (promotion) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PromotionCard(
                      promotion: promotion,
                      showExpiry: true,
                      onTap: () => _openPromotionDetail(context, promotion),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openPromotionDetail(BuildContext context, Promotion promotion) {
    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: {
        'businessId': promotion.businessId,
        'productId': promotion.productId,
      },
    );
  }
}

class _EmptyPromotionsState extends StatelessWidget {
  const _EmptyPromotionsState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined, size: 90, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            Text(
              'No hay promociones activas por el momento',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde o refresca la lista para descubrir nuevas ofertas.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

