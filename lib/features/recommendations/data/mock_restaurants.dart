import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';

class MockRestaurants {
  static List<Restaurant> get all => [
    Restaurant(
      id: "r1",
      name: "Bangkok Spice",
      cuisine: "Thai",
      tasteVector: [1.5, 2.0, 1.2, 4.6, 2.2],
      tags: ["thai","curry","basil","spicy","noodles"],
    ),
    Restaurant(
      id: "r2",
      name: "Sweet Cravings Bakery",
      cuisine: "Bakery",
      tasteVector: [4.8, 0.8, 0.5, 0.1, 1.0],
      tags: ["cakes","cookies","pastry","sweet"],
    ),
    Restaurant(
      id: "r3",
      name: "Umami House Ramen",
      cuisine: "Japanese",
      tasteVector: [1.2, 2.4, 0.8, 1.2, 4.6],
      tags: ["ramen","broth","umami","pork","noodles"],
    ),
    Restaurant(
      id: "r4",
      name: "La Taquería El Fuego",
      cuisine: "Mexican",
      tasteVector: [1.6, 2.2, 1.2, 4.2, 2.0],
      tags: ["tacos","al pastor","salsa","spicy","cilantro","lime"],
    ),
    Restaurant(
      id: "r5",
      name: "Lemon Grove",
      cuisine: "Mediterranean",
      tasteVector: [1.0, 2.2, 4.4, 0.8, 2.2],
      tags: ["lemon","olive oil","grill","sour","fresh"],
    ),
    Restaurant(
      id: "r6",
      name: "Salt & Smoke",
      cuisine: "BBQ",
      tasteVector: [1.2, 4.2, 0.6, 2.0, 3.2],
      tags: ["bbq","ribs","brisket","smoky","savory"],
    ),
    Restaurant(
      id: "r7",
      name: "Crispy Wok",
      cuisine: "Chinese",
      tasteVector: [2.2, 2.6, 1.2, 2.4, 3.0],
      tags: ["stir-fry","crispy","garlic","ginger"],
    ),
    Restaurant(
      id: "r8",
      name: "Dolce Vita Gelato",
      cuisine: "Italian Desserts",
      tasteVector: [4.6, 0.6, 0.4, 0.1, 1.2],
      tags: ["gelato","sweet","dessert","creamy"],
    ),
    Restaurant(
      id: "r9",
      name: "Pho Real",
      cuisine: "Vietnamese",
      tasteVector: [1.2, 2.2, 1.0, 1.4, 4.2],
      tags: ["pho","herbs","broth","umami","fresh"],
    ),
    Restaurant(
      id: "r10",
      name: "Citrus & Co.",
      cuisine: "Modern",
      tasteVector: [1.0, 1.8, 4.8, 0.4, 1.8],
      tags: ["citrus","bright","salads","sour"],
    ),
  ];
}

