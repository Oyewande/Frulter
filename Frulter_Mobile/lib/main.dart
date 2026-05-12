import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// ─── Config ────────────────────────────────────────────────────────────────
// Replace this with your Railway deployment URL once deployed.
// For local testing use:
//   Android emulator → 'http://10.0.2.2:8000'
//   iOS simulator / web → 'http://localhost:8000'
const String kBaseUrl = 'https://your-app.up.railway.app';

// ─── Model ─────────────────────────────────────────────────────────────────
class ProduceItem {
  final int id;
  final String name;
  final String category;
  final String color;
  final String imageUrl;

  const ProduceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imageUrl,
  });

  factory ProduceItem.fromJson(Map<String, dynamic> json) {
    return ProduceItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
      imageUrl: json['image'] as String,
    );
  }
}

// ─── API Service ───────────────────────────────────────────────────────────
class ProduceApi {
  static Future<List<ProduceItem>> fetchProduce({
    String? category,
    String? color,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'all') queryParams['category'] = category;
    if (color != null && color != 'all') queryParams['color'] = color;

    final uri = Uri.parse('$kBaseUrl/produce/filter')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response =
        await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['data'] as List<dynamic>;
      return items
          .map((e) => ProduceItem.fromJson(e as Map<String, dynamic>))
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
  List<ProduceItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'all';
  String _selectedColor = 'all';

  static const List<String> _categories = ['all', 'fruit', 'vegetable'];
  static const List<String> _colors = [
    'all',
    'Red',
    'Yellow',
    'Green',
    'Orange',
    'Purple',
  ];

  static const Map<String, Color> _colorMap = {
    'Red': Colors.red,
    'Yellow': Colors.yellow,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
  };

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
      final items = await ProduceApi.fetchProduce(
        category: _selectedCategory,
        color: _selectedColor,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FilterDropdown<String>(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  itemLabel: (c) => c == 'all' ? 'All' : _capitalize(c),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                    _loadProduce();
                  },
                ),
                _FilterDropdown<String>(
                  label: 'Color',
                  value: _selectedColor,
                  items: _colors,
                  itemLabel: (c) => c == 'all' ? 'All' : c,
                  onChanged: (val) {
                    setState(() => _selectedColor = val);
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
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${_capitalize(item.category)} · ${item.color}'),
            trailing: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _colorMap[item.color] ?? Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Reusable filter dropdown ──────────────────────────────────────────────
class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

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
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        DropdownButton<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item)),
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
