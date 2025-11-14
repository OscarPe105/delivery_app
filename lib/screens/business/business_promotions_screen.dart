import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/promotion.dart';
import '../../models/product.dart';

class BusinessPromotionsScreen extends StatefulWidget {
  const BusinessPromotionsScreen({super.key});

  @override
  State<BusinessPromotionsScreen> createState() => _BusinessPromotionsScreenState();
}

class _BusinessPromotionsScreenState extends State<BusinessPromotionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      provider.loadProducts();
      provider.loadPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        backgroundColor: ThemeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPromotionForm(context),
        backgroundColor: ThemeProvider.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nueva promoción'),
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, child) {
          final promotions = provider.promotions;

          if (promotions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no tienes promociones activas.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primera promoción para destacar productos y atraer más clientes.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: ThemeProvider.primaryColor.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.local_offer,
                      color: ThemeProvider.primaryColor,
                    ),
                  ),
                  title: Text(
                    promotion.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(promotion.productName),
                      const SizedBox(height: 4),
                      Text(
                        'Descuento ${promotion.discountPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: ThemeProvider.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (promotion.endDate != null)
                        Text(
                          'Válido hasta ${_formatDate(promotion.endDate!)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openPromotionForm(context, promotion: promotion);
                      } else if (value == 'delete') {
                        _confirmDelete(context, promotion.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openPromotionForm(BuildContext context, {Promotion? promotion}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PromotionForm(promotion: promotion),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String promotionId) async {
    final provider = Provider.of<BusinessProvider>(context, listen: false);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar promoción'),
        content: const Text('¿Deseas eliminar esta promoción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await provider.deletePromotion(promotionId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Promoción eliminada' : 'No se pudo eliminar la promoción'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class PromotionForm extends StatefulWidget {
  const PromotionForm({super.key, this.promotion});

  final Promotion? promotion;

  @override
  State<PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends State<PromotionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;
  DateTime? _startDate;
  DateTime? _endDate;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promotion?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.promotion?.description ?? '');
    _discountController = TextEditingController(
      text: widget.promotion != null ? widget.promotion!.discountPercent.toString() : '10',
    );
    _startDate = widget.promotion?.startDate;
    _endDate = widget.promotion?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final products = provider.products;

    if (_selectedProduct == null) {
      if (widget.promotion != null) {
        final matchingProducts =
            products.where((product) => product.id == widget.promotion!.productId);
        if (matchingProducts.isNotEmpty) {
          _selectedProduct = matchingProducts.first;
        }
      }
      _selectedProduct ??= products.isNotEmpty ? products.first : null;
    }

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primero agrega productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Para crear promociones necesitas tener productos registrados en tu catálogo.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.promotion == null ? 'Crear promoción' : 'Editar promoción',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Product>(
              initialValue: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Producto a promocionar',
                border: OutlineInputBorder(),
              ),
              items: products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
              validator: (value) => value == null ? 'Selecciona un producto' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la promoción',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Descuento (%)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final discount = double.tryParse(value ?? '');
                if (discount == null) return 'Ingresa un descuento válido';
                if (discount <= 0 || discount > 90) return 'Usa un valor entre 1 y 90';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Inicio',
                    date: _startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerTile(
                    label: 'Fin',
                    date: _endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_selectedProduct == null) return;

                  final discount = double.parse(_discountController.text);

                  ScaffoldMessenger.of(context).clearSnackBars();

                  if (widget.promotion == null) {
                    final newPromotion = await provider.createPromotion(
                      product: _selectedProduct!,
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                      discountPercent: discount,
                      startDate: _startDate,
                      endDate: _endDate,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newPromotion != null
                            ? 'Promoción creada correctamente'
                            : 'No se pudo crear la promoción'),
                      ),
                    );
                  } else {
                    final success = await provider.updatePromotion(
                      promotion: widget.promotion!,
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                      discountPercent: discount,
                      startDate: _startDate,
                      endDate: _endDate,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Promoción actualizada'
                            : 'No se pudo actualizar la promoción'),
                      ),
                    );
                  }
                },
                child: Text(widget.promotion == null ? 'Guardar promoción' : 'Actualizar'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                  : 'Seleccionar',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

