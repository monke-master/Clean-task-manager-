import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localstore/localstore.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_manager_arch/view/app_route_builder.dart';
import 'package:task_manager_arch/view/code_page.dart';
import 'package:task_manager_arch/view/registration_page.dart';
import 'package:task_manager_arch/view/start_page.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', '')
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) => onGenerateRoute(settings),
    );
  }

  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/registration':
        return AppRouteBuilder.defaultRouteBuilder(RegistrationPage());
      case '/code':
        return AppRouteBuilder.defaultRouteBuilder(CodePage());
      default:
        return AppRouteBuilder.defaultRouteBuilder(StartPage());
    }
  }
}



