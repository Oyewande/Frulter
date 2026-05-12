import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

const String kBaseUrl = 'https://frulter.up.railway.app';

// ─── Model ─────────────────────────────────────────────────────────────────
class FoodItem {
  final int id;
  final String name;
  final String category;
  final String size;
  final bool hasSeeds;
  final bool isBerry;
  final String imageUrl;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.hasSeeds,
    required this.isBerry,
    required this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      size: json['size'] as String,
      hasSeeds: json['has_seeds'] as bool,
      isBerry: json['is_berry'] as bool,
      imageUrl: json['image'] as String,
    );
  }
}

// ─── API Service ───────────────────────────────────────────────────────────
class ProduceApi {
  static Future<List<FoodItem>> fetchProduce({
    String? category,
    String? size,
    bool? hasSeeds,
    bool? isBerry,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'all') queryParams['category'] = category;
    if (size != null && size != 'all') queryParams['size'] = size;
    if (hasSeeds != null) queryParams['has_seeds'] = hasSeeds.toString();
    if (isBerry != null) queryParams['is_berry'] = isBerry.toString();

    final uri = Uri.parse('$kBaseUrl/produce/filter')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['data'] as List<dynamic>;
      return items
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}

// ─── App ───────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frulter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const FilterListScreen(),
    );
  }
}

// ─── Screen ────────────────────────────────────────────────────────────────
class FilterListScreen extends StatefulWidget {
  const FilterListScreen({super.key});

  @override
  State<FilterListScreen> createState() => _FilterListScreenState();
}

class _FilterListScreenState extends State<FilterListScreen> {
  List<FoodItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'all';
  String _selectedSize = 'all';
  String _selectedSeeds = 'all';
  String _selectedBerry = 'all';

  @override
  void initState() {
    super.initState();
    _loadProduce();
  }

  Future<void> _loadProduce() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Convert dropdown string values to the types the API expects
      bool? hasSeeds;
      if (_selectedSeeds == 'Has Seeds') hasSeeds = true;
      if (_selectedSeeds == 'No Seeds') hasSeeds = false;

      bool? isBerry;
      if (_selectedBerry == 'Berries Only') isBerry = true;
      if (_selectedBerry == 'No Berries') isBerry = false;

      final items = await ProduceApi.fetchProduce(
        category: _selectedCategory,
        size: _selectedSize,
        hasSeeds: hasSeeds,
        isBerry: isBerry,
      );
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frulter'),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadProduce,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Bar ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FilterDropdown(
                  label: 'Category',
                  value: _selectedCategory,
                  items: const ['all', 'fruit', 'vegetable'],
                  itemLabel: (c) => c == 'all' ? 'All' : _capitalize(c),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                    _loadProduce();
                  },
                ),
                _FilterDropdown(
                  label: 'Size',
                  value: _selectedSize,
                  items: const ['all', 'small', 'medium', 'large'],
                  itemLabel: (s) => s == 'all' ? 'All' : _capitalize(s),
                  onChanged: (val) {
                    setState(() => _selectedSize = val);
                    _loadProduce();
                  },
                ),
                _FilterDropdown(
                  label: 'Seeds',
                  value: _selectedSeeds,
                  items: const ['all', 'Has Seeds', 'No Seeds'],
                  itemLabel: (s) => s,
                  onChanged: (val) {
                    setState(() => _selectedSeeds = val);
                    _loadProduce();
                  },
                ),
                _FilterDropdown(
                  label: 'Berry',
                  value: _selectedBerry,
                  items: const ['all', 'Berries Only', 'No Berries'],
                  itemLabel: (s) => s == 'all' ? 'All' : s,
                  onChanged: (val) {
                    setState(() => _selectedBerry = val);
                    _loadProduce();
                  },
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Could not reach the server',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProduce,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No items match your filters.'));
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${_capitalize(item.category)} · ${item.size}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.hasSeeds)
                  const Tooltip(
                    message: 'Has seeds',
                    child: Icon(Icons.grain, size: 16, color: Colors.brown),
                  ),
                if (item.isBerry)
                  const Tooltip(
                    message: 'Berry',
                    child: Icon(Icons.circle, size: 16, color: Colors.purple),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Reusable filter dropdown ──────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final String Function(String) itemLabel;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        DropdownButton<String>(
          value: value,
          isDense: true,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(itemLabel(item),
                        style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }
}
