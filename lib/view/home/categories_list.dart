import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../styles/app_colors.dart';
import '../../styles/button_styles.dart';
import '../../styles/text_styles.dart';

// Список категорий
class CategoriesList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CategoriesListState();
  }

}

// Состояние списка категорий
class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _addCategoryBtn(context);
          }
          return _buildCategory(context, "Nothing");
        }
    );
  }


  // Виджет категории
  Widget _buildCategory(BuildContext context, String category) {
    return InkResponse(
      // При удерживании появляется диалог действий с выбранной категорией
      onLongPress: (category == "no category") ? null : () => _showCategoryBottomSheet(category),
      child: Container(
        padding: const EdgeInsets.only(top: 50, left: 8, right: 8, bottom: 20),
        child: ElevatedButton(
            style: ButtonStyles.categoryButton,
            child: Text((category == "no category") ? AppLocalizations.of(context)!.all : category),
            onPressed: () {}
        ),
      ),
    );
  }

  // Диалог действий с выбранной категорией
  void _showCategoryBottomSheet(String category) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: 180,
            child: Container(
              child: _buildMenu(context, category),
            ),
          );
        }
    );
  }

  // Меню диалога действий с выбранной категорией
  Widget _buildMenu(BuildContext context, String category) {
    return Column(
      children: [
        // Редактирование категории
        ListTile(
          key: const Key("editCategoryBtn"),
          leading: Icon(
            Icons.edit,
            color: AppColors.lightBlue,
          ),
          title: Text(
            AppLocalizations.of(context)!.edit,
            style: TextStyles.defaultTextStyle,
          ),
          onTap: () {
            _showEditCategoryDialog(
              context,
              category,
              onClosed: () => Navigator.pop(context)
            );
          }
        ),
        // Удаление категории
        ListTile(
          key: const Key("deleteCategoryBtn"),
          leading: Icon(
            Icons.delete,
            color: AppColors.red,
          ),
          title: Text(
            AppLocalizations.of(context)!.delete,
            style: TextStyles.defaultTextStyle,
          ),
          onTap: () {
          },
        ),
      ],
    );
  }

  // Диалог редактирования категории
  void _showEditCategoryDialog(BuildContext context, String category, {required VoidCallback onClosed}) {
    TextEditingController textController = TextEditingController();
    textController.text = category;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.edit),
                  // Редактирование названия
                  content: TextFormField(
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)?.edit,
                      fillColor: AppColors.lightBlue,
                    ),
                    controller: textController,
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  actions: [
                    // Закрытие диалога
                    TextButton(
                      onPressed:() {},
                      child: Text(AppLocalizations.of(context)!.enter),
                    )
                  ],
                );
              }
          );}
    );
  }

  // Добавление категории
  Widget _addCategoryBtn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 8, right: 8, bottom: 20),
      child: ElevatedButton(
        key: const Key("addCategoryBtn"),
        style: ButtonStyles.categoryButton,
        onPressed: () => _showAddCategoryDialog(context),
        child: const Text("+"),
      ),
    );
  }

  // Диалог добавления категории
  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController textController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                // Ввод названия
                title: Text(AppLocalizations.of(context)!.newCategory),
                content: TextFormField(
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: AppLocalizations.of(context)?.newCategory,
                    fillColor: AppColors.lightBlue,
                  ),
                  controller: textController,
                  onChanged: (value) => setDialogState(() {}),
                  key: const Key("categoryNameField"),
                ),
                actions: [
                  // Закрытие диалога
                  TextButton(
                    onPressed: () {},
                    key: const Key("enterBtn"),
                    child: Text(AppLocalizations.of(context)!.enter),
                  )
                ],
              );
            }
        );}
    );
  }

  // Изменения состояния списка (для вызова из диалога)
  void _setPageState() {
    setState(() {});
  }

}