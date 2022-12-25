import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_manager_arch/styles/app_colors.dart';
import 'package:task_manager_arch/styles/button_styles.dart';

import '../../helpers/string_helper.dart';
import '../../styles/text_styles.dart';

class EmailPage extends StatefulWidget {

  const EmailPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EmailPageState();
  }

}

class _EmailPageState extends State<EmailPage> {

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
          AppLocalizations.of(context)!.registration,
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
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              autofocus: true,
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)!.email,
                fillColor: AppColors.lightBlue,
              ),
              validator: (String? value) {
                return (value != null && !StringHelper.isValidEmail(value)) ?
                        AppLocalizations.of(context)!.incorrectEmail : null;
              },
              onChanged: (value) => setState(() {}),
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
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Text(
              AppLocalizations.of(context)!.weWillSendCode,
            ),
          )

        ],
      ),
    );
  }
  
  Widget _nextButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ButtonStyles.defaultButton,
          onPressed:
            StringHelper.isValidEmail(_controller.text) ?
                () => Navigator.pushNamed(context, '/code') : null,
          child: Text(
              AppLocalizations.of(context)!.next
          ),
        )
    );
  }



}