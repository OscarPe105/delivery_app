import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos, negocios...',
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
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                // Aquí puedes implementar la lógica de búsqueda
                _performSearch(value);
              },
            ),
          ),
          
          // Resultados de búsqueda
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Busca productos o negocios',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: 5, // Simulamos 5 resultados
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.store,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('Resultado ${index + 1}'),
                          subtitle: const Text('Descripción del resultado'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navegar al detalle del resultado
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    // Aquí implementarías la lógica de búsqueda real
    print('Buscando: $query');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
