import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_manager_arch/styles/text_styles.dart';


import '../styles/app_colors.dart';
import '../styles/button_styles.dart';

class StartPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _StartPageState();
  }

}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin{

  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    AnimationController controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this);
    animation = Tween<double>(begin: 2*pi, end: 0).animate(controller);

    animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _textColumn(context),
      floatingActionButton: _floatingButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

  }

  Widget _textColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text(
            AppLocalizations.of(context)!.welcome,
            style: TextStyles.headerStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          child: AnimatedSyncImage(animation: animation),
        ),
        Container(
          padding: const EdgeInsets.only(
              left: 20, right: 20,
              bottom: 5, top: 5),
          child: Text(
            AppLocalizations.of(context)!.signUpTip,
            style: TextStyles.defaultText,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _floatingButtons(BuildContext context) {
    EdgeInsetsGeometry buttonPadding = const EdgeInsets.only(
        left: 20, right: 20,
        bottom: 5, top: 5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                  padding: buttonPadding,
                  child: ElevatedButton(
                      style: ButtonStyles.defaultButton,
                      onPressed: () {
                        Navigator.pushNamed(context, '/registration');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                      )
                  ),
                ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
                  padding: buttonPadding,
                  child: ElevatedButton(
                      style: ButtonStyles.defaultButton,
                      onPressed: () {
                        Navigator.pushNamed(context, '/signIn');
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                            AppLocalizations.of(context)!.haveAccount,
                          textAlign: TextAlign.center,
                        ),
                      )
                  ),
                ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
                  padding: buttonPadding,
                  child: TextButton(
                      style: ButtonStyles.defaultTextButton,
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context)!.later)
                  ),
                ),
            )
          ],
        )
      ],
    );
  }


}

class AnimatedSyncImage extends AnimatedWidget {

  const AnimatedSyncImage({required Animation<double> animation}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(
      angle: animation.value,
      child: const Icon(
        Icons.sync,
        color: AppColors.lightBlue,
        size: 120
      ),
    );
  }


  
}