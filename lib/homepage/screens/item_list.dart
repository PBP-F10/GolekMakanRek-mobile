import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golekmakanrek_mobile/homepage/models/food.dart';
import 'package:golekmakanrek_mobile/homepage/models/restaurant.dart';
import 'package:golekmakanrek_mobile/homepage/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _favoritedItems = false;
  final Map<String, bool> _starredItems = {};
  final Map<String, int> _starCounts = {};
  bool loggedIn = false;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double _currentMinPrice = 0;
  double _currentMaxPrice = 100000;
  double _minPrice = 0;
  double _maxPrice = 0;
  List<String>? _categories;
  final Map<String, bool> _selectedCategories = {};
  Future<List<Food>>? _foodFuture;
  Future<List<Restaurant>>? _restaurantFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _foodFuture = fetchFood(context.read<CookieRequest>());
    _restaurantFuture = fetchRestaurant(context.read<CookieRequest>());
    fetchFilterData(context.read<CookieRequest>());
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
        _starCounts[d['pk']] = (await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_food_likes/${d['pk']}'))['count'];
      }
    }
    return listFood;
  }

  Future<void> _searchFood(String query) async {
    final request = context.read<CookieRequest>();
    final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/search/food/?nama=$query');
    var data = response;
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
      }
    }
    setState(() {
      _foodFuture = Future.value(listFood);
    });
  }

  Future<void> _searchRestaurant(String query) async {
    final request = context.read<CookieRequest>();
    final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/search/restaurant/?nama=$query');
    var data = response;
    List<Restaurant> listRestaurant = [];
    for (var d in data) {
      if (d != null) {
        listRestaurant.add(Restaurant.fromJson(d));
      }
    }
    setState(() {
      _restaurantFuture = Future.value(listRestaurant);
    });
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

  Future<void> fetchFilterData(CookieRequest request) async {
    var response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_search_options/');
    var data = response;

    setState(() {
      _categories = List<String>.from(data['foodCategories']);
      _currentMinPrice = data['minPrice'].toDouble();
      _currentMaxPrice = data['maxPrice'].toDouble();
      _minPrice = data['minPrice'].toDouble();
      _maxPrice = data['maxPrice'].toDouble();
    });

    // Initialize selected categories
    for (var category in _categories!) {
      _selectedCategories[category] = false;
    }
  }

  void _showFilterOptions() {
    double initialSize; 
    if (_tabController.index == 0) {
      initialSize = 0.7;
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
                            min: _minPrice,
                            max: _maxPrice,
                            divisions: ((_maxPrice - _minPrice) / 1000).round(),
                            labels: RangeLabels(
                              _currentMinPrice.round().toString(),
                              _currentMaxPrice.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentMinPrice = (values.start / 1000).round() * 1000;
                                _currentMaxPrice = (values.end / 1000).round() * 1000;
                                _minPriceController.text = _currentMinPrice.round().toString();
                                _maxPriceController.text = _currentMaxPrice.round().toString();
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
                                    prefixIcon: const Icon(Icons.attach_money),
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onSubmitted: (value) {
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
                                    prefixIcon: const Icon(Icons.attach_money),
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onSubmitted: (value) {
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
                        const SizedBox(height: 20),
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
                          children: _categories!.map((category) {
                            return FilterChip(
                              label: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              selected: _selectedCategories[category]!,
                              shape: StadiumBorder(
                                side: BorderSide(color: !_selectedCategories[category]! ? Colors.grey : Theme.of(context).colorScheme.primary),
                              ),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategories[category] = selected;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (_tabController.index == 0 && loggedIn) ...[
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
                            selected: _favoritedItems,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: _favoritedItems ? Colors.orange : Colors.grey,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                _favoritedItems = selected;
                              });
                            },
                            backgroundColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            showCheckmark: false,
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Handle filter submission
                            if (_tabController.index == 0) {
                              _searchFood("");
                            }
                            else {
                              _searchRestaurant("");
                            }
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

  String formatPrice(int price) {
    return _currencyFormat.format(price);
  }

  @override
  Widget build(BuildContext context) {
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
            onSubmitted: (value) {
              if (_tabController.index == 0) {
                _searchFood(value);
              }
              else {
                _searchRestaurant(value);
              }
            },
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
            future: _foodFuture,
            builder: (context, AsyncSnapshot<List<Food>> snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image(
                        //   image: const AssetImage('assets/images/sad_image.png'),
                        //   width: min(MediaQuery.of(context).size.width * 0.4, 150),
                        // ),
                        SizedBox(height: 20),
                        Text(
                          'No food items found!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        if (snapshot.data![index].fields.diskon > 0) ...[
                                          Text(
                                            formatPrice(snapshot.data![index].fields.harga),
                                            style: const TextStyle(
                                              color: Colors.red,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatPrice((snapshot.data![index].fields.harga * (1 - snapshot.data![index].fields.diskon / 100)).toInt()),
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "-${snapshot.data![index].fields.diskon}%",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ] else ...[
                                          Text(formatPrice(snapshot.data![index].fields.harga)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(snapshot.data![index].fields.deskripsi.toString().trim()),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _starredItems[snapshot.data![index].pk] == true ? Icons.star : Icons.star_border,
                                      color: _starredItems[snapshot.data![index].pk] == true ? Colors.yellow : null,
                                    ),
                                    onPressed: () {
                                      if (!loggedIn) {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You must be logged in to favorite items!'),
                                          ),
                                        );
                                      }
                                      else {
                                        setState(() {
                                          _starredItems[snapshot.data![index].pk] = !_starredItems[snapshot.data![index].pk]!;
                                          _starCounts[snapshot.data![index].pk] = _starredItems[snapshot.data![index].pk] == true
                                              ? (_starCounts[snapshot.data![index].pk] ?? 0) + 1
                                              : (_starCounts[snapshot.data![index].pk] ?? 1) - 1;
                                        });
                                      }
                                    },
                                  ),
                                  Text(_starCounts[snapshot.data![index].pk].toString()),
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
            future: _restaurantFuture,
            builder: (context, AsyncSnapshot<List<Restaurant>> snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image(
                        //   image: const AssetImage('assets/images/sad_image.png'),
                        //   width: min(MediaQuery.of(context).size.width * 0.4, 150),
                        // ),
                        SizedBox(height: 20),
                        Text(
                          'No restaurants found!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
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
                                  fontWeight: FontWeight.w600,
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