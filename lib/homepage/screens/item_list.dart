import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golekmakanrek_mobile/homepage/models/food.dart';
import 'package:golekmakanrek_mobile/homepage/models/restaurant.dart';
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
  final HashSet _starredItems = HashSet();
  final Map<String, int> _starCounts = {};
  bool loggedIn = false;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double _currentMinPrice = 0;
  double _currentMaxPrice = 0;
  double _minPrice = 0;
  double _maxPrice = 0;
  int _totalFoods = 0;
  int _totalRestaurants = 0;
  List<String>? _categories;
  final Map<String, bool> _selectedCategories = {};
  Future<List<Food>>? _foodFuture;
  Future<List<Restaurant>>? _restaurantFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String? _selectedCategory;
  bool _isFilterLoading = true;
  bool _isListLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loggedIn = context.read<CookieRequest>().loggedIn;
    _foodFuture = fetchFood(context.read<CookieRequest>());
    _restaurantFuture = fetchRestaurant(context.read<CookieRequest>());
    fetchFilterData(context.read<CookieRequest>()).then((_) {
      setState(() {
        _isFilterLoading = false;
      });
    });
  }

  Future<List<Food>> fetchFood(CookieRequest request) async {
    var response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_food/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    if (request.loggedIn) {
      response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_user_likes/'); 
      for (var d in response) {
        if (d != null) {
          _starredItems.add(d['fields']['food_id']);
        }
      }
    }

    // Melakukan konversi data json menjadi object Food
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
        _starCounts[d['pk']] = (await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_food_likes/${d['pk']}'))['count'];
      }
    }
    _totalFoods = listFood.length;
    return listFood;
  }

  Future<void> _searchFood(String name, String category, double minPrice, double maxPrice, bool likeFilter) async {
    setState(() {
      _isListLoading = true;
    });
    var searchURL = Uri.https(
      'joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id',
      '/search/food/',
      {
        'nama': name,
        'kategori': category,
        'min_harga': minPrice.toInt().toString(),
        'max_harga': maxPrice.toInt().toString(),
      },
      ).toString();
    if (likeFilter) {
      searchURL += '&like_filter=true';
    }
    final request = context.read<CookieRequest>();
    final response = await request.get(searchURL);
    var data = response;
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
        _starCounts[d['pk']] = (await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_food_likes/${d['pk']}'))['count'];
      }
    }
    setState(() {
      _foodFuture = Future.value(listFood);
      _isListLoading = false;
    });
  }

  Future<void> _searchRestaurant(String name, String category) async {
    setState(() {
      _isListLoading = true;
    });
    var searchURL = Uri.https(
      'joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id',
      '/search/restaurant/',
      {
        'nama': name,
        'kategori': category,
      },
      ).toString();
    final request = context.read<CookieRequest>();
    final response = await request.get(searchURL);
    var data = response;
    List<Restaurant> listRestaurant = [];
    for (var d in data) {
      if (d != null) {
        listRestaurant.add(Restaurant.fromJson(d));
      }
    }
    setState(() {
      _restaurantFuture = Future.value(listRestaurant);
      _isListLoading = false;
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
    _totalRestaurants = listResto.length;
    return listResto;
  }

  Future<bool> updateLikes(String idMakanan) async {
    final request = context.read<CookieRequest>();
    final response = await request.post('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/toggle_like_json/', 
      jsonEncode(<String, String>{
          'food_id': idMakanan,
        }),
    );
    return response['status'] == 'success';
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
    double initialSize = 0.9;
    // Create temporary variables and ensure they're within bounds
    double tempMinPrice = min(max(_currentMinPrice, _minPrice), _maxPrice);
    double tempMaxPrice = min(max(_currentMaxPrice, _minPrice), _maxPrice);
    String? tempCategory = _selectedCategory;
    bool tempFavorited = _favoritedItems;
    
    if (_isFilterLoading) {
      // If filters are still loading, wait for them to complete first
      fetchFilterData(context.read<CookieRequest>()).then((_) {
        // Update the temporary values after filter data is loaded
        tempMinPrice = min(max(_currentMinPrice, _minPrice), _maxPrice);
        tempMaxPrice = min(max(_currentMaxPrice, _minPrice), _maxPrice);
        _showFilterSheet(initialSize, tempMinPrice, tempMaxPrice, tempCategory, tempFavorited);
      });
    } else {
      _showFilterSheet(initialSize, tempMinPrice, tempMaxPrice, tempCategory, tempFavorited);
    }
  }

  void _validateAndUpdatePrices(String value, bool isMin, StateSetter setModalState, double tempMinPrice, double tempMaxPrice) {
    double? newValue = double.tryParse(value);
    if (newValue == null) return;

    if (isMin) {
      if (newValue < _minPrice) {
        newValue = _minPrice;
      } else if (newValue > tempMaxPrice) {
        newValue = tempMaxPrice;
      }
      setModalState(() {
        tempMinPrice = newValue!;
        _minPriceController.text = newValue.toInt().toString();
      });
    } else {
      if (newValue > _maxPrice) {
        newValue = _maxPrice;
      } else if (newValue < tempMinPrice) {
        newValue = tempMinPrice;
      }
      setModalState(() {
        tempMaxPrice = newValue!;
        _maxPriceController.text = newValue.toInt().toString();
      });
    }
  }

  void _showFilterSheet(double initialSize, double tempMinPrice, double tempMaxPrice, String? tempCategory, bool tempFavorited) {
    final ScrollController modalScrollController = ScrollController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: initialSize,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController _) {
                return Column(
                  children: [
                    // Sticky Header
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: modalScrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_tabController.index == 0) ...[
                                const Text(
                                  'Harga',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RangeSlider(
                                  values: RangeValues(tempMinPrice, tempMaxPrice),
                                  min: _minPrice,
                                  max: _maxPrice,
                                  divisions: max(((_maxPrice - _minPrice) / 1000).round(), 1),
                                  labels: RangeLabels(
                                    _currencyFormat.format(tempMinPrice),
                                    _currencyFormat.format(tempMaxPrice),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setModalState(() {
                                      tempMinPrice = (values.start / 1000).round() * 1000;
                                      tempMaxPrice = (values.end / 1000).round() * 1000;
                                      
                                      _minPriceController.text = tempMinPrice.toInt().toString();
                                      _maxPriceController.text = tempMaxPrice.toInt().toString();
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
                                          labelText: 'Minimum',
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
                                          _validateAndUpdatePrices(value, true, setModalState, tempMinPrice, tempMaxPrice);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _maxPriceController,
                                        decoration: InputDecoration(
                                          labelText: 'Maksimum',
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
                                          _validateAndUpdatePrices(value, false, setModalState, tempMinPrice, tempMaxPrice);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                              const Text(
                                'Kategori',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  RadioListTile<String>(
                                    title: const Text('Semua'),
                                    value: "",
                                    groupValue: tempCategory,
                                    onChanged: (String? value) {
                                      setModalState(() {
                                        tempCategory = value;
                                      });
                                    },
                                  ),
                                  ..._categories!.map(
                                    (category) => RadioListTile<String>(
                                      title: Text(category),
                                      value: category,
                                      groupValue: tempCategory,
                                      onChanged: (String? value) {
                                        setModalState(() {
                                          tempCategory = value;
                                        }); 
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (_tabController.index == 0 && loggedIn) ...[
                                const SizedBox(height: 20),
                                const Text(
                                  'Item Favorit',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      tempFavorited = !tempFavorited;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: tempFavorited ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: tempFavorited 
                                          ? Theme.of(context).colorScheme.primary 
                                          : Colors.grey.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 20,
                                          color: tempFavorited 
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey.withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tampilkan Item Favorit Saja',
                                          style: TextStyle(
                                            color: tempFavorited 
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sticky Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle filter submission
                          setState(() {
                            _currentMinPrice = tempMinPrice;
                            _currentMaxPrice = tempMaxPrice;
                            _selectedCategory = tempCategory;
                            _favoritedItems = tempFavorited;
                          });
                          if (_tabController.index == 0) {
                            _searchFood(_searchController.text, tempCategory ?? "", tempMinPrice, tempMaxPrice, tempFavorited);
                          }
                          else {
                            _searchRestaurant(_searchController.text, tempCategory ?? "");
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
                          'Cari',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      modalScrollController.dispose();
    });
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
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                hintText: 'Cari...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: (value) {
                if (_tabController.index == 0) {
                  _searchFood(value, _selectedCategory ?? "", _currentMinPrice, _currentMaxPrice, _favoritedItems);
                }
                else {
                  _searchRestaurant(value, _selectedCategory ?? "");
                }
              },
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
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang!',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.restaurant_menu, size: 32),
                                      const SizedBox(height: 8),
                                      FutureBuilder(
                                        future: _foodFuture,
                                        builder: (context, snapshot) {
                                          return Text(
                                            _totalFoods.toString(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                      const Text('Makanan & Minuman'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.store, size: 32),
                                      const SizedBox(height: 8),
                                      FutureBuilder(
                                        future: _restaurantFuture,
                                        builder: (context, snapshot) {
                                          return Text(
                                            _totalRestaurants.toString(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                      const Text('Restoran'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Featured section
                        const Text(
                          'Banting Harga!',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder(
                          future: _foodFuture,
                          builder: (context, AsyncSnapshot<List<Food>> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            // Get all items with discount, sort by discount percentage, take top 3
                            var featuredItems = snapshot.data!
                                .where((item) => item.fields.diskon > 0)
                                .toList()
                              ..sort((a, b) => b.fields.diskon.compareTo(a.fields.diskon));
                            featuredItems = featuredItems.take(3).toList();

                            if (featuredItems.isEmpty) {
                              return const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Belum ada diskon untuk saat ini.',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return Column(
                              children: featuredItems.map((food) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    food.fields.nama,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Diskon ${food.fields.diskon}%!'),
                                  trailing: Text(
                                    formatPrice((food.fields.harga * (1 - food.fields.diskon / 100)).toInt()),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    height: 8,
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Makanan'),
                    Tab(text: 'Restoran'),
                  ],
                  indicatorWeight: 3,
                  dividerColor: Colors.grey[100],
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFoodList(),
            _buildRestaurantList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    if (_isListLoading) {
      return Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return FutureBuilder(
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
                    'Tidak ada item yang ditemukan!',
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
                                        decorationColor: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatPrice((snapshot.data![index].fields.harga * (1 - snapshot.data![index].fields.diskon / 100)).toInt()),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                                    Text(formatPrice(snapshot.data![index].fields.harga), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                _starredItems.contains(snapshot.data![index].pk) ? Icons.star : Icons.star_border,
                                color: _starredItems.contains(snapshot.data![index].pk) ? const Color.fromARGB(255, 245, 158, 11) : null,
                              ),
                              onPressed: () async {
                                if (!loggedIn) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Silahkan login untuk menambah item ini ke favorit!'),
                                    ),
                                  );
                                }
                                else {
                                  bool status = await updateLikes(snapshot.data![index].pk);
                                  if (status) {
                                    setState(() {
                                      if (_starredItems.contains(snapshot.data![index].pk)) {
                                        _starredItems.remove(snapshot.data![index].pk);
                                      } else {
                                        _starredItems.add(snapshot.data![index].pk);
                                      }
                                      _starCounts[snapshot.data![index].pk] = _starredItems.contains(snapshot.data![index].pk)
                                          ? (_starCounts[snapshot.data![index].pk] ?? 0) + 1
                                          : (_starCounts[snapshot.data![index].pk] ?? 1) - 1;
                                    });
                                  }
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
    );
  }

  Widget _buildRestaurantList() {
    if (_isListLoading) {
      return Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return FutureBuilder(
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
                    'Tidak ada restoran yang ditemukan!',
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}