import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/string_helper.dart';
import '../../styles/app_colors.dart';
import '../../styles/button_styles.dart';
import '../../styles/text_styles.dart';

// Страница с вводом email для восстановления пароля
class PasRecEmailPage extends StatefulWidget {
  const PasRecEmailPage({super.key});


  @override
  State<StatefulWidget> createState() {
    return _PasRecEmailPageState();
  }

}

class _PasRecEmailPageState extends State<PasRecEmailPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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

  // Тело страницы
  Widget _pageBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ввод email
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              autofocus: true,
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              // Дизайн поля ввода
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)!.email,
                fillColor: AppColors.lightBlue,
              ),
              // Проверка введенного email на правильный формат
              validator: (String? value) {
                return (value != null && !StringHelper.isValidEmail(value)) ?
                AppLocalizations.of(context)!.incorrectEmail : null;
              },
              onChanged: (value) => setState(() {}),
              // Удаление фокуса на поле ввода при завершении ввода, если
              // формат данных правильный
              onEditingComplete: () {
                if (_formKey.currentState!.validate()) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                }
              },
            ),
          ),
          // Подсказка
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Text(
              AppLocalizations.of(context)!.verifyEmailForRecovery,
            ),
          )
        ],
      ),
    );
  }

  // Кнопка перехода на страницу с вводом кода (по нажатию отправляется код)
  Widget _nextButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ButtonStyles.defaultButton,
          onPressed:
          StringHelper.isValidEmail(_controller.text) ?
              () => Navigator.pushNamed(context, '/password_recovery/code') : null,
          child: Text(
              AppLocalizations.of(context)!.next
          ),
        )
    );
  }

}