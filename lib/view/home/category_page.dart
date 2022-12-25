import 'package:flutter/cupertino.dart';
import 'package:task_manager/task_list_page.dart';

import 'categories_list.dart';
// Страница категории
class CategoryPage extends StatefulWidget {

  String _category = "no category";


  @override
  State<StatefulWidget> createState() {
    return _CategoryPageState();
  }

}

// Состояние страницы категории
class _CategoryPageState extends State<CategoryPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Список категорий
        SizedBox(
          width: double.infinity,
          height: 100,
          child: CategoriesList(
            selectedCategory: widget._category,
            onCategoryChanged: (String category) =>
                setState(() => widget._category = category),
            onCategoryDeleted: () => setState(() {
              widget._category = "no category";
            }),
          ),
        ),
        // Список задач выбранной категории
        Expanded(
            child: TaskListPage(widget._category)
        ),
      ],
    );
  }

}