import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../styles/app_colors.dart';
import '../../styles/button_styles.dart';
import '../../styles/text_styles.dart';

class CodePage extends StatefulWidget {

  const CodePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CodePageState();
  }

}

class _CodePageState extends State<CodePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();

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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.code,
                  fillColor: AppColors.lightBlue
              ),
              validator: (value) {
                return (value != null && value.length != 6) ?
                        AppLocalizations.of(context)!.incorrectCode : null;
              },
              onChanged: (value) => setState(() {}),
              onEditingComplete: () {
                if (_formKey.currentState!.validate()) {
                  FocusScopeNode focus = FocusScope.of(context);
                  if (!focus.hasPrimaryFocus) {
                    focus.unfocus();
                  }
                }
              },
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
                  Text('0:44'),
                ],
              )
          )
        ],
      ));
  }

  Widget _nextButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ButtonStyles.defaultButton,
          onPressed: () {
            Navigator.pushNamed(context, '/password');
          },
          child: Text(
              AppLocalizations.of(context)!.next
          ),
        )
    );
  }

}