import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_manager_arch/styles/button_styles.dart';

import '../../styles/app_colors.dart';
import '../../styles/text_styles.dart';
import 'category_page.dart';


class HomePage extends StatefulWidget {

  HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}


class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoryPage(),
      floatingActionButton: FloatingActionButton(
        key: const Key("addTaskBtn"),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return addTaskDialog();
            }
        ),
        backgroundColor: AppColors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }


  Widget addTaskDialog() {
    TextEditingController textController = TextEditingController();
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            // Ввод названия задачи
            content: TextFormField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)?.createTask,
                fillColor: AppColors.lightBlue,
              ),
              controller: textController,
              // Изменение состояния диалога после изменения вводимого текста
              // onChanged: (value) => setDialogState(() {}),
              key: const Key("taskNameField"),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Список категорий
                  // Container(
                  //   padding: const EdgeInsets.only(left: 15),
                  //   child: DropdownButton(
                  //     key: const Key("categoriesDropdownBtn"),
                  //     value: widget._newTaskCategory,
                  //     items: Data.categories.map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem(
                  //           value: value,
                  //           child: Text(value == "no category"
                  //               ? AppLocalizations.of(context)!.noCategory : value)
                  //       );
                  //     }).toList(),
                  //     onChanged: (String? value) =>
                  //         setDialogState(() => widget._newTaskCategory = value!),
                  //   ),
                  // ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.lightBlue,
                    ),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return dateTimeDialog();
                        }
                    ),
                  ),
                  // Закрытие диалога и добавление задачи (с проверкой на пустой ввод)
                  TextButton(
                    style: ButtonStyles.dialogButton,
                    onPressed: () {},
                    key: const Key("enterBtn"),
                    child: Text(AppLocalizations.of(context)!.enter),
                  ),
                ],
              )
            ],
          );
        }
    );
  }

  Widget dateTimeDialog() {
    return AlertDialog(
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              InkWell(
                child: _dialogBtn(
                  text: AppLocalizations.of(context)!.date,
                  icon: Icons.calendar_today,
                  // Выбранная дата или надпись "нет даты"
                  stateText: "No date",
                  // stateText: widget._newTaskDate == null ?
                  // AppLocalizations.of(context)!.noDate :
                  // DateTimeFormatter.formatDate(
                  //     widget._newTaskDate!,
                  //     Localizations.localeOf(context).toString()
                  // ),
                ),
                onTap: () async {
                  // Выбор даты
                  final date = await _pickDate();
                  if (date == null) return;

                  // setDialogState(() {
                  //   widget._newTaskDate = date;
                  // });
                },
              ),
              divider(),
              InkWell(
                // Выбор времени
                onTap: () async {
                  final time = await _pickTime();
                  if (time == null) return;

                },
                child: _dialogBtn(
                  text: AppLocalizations.of(context)!.time,
                  icon: Icons.alarm,
                  // Выбранное время или надпись "без времени"
                  stateText: "No date"
                  // stateText: widget._newTaskTime == null ?
                  // AppLocalizations.of(context)!.no :
                  // widget._newTaskTime!.format(context),
                ),
              ),
              divider(),
              _dialogBtn(
                  text: AppLocalizations.of(context)!.repeate,
                  icon: Icons.repeat_rounded,
                  stateText: "No"
              ),
              divider(),
            ],
          );
        },
      ),
      actions: [
        // Отмена выбора даты
        TextButton(
          style: ButtonStyles.defaultButton,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        // Подтверждение выбора даты
        TextButton(
          style: ButtonStyles.defaultButton,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.enter),
        ),
      ],
    );
  }

  // Выбор даты
  Future<DateTime?> _pickDate() => showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),

  );

  // Выбор времени
  Future<TimeOfDay?> _pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );



  Widget _dialogBtn({required String text, required IconData icon, required String stateText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.lightBlue,
          size: 30,
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(
              text,
              style: TextStyles.defaultTextStyle,
            ),
          ),
        ),
        Text(
          stateText,
          style: TextStyles.pickedDataTextStyle,
        ),
      ],
    );
  }

  // Изменение состояния домашней страницы
  void _setHomePageState() {
    setState(() {});
  }

  // Разделитель
  Widget divider() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Divider(
          thickness: 1,
          endIndent: 0,
          color: AppColors.lightGray,
        )
    );
  }

}