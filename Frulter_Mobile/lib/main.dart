import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruits & Veggies Filter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, 
        useMaterial3: true,
      ),
      home: const FilterListScreen(),
    );
  }
}

class FoodItem {
  final String name;
  final String category;
  final String size;  
  final bool hasSeeds; 
  final bool isBerry;  
  final String imageUrl; 

  FoodItem({
    required this.name,
    required this.category,
    required this.size,
    required this.hasSeeds,
    required this.isBerry,
    required this.imageUrl,
  });
}

class FilterListScreen extends StatefulWidget {
  const FilterListScreen({super.key});

  @override
  State<FilterListScreen> createState() => _FilterListScreenState();
}

class _FilterListScreenState extends State<FilterListScreen> {
  
  final List<FoodItem> allItems = [
    FoodItem(
      name: 'Strawberry',
      category: 'Fruit',
      size: 'Small',
      hasSeeds: true,
      isBerry: true,
      imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200',
    ),

    FoodItem(
      name: 'Watermelon',
      category: 'Fruit',
      size: 'Large',
      hasSeeds: true,
      isBerry: false,
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=200',
    ),
    
    FoodItem(
      name: 'Carrot',
      category: 'Vegetable',
      size: 'Medium',
      hasSeeds: false,
      isBerry: false,
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200',
    ),

    FoodItem(
      name: 'Blueberry',
      category: 'Fruit',
      size: 'Small',
      hasSeeds: true,
      isBerry: true,
      imageUrl: 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?w=200',
    ),

    FoodItem(
      name: 'Apple',
      category: 'Fruit',
      size: 'Medium',
      hasSeeds: true,
      isBerry: false,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200',
    ),

    FoodItem(
      name: 'Mango',
      category: 'Fruit',
      size: 'Medium',
      hasSeeds: true,
      isBerry: false,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200',
    ),

    FoodItem(
      name: 'Grapes',
      category: 'Fruit',
      size: 'Small',
      hasSeeds: true,
      isBerry: true,
      imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200',
    ),
    FoodItem(
      name: 'Orange',
      category: 'Fruit',
      size: 'Medium',
      hasSeeds: true,
      isBerry: false,
      imageUrl: 'https://images.unsplash.com/photo-1547514701-42782101795e?w=200',
    ),
    FoodItem(
      name: 'Banana',
      category: 'Fruit',
      size: 'Large',
      hasSeeds: false,
      isBerry: true, 
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200',
    ),
  ];

  // Variables to hold our current filter settings
  String selectedSizeFilter = 'All'; 
  String selectedSeedFilter = 'All'; 
  String selectedBerryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    List<FoodItem> filteredItems = allItems.where((item) {
      
      // 1. Filter by Size
      if (selectedSizeFilter != 'All' && item.size != selectedSizeFilter) {
        return false;
      }
      
      // 2. Filter by Seeds
      if (selectedSeedFilter == 'Has Seeds' && !item.hasSeeds) return false;
      if (selectedSeedFilter == 'No Seeds' && item.hasSeeds) return false;
      
      // 3. Filter by Berries
      if (selectedBerryFilter == 'Berries Only' && !item.isBerry) return false;
      if (selectedBerryFilter == 'No Berries' && item.isBerry) return false;

      return true;
    }).toList(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Filter'),
        backgroundColor: Colors.green[100],
      ),
      
      body: Column(
        children: [
          //--- FILTER CONTROLS DROP-DOWNS SECTION ---
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Spreads dropdowns evenly
              children: [
                // Dropdown 1: Size Filter
                DropdownButton<String>(
                  value: selectedSizeFilter,
                  items: <String>['All', 'Small', 'Medium', 'Large'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { selectedSizeFilter = newValue!; });
                  },
                ),

                // Dropdown 2: Seed Filter
                DropdownButton<String>(
                  value: selectedSeedFilter,
                  items: <String>['All', 'Has Seeds', 'No Seeds'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { selectedSeedFilter = newValue!; });
                  },
                ),

                // Dropdown 3: Berry Filter
                DropdownButton<String>(
                  value: selectedBerryFilter,
                  items: <String>['All', 'Berries Only', 'No Berries'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { selectedBerryFilter = newValue!; });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No items match your filters!'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl, 
                              width: 50, 
                              height: 50, 
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${item.category} • Size: ${item.size}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}