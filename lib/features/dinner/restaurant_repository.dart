
class RestaurantLite {
  final String id;
  final String name;
  final String budget; // cheap | moderate | pricey
  final Set<String> cuisines; // e.g. american, steakhouse, mexican
  final Set<String> flavors; // e.g. savory, smoky, spicy
  final Set<String>
      categories; // e.g. steak, burgers, tacos, sushi, pizza, salad
  final Set<String> friesStyles; // e.g. crinkle, shoestring, waffle, skin-on
  final Set<String>
      supportsDiets; // e.g. vegan, vegetarian, halal, kosher, keto, paleo
  final Set<String>
      unsafeAllergens; // e.g. peanut, treenut, shellfish, egg, dairy, gluten, soy
  final Set<String> proteins; // e.g. beef, pork, chicken, fish, shellfish, lamb

  const RestaurantLite({
    required this.id,
    required this.name,
    required this.budget,
    required this.cuisines,
    required this.flavors,
    required this.categories,
    required this.friesStyles,
    required this.supportsDiets,
    required this.unsafeAllergens,
    required this.proteins,
  });
}

class RestaurantRepository {
  /// Swap this with Firestore/Places later.
  static List<RestaurantLite> demo() => const [
        RestaurantLite(
          id: "r-steak-1",
          name: "Steak Central",
          budget: "pricey",
          cuisines: {"american", "steakhouse"},
          flavors: {"savory", "smoky"},
          categories: {"steak", "fries", "salad"},
          friesStyles: {"skin-on"},
          supportsDiets: {"keto", "paleo"},
          unsafeAllergens: {"dairy", "gluten"},
          proteins: {"beef", "chicken"},
        ),
        RestaurantLite(
          id: "r-burger-1",
          name: "Patty Palace",
          budget: "cheap",
          cuisines: {"american", "burgers"},
          flavors: {"savory", "crispy"},
          categories: {"burgers", "fries", "salad"},
          friesStyles: {"crinkle", "shoestring"},
          supportsDiets: {"vegetarian"},
          unsafeAllergens: {"gluten"},
          proteins: {"beef", "chicken", "pork"},
        ),
        RestaurantLite(
          id: "r-mex-1",
          name: "Taqueria El Fuego",
          budget: "moderate",
          cuisines: {"mexican"},
          flavors: {"spicy", "savory", "tangy"},
          categories: {"tacos", "salad"},
          friesStyles: {},
          supportsDiets: {"gluten-free"},
          unsafeAllergens: {"dairy"},
          proteins: {"beef", "chicken", "fish"},
        ),
        RestaurantLite(
          id: "r-waffle-1",
          name: "Fry Factory",
          budget: "moderate",
          cuisines: {"american"},
          flavors: {"savory", "crispy"},
          categories: {"fries", "burgers"},
          friesStyles: {"waffle"},
          supportsDiets: {},
          unsafeAllergens: {"gluten"},
          proteins: {"beef", "chicken"},
        ),
      ];
}
