class Restaurant {
  final String name;
  final String description;
  final String category;
  double rating; 
  final List<String> foodItems; 

  Restaurant({
    required this.name,
    required this.description,
    required this.category,
    this.rating = 0.0,
    required this.foodItems,
  });

  void addRating(double newRating) {
    rating = (rating + newRating) / 2;
  }
}
