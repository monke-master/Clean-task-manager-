import 'package:flutter/cupertino.dart';

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
            ),
          ),
        // Список задач выбранной категории
        // Expanded(
        //     child: TaskListPage(widget._category)
      ],
    );
  }

}