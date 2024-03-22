class FoodItem {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  FoodItem({required this.name, required this.calories, required this.protein, required this.carbs, required this.fats});
}

class ListItem {
  final String name;
  final String description;

  ListItem({required this.name, required this.description});
}

class ListGroup {
  final String title;
  final List<ListItem> items;

  ListGroup({required this.title, required this.items});
}