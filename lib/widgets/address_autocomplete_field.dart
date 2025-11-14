import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/google_maps_config.dart';
import '../services/map_service.dart';
import '../themes/app_colors.dart';

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<Map<String, dynamic>>? onPlaceSelected;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.onPlaceSelected,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  List<Map<String, dynamic>> _predictions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  
  // Debouncer para evitar demasiadas llamadas a la API
  DateTime? _lastSearchTime;
  static const Duration _debounceTime = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.length >= 3) {
      _performSearch(text);
    } else {
      _hideSuggestions();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _hideSuggestions();
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    // Debounce
    final now = DateTime.now();
    if (_lastSearchTime != null && 
        now.difference(_lastSearchTime!) < _debounceTime) {
      return;
    }
    _lastSearchTime = now;

    try {
      // Llamar a Google Places Autocomplete API
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=${GoogleMapsConfig.apiKey}'
        '&language=es'
        '&components=country:sv', // Restringir a El Salvador
      );
      
      debugPrint('🔍 Buscando: $query');
      debugPrint('🔍 URL: $url');
      
      final response = await http.get(url);

      debugPrint('🔍 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('🔍 Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          setState(() {
            _predictions = List<Map<String, dynamic>>.from(
              data['predictions'].map((pred) => {
                'place_id': pred['place_id'],
                'description': pred['description'],
              }),
            );
          });
          
          debugPrint('🔍 Sugerencias encontradas: ${_predictions.length}');
          
          if (_predictions.isNotEmpty && _focusNode.hasFocus) {
            _showOverlay();
          } else {
            _hideSuggestions();
          }
        } else if (data['status'] == 'ZERO_RESULTS') {
          debugPrint('⚠️ No se encontraron resultados para: $query');
          _hideSuggestions();
        } else {
          debugPrint('⚠️ Error de API: ${data['status']}');
          _hideSuggestions();
        }
      }
    } catch (e) {
      debugPrint('❌ Error en búsqueda de direcciones: $e');
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      debugPrint('📍 Obteniendo detalles del place: $placeId');
      
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${Uri.encodeComponent(placeId)}'
          '&key=${GoogleMapsConfig.apiKey}'
          '&fields=geometry,formatted_address',
        ),
      );

      debugPrint('📍 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📍 Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          final formattedAddress = result['formatted_address']?.toString() ?? '';
          final normalizedAddress = MapService.normalizeAddress(formattedAddress);

          final placeData = {
            'address': normalizedAddress,
            'latitude': location['lat'],
            'longitude': location['lng'],
          };

          debugPrint('📍 Dirección: ${result['formatted_address']}');
          debugPrint('📍 Coordenadas: ${location['lat']}, ${location['lng']}');

          widget.controller.text = normalizedAddress;
          widget.onPlaceSelected?.call(placeData);
          _hideSuggestions();
        }
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo detalles del lugar: $e');
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideSuggestions() {
    _removeOverlay();
    setState(() {
      _predictions = [];
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _predictions.length > 5 ? 5 : _predictions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: Text(
                      prediction['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      _getPlaceDetails(prediction['place_id']);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint ?? 'Escribe una dirección',
          prefixIcon: Icon(widget.prefixIcon ?? Icons.location_on),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    _hideSuggestions();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: widget.validator,
        onTap: () {
          if (_predictions.isNotEmpty) {
            _showOverlay();
          }
        },
      ),
    );
  }
}

