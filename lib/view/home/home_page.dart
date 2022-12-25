import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../styles/app_colors.dart';


class HomePage extends StatefulWidget {
  String _newTaskCategory = "no category";
  DateTime? _newTaskDate = null;
  TimeOfDay? _newTaskTime = null;

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
    List<String> categories = [];
    categories.addAll(Data.categories);
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
              onChanged: (value) => setDialogState(() {}),
              key: const Key("taskNameField"),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    // Список категорий
                    child: DropdownButton(
                      key: const Key("categoriesDropdownBtn"),
                      value: widget._newTaskCategory,
                      items: Data.categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                            value: value,
                            child: Text(value == "no category"
                                ? AppLocalizations.of(context)!.noCategory : value)
                        );
                      }).toList(),
                      onChanged: (String? value) =>
                          setDialogState(() => widget._newTaskCategory = value!),
                    ),
                  ),
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
                    style: textBtnStyle(),
                    onPressed: textController.text.isEmpty ? null : ()  {
                      String taskName = textController.text;
                      if (widget._newTaskDate == null) {
                        Data.addTask(taskName, widget._newTaskCategory, DateTime.now());
                      } else {
                        Data.addTaskWithDate(
                            taskName,
                            widget._newTaskCategory,
                            DateTime.now(),
                            widget._newTaskDate!,
                            widget._newTaskTime!,
                            widget._newTaskTime!.format(context)
                        );
                      }
                      _setHomePageState();
                      Navigator.pop(context);
                    },
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
                  stateText: widget._newTaskDate == null ?
                  AppLocalizations.of(context)!.noDate :
                  DateTimeFormatter.formatDate(
                      widget._newTaskDate!,
                      Localizations.localeOf(context).toString()
                  ),
                ),
                onTap: () async {
                  final date = await _pickDate();
                  if (date == null) return;
                  setDialogState(() {
                    widget._newTaskDate = date;
                  });
                },
              ),
              divider(),
              InkWell(
                onTap: widget._newTaskDate == null ?
                    () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pickDateFirst))):
                    () async {
                  final time = await _pickTime();
                  if (time == null) return;
                  setDialogState(() {
                    widget._newTaskTime = time;
                  });
                },
                child: _dialogBtn(
                  text: AppLocalizations.of(context)!.time,
                  icon: Icons.alarm,
                  stateText: widget._newTaskTime == null ?
                  AppLocalizations.of(context)!.no :
                  widget._newTaskTime!.format(context),
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
          style: textBtnStyle(),
          onPressed: () {
            widget._newTaskTime = null;
            widget._newTaskDate = null;
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        // Подтверждение выбора даты
        TextButton(
          style: textBtnStyle(),
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
              style: defaultTxt(),
            ),
          ),
        ),
        Text(
          stateText,
          style: stateTxt(),
        ),
      ],
    );
  }

  // Изменение состояния домашней страницы
  void _setHomePageState() {
    setState(() {});
  }



}