import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showBusinesses = true;

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<CommunityStoreProvider>(context);

    final businessResults = _searchQuery.isEmpty
        ? <Business>[]
        : storeProvider.businesses.where((business) {
            final q = _searchQuery.toLowerCase();
            final nameMatch = business.name.toLowerCase().contains(q);
            final descriptionMatch =
                (business.description ?? '').toLowerCase().contains(q);
            final categoryMatch = business.category.toLowerCase().contains(q);
            final tagsMatch = business.tags?.any(
                  (tag) => tag.toLowerCase().contains(q),
                ) ??
                false;
            return nameMatch || descriptionMatch || categoryMatch || tagsMatch;
          }).toList();

    final productResults = _searchQuery.isEmpty
        ? <Product>[]
        : storeProvider.products.where((product) {
            final q = _searchQuery.toLowerCase();
            final nameMatch = product.name.toLowerCase().contains(q);
            final descriptionMatch =
                product.description.toLowerCase().contains(q);
            return nameMatch || descriptionMatch;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: ThemeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchHeader(storeProvider),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _showBusinesses
                    ? _buildBusinessesList(businessResults)
                    : _buildProductsList(storeProvider, productResults),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(CommunityStoreProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar negocios o productos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: ThemeProvider.primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                provider.setSearchQuery(value);
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleChip(
                label: 'Negocios',
                selected: _showBusinesses,
                onTap: () {
                  setState(() {
                    _showBusinesses = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildToggleChip(
                label: 'Productos',
                selected: !_showBusinesses,
                onTap: () {
                  setState(() {
                    _showBusinesses = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Busca productos o negocios',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessesList(List<Business> results) {
    if (results.isEmpty) {
      return _buildNoResults(
        'No encontramos negocios que coincidan con tu búsqueda.',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final business = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ThemeProvider.primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.store, color: ThemeProvider.primaryColor),
            ),
            title: Text(business.name),
            subtitle: Text(
              business.description ?? business.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/business-detail', arguments: business);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductsList(CommunityStoreProvider provider, List<Product> results) {
    if (results.isEmpty) {
      return _buildNoResults(
        'No encontramos productos que coincidan con tu búsqueda.',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        const currencySymbol = "\$";
        final promotion = provider.getPromotionForProduct(product.id);
        final originalPrice = '$currencySymbol${product.price.toStringAsFixed(2)}';
        final promoValue = promotion?.promotionalPrice;
        final promoPrice = promoValue != null
            ? '$currencySymbol${promoValue.toStringAsFixed(2)}'
            : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ThemeProvider.primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.fastfood, color: ThemeProvider.primaryColor),
            ),
            title: Text(product.name),
            subtitle: Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (promoPrice != null)
                  Text(
                    originalPrice,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  promoPrice ?? originalPrice,
                  style: TextStyle(
                    color: promoPrice != null ? Colors.redAccent : ThemeProvider.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            onTap: () {
              final business = provider.getBusinessById(product.businessId);
              if (business == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No pudimos encontrar el negocio de este producto.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/product-detail',
                arguments: {
                  'business': business,
                  'productId': product.id,
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoResults(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ThemeProvider.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? ThemeProvider.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
