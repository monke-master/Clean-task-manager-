class Category {

  String categoryId;
  String userId;
  String title;
  DateTime creationDate;

  Category({required this.categoryId, required this.userId, required this.title,
            required this.creationDate});

  @override
  int get hashCode => Object.hash(categoryId, userId, title, creationDate);

  @override
  bool operator == (Object other) =>
          other is Category &&
          other.categoryId == categoryId &&
          other.userId == userId &&
          other.title == title &&
          other.creationDate == creationDate;



}