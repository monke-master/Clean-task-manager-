import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../helpers/string_helper.dart';
import '../styles/app_colors.dart';
import '../styles/button_styles.dart';
import '../styles/text_styles.dart';

class SignInPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }

}

class _SignInPageState extends State<SignInPage> {

  // Ключ для получения состояния формы с данными уз
  final _formKey = GlobalKey<FormState>();
  // Контроллеры для получения вводимых данных
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageBody(context),
      floatingActionButton: _nextButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _pageBody(BuildContext context) {
    return Column(
      children: [
        Padding(  // Заголовок
          padding: const EdgeInsets.only(top: 60),
          child: Text(
              AppLocalizations.of(context)!.signIn,
              style: TextStyles.headerStyle),
        ),
        const Icon( // Логотип
          Icons.account_box,
          color: AppColors.lightBlue,
          size: 170,
        ),
        _form(context),
        _forgotPasswordHint(context),
      ],
    );
  }

  // Форма ввода данных
  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding( // Ввод email
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              controller: _controller1,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              // Дизайн поля ввода
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.email,
                  fillColor: AppColors.lightBlue
              ),
              validator: (value) {
                // Проверка email на правильный формат
                return (value != null && !StringHelper.isValidEmail(value)) ?
                        AppLocalizations.of(context)!.incorrectEmail : null;
              },
              onChanged: (value) => setState(() {}),
              onEditingComplete: () {
                // Удаление фокуса на поле ввода при завершении ввода, если
                // формат данных правильный
                if (_formKey.currentState!.validate()) {
                  FocusScopeNode focusScope = FocusScope.of(context);
                  if (!focusScope.hasPrimaryFocus) {
                    focusScope.nextFocus();
                  }
                }
              },
            ),
          ),
          Padding( // Ввод пароля
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              autofocus: true,
              controller: _controller2,
              keyboardType: TextInputType.visiblePassword,
              // Дизайн поля ввода
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.repeatPassword,
                  fillColor: AppColors.lightBlue
              ),
              onChanged: (value) => setState(() {}),
              onEditingComplete: () {
                // Удаление фокуса на поле ввода при завершении ввода
                FocusScopeNode focus = FocusScope.of(context);
                if (!focus.hasPrimaryFocus) {
                  focus.unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgotPasswordHint(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(top: 10, left: 20),
        child: InkWell(
          child: Text(
            AppLocalizations.of(context)!.forgotPassword,
            style: TextStyles.hintText,
            textAlign: TextAlign.start,
          ),
          onTap: () {},
        )
    );
  }

  // Кнопка перехода на главную страницу (с проверкой подлиннсоти данных)
  Widget _nextButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          style: ButtonStyles.defaultButton,
          child: Text(
              AppLocalizations.of(context)!.next
          ),
          onPressed: () {} // _controller1.text == _controller2.text ? () =>
      ),
    );
  }



}