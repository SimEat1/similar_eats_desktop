class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final List<double> tasteVector; // [sweet, salty, sour, spicy, umami]
  final List<String> tags;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.tasteVector,
    required this.tags,
  }) : assert(tasteVector.length == 5);
}
