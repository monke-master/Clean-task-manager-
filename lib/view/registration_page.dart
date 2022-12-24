import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_manager_arch/styles/app_colors.dart';
import 'package:task_manager_arch/styles/button_styles.dart';

import '../styles/text_styles.dart';

class RegistrationPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }

}

class _RegistrationPageState extends State<RegistrationPage> {

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.email,
                  fillColor: AppColors.lightBlue,
              ),
              validator: (String? value) {

                return (value.ma)
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
      floatingActionButton: Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ButtonStyles.defaultButton,
            child: Text(
                AppLocalizations.of(context)!.next
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/code');
            },
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}