import 'dart:math';
import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/homepage/models/food.dart';
import 'package:golekmakanrek_mobile/homepage/models/restaurant.dart';
import 'package:golekmakanrek_mobile/homepage/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _includeCertainFoodItems = false;
  final Map<int, bool> _starredItems = {};
  final Map<int, int> _starCounts = {};
  bool loggedIn = false;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double _currentMinPrice = 0;
  double _currentMaxPrice = 100000;
  final List<String> _categories = ['Category 1', 'Category 2', 'Category 3'];
  final Map<String, bool> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize star counts for demonstration
    for (int i = 0; i < 10; i++) {
      _starCounts[i] = 0;
    }
    // Initialize selected categories
    for (var category in _categories) {
      _selectedCategories[category] = false;
    }
  }

  Future<List<Food>> fetchFood(CookieRequest request) async {
    var response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_food/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_likes/'); 

    // Melakukan konversi data json menjadi object Food
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
      }
    }
    return listFood;
  }

  Future<List<Restaurant>> fetchRestaurant(CookieRequest request) async {
    final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_restaurant/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Food
    List<Restaurant> listResto = [];
    for (var d in data) {
      if (d != null) {
        listResto.add(Restaurant.fromJson(d));
      }
    }
    return listResto;
  }

  void _showFilterOptions() {
    double initialSize; 
    if (_tabController.index == 0) {
      initialSize = 0.8;
    }
    else {
      initialSize = 0.4;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              expand: false,
              snap: true,
              snapSizes: const [0.5, 0.8],
              initialChildSize: initialSize,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                      children: [
                        const Center( // Center the title
                          child: Text(
                            'Filter Options',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_tabController.index == 0) ...[
                          const Text(
                            'Price Range',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RangeSlider(
                            values: RangeValues(_currentMinPrice, _currentMaxPrice),
                            min: 0,
                            max: 100000,
                            divisions: 100,
                            labels: RangeLabels(
                              _currentMinPrice.round().toString(),
                              _currentMaxPrice.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentMinPrice = values.start;
                                _currentMaxPrice = values.end;
                                _minPriceController.text = values.start.round().toString();
                                _maxPriceController.text = values.end.round().toString();
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Min Price',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentMinPrice = double.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Max Price',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentMaxPrice = double.tryParse(value) ?? 100000;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          children: _categories.map((category) {
                            return FilterChip(
                              label: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              selected: _selectedCategories[category]!,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: _selectedCategories[category]! ? Colors.orange : Colors.grey,
                                ),
                              ),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategories[category] = selected;
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: Colors.transparent,
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (_tabController.index == 0) ...[
                          const Text(
                            'Show Favorited Items',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilterChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  'Show Favorited Items Only',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            selected: _includeCertainFoodItems,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: _includeCertainFoodItems ? Colors.orange : Colors.grey,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                _includeCertainFoodItems = selected;
                              });
                            },
                            backgroundColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            showCheckmark: false,
                          ),
                          const SizedBox(height: 10),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            // Handle filter submission
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterOptions,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Food'),
            Tab(text: 'Restaurant'),
          ],
          labelColor: Colors.white,
        ),
      ),
      drawer: const LeftDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
            future: fetchFood(request),
            builder: (context, AsyncSnapshot<List<Food>> snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage('assets/images/sad_image.png'),
                          width: min(MediaQuery.of(context).size.width * 0.4, 150),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sorry, no food items available yet!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ItemList(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].fields.nama,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text("Rp ${snapshot.data![index].fields.harga}"),
                                    const SizedBox(height: 10),
                                    Text(snapshot.data![index].fields.deskripsi.toString().trim()),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _starredItems[index] == true ? Icons.star : Icons.star_border,
                                      color: _starredItems[index] == true ? Colors.yellow : null,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _starredItems[index] = !_starredItems[index]!;
                                        _starCounts[index] = _starredItems[index] == true
                                            ? (_starCounts[index] ?? 0) + 1
                                            : (_starCounts[index] ?? 1) - 1;
                                      });
                                    },
                                  ),
                                  Text(_starCounts[index].toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),
          FutureBuilder(
            future: fetchRestaurant(request),
            builder: (context, AsyncSnapshot<List<Restaurant>> snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage('assets/images/sad_image.png'),
                          width: min(MediaQuery.of(context).size.width * 0.4, 150),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sorry, no restaurants available yet!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ItemList(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data![index].fields.nama,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(snapshot.data![index].fields.deskripsi.toString().trim()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}