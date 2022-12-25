import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../helpers/string_helper.dart';
import '../styles/app_colors.dart';
import '../styles/text_styles.dart';

class SignInPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }

}

class _SignInPageState extends State<SignInPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageBody(context),
    );
  }

  Widget _pageBody(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.signIn,
          style: TextStyles.headerStyle),
        SvgPicture.asset(
            "assets/task.svg",
            color: AppColors.lightBlue),
        _form(context),
      ],
    );
  }

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
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.password,
                  fillColor: AppColors.lightBlue
              ),
              validator: (value) {},
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
          Padding( // Ввод пароля
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
                return (value != null && value == _controller1.text)
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



}