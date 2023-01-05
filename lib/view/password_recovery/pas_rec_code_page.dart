import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../styles/app_colors.dart';
import '../../styles/button_styles.dart';
import '../../styles/text_styles.dart';

// Страница ввода кода для подтверждения email для восстановления пароля
class PasRecCodePage extends StatefulWidget {

  const PasRecCodePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PasRecCodePageState();
  }

}

class _PasRecCodePageState extends State<PasRecCodePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.passwordRecovery,
          style: TextStyles.headerStyle,
        ),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
      ),
      body: _pageBody(context),
      floatingActionButton: _nextButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _pageBody(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ввод кода
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: TextFormField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.number,
                // Дизайн поля ввода
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.code,
                    fillColor: AppColors.lightBlue
                ),
                // Проверка кода на правильность
                validator: (value) {
                  return (value != null && value.length != 6) ?
                  AppLocalizations.of(context)!.incorrectCode : null;
                },
                onChanged: (value) => setState(() {}),
                onEditingComplete: () {
                  // Удаление фокуса на поле ввода при завершении ввода, если
                  // формат данных правильный
                  if (_formKey.currentState!.validate()) {
                    FocusScopeNode focus = FocusScope.of(context);
                    if (!focus.hasPrimaryFocus) {
                      focus.unfocus();
                    }
                  }
                },
              ),
            ),
            // Отправка нового кода (раз в минуту)
            Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sendNewCode,
                    ),
                    Text('0:44'),
                  ],
                )
            )
          ],
        ));
  }

  // Кнопка перехода на страницу с вводом кода (по нажатию отправляется код)
  Widget _nextButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ButtonStyles.defaultButton,
          onPressed: () {
            Navigator.pushNamed(context, '/password_recovery/password');
          },
          child: Text(
              AppLocalizations.of(context)!.next
          ),
        )
    );
  }

}