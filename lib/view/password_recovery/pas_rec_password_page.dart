import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/string_helper.dart';
import '../../styles/app_colors.dart';
import '../../styles/button_styles.dart';
import '../../styles/text_styles.dart';

class PasRecPasswordPage extends StatefulWidget {

  const PasRecPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PasRecPasswordPageState();
  }

}

class _PasRecPasswordPageState extends State<PasRecPasswordPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

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
          Padding( // Ввод пароля
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              controller: _controller1,
              autofocus: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.newPassword,
                  fillColor: AppColors.lightBlue
              ),
              validator: (value) {
                if (value == null) {
                  return null;
                }
                if (!StringHelper.isValidPassword(value)) {

                  if (!StringHelper.containsLetter(value)) {
                    return AppLocalizations.of(context)!.atLeastOneLetter;
                  }
                  if (value.length < 8 || value.length > 32) {
                    return AppLocalizations.of(context)!.passwordLengthError;
                  }
                  return AppLocalizations.of(context)!.incorrectPasswordFormat;
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
              onEditingComplete: () {
                if (_formKey.currentState!.validate()) {
                  FocusScopeNode focusScope = FocusScope.of(context);
                  if (!focusScope.hasPrimaryFocus) {
                    focusScope.nextFocus();
                  }
                }
              },
            ),
          ),
          Padding( // Повторить пароль
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              autofocus: true,
              controller: _controller2,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.repeatPassword,
                  fillColor: AppColors.lightBlue
              ),
              validator: (value) {
                return (value != null && value != "" && value != _controller1.text)
                    ? AppLocalizations.of(context)!.passwordsDontMatch : null;
              },
              onChanged: (value) => setState(() {}),
              onEditingComplete: () {
                if (!_formKey.currentState!.validate()) {
                  FocusScopeNode focus = FocusScope.of(context);
                  if (!focus.hasPrimaryFocus) {
                    focus.unfocus();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Кнопка перехода на следующую страницу
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