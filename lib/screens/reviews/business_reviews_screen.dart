import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/review_card.dart';

class BusinessReviewsScreen extends StatefulWidget {
  final String businessId;
  final String businessName;

  const BusinessReviewsScreen({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  State<BusinessReviewsScreen> createState() => _BusinessReviewsScreenState();
}

class _BusinessReviewsScreenState extends State<BusinessReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar reviews cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false)
          .loadBusinessReviews(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final reviews = reviewProvider.getBusinessReviews(widget.businessId);
    final statistics = reviewProvider.getBusinessStatistics(widget.businessId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas - ${widget.businessName}'),
        elevation: 0,
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (statistics != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ReviewStatisticsCard(statistics: statistics),
                      ),
                    const SizedBox(height: 8),
                    ...reviews.map((review) => ReviewCard(
                          review: review,
                          showBusinessReply: true,
                        )),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.reviews,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reseñas aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en dejar una reseña',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

