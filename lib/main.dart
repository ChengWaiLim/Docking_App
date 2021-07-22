import 'package:docking_project/Util/Config.dart';
import 'package:docking_project/Util/FlutterRouter.dart';
import 'package:docking_project/Util/Request.dart';
import 'package:docking_project/Util/UtilExtendsion.dart';
import 'package:docking_project/pages/FirstPage.dart';
import 'package:docking_project/pages/MainPage.dart';
import 'package:docking_project/pages/SplashPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_basecomponent/Util.dart';

Future<void> main() async {
  FlutterRouter.initialize();
  Request.initialize(Config.baseURL);
  FlutterRouter().configureRoutes();
  WidgetsFlutterBinding.ensureInitialized();
  Util.sharedPreferences = await SharedPreferences.getInstance();
  // await Request().renewToken();
  if(Util.sharedPreferences.getString("Authorization") != null && Util.sharedPreferences.getString("Authorization").isNotEmpty)
    await UtilExtendsion.initDriver();
  
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('zh', 'HK')
      ],
      path: 'assets/translations', 
      fallbackLocale: Locale('zh', 'HK'),
      child: RouterPage()));
}

class RouterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1)),
      builder: (context, AsyncSnapshot snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
              title: 'Docking',
              theme: ThemeData(
                primaryColor: UtilExtendsion.mainColor,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: snapshot.connectionState == ConnectionState.waiting? SplashPage() : (Util.sharedPreferences.getString("Authorization") != "" && Util.sharedPreferences.getString("Authorization") != null)? MainPage(): FirstPage(),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              onGenerateRoute: FlutterRouter().fluroRouter.generator);
      },
    );
  }
}
