import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../styles/app_colors.dart';
import '../styles/button_styles.dart';
import '../styles/text_styles.dart';

class CodePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CodePageState();
  }

}

class _CodePageState extends State<CodePage> {

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
                    labelText: AppLocalizations.of(context)!.code,
                  fillColor: AppColors.lightBlue
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.sendNewCode,
                  ),
                  Text(
                      '0:44'
                  ),
                ],
              )
          )
        ],
      ),
      floatingActionButton: Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ButtonStyles.defaultButton,
            onPressed: () {},
            child: Text(
                AppLocalizations.of(context)!.next
            ),
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}