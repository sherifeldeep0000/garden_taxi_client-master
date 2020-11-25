import 'dart:io';

//import 'package:device_preview/device_preview.dart';
import 'package:my_cab/helper_providers/client_providers/client_info_provider.dart';
import 'package:my_cab/helper_providers/maps/destination_info.dart';
import 'package:my_cab/helper_providers/maps/my_location_info.dart';
import 'package:my_cab/modules/auth/login_screen.dart';
import 'package:my_cab/modules/home/requset_view.dart';
import 'package:my_cab/modules/splash/language_screen.dart';
import 'package:provider/provider.dart';

import 'Language/appLocalizations.dart';
import 'constance/constance.dart' as constance;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/modules/home/home_screen.dart';
import 'package:my_cab/modules/splash/SplashScreen.dart';
import 'package:my_cab/modules/splash/introductionScreen.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:my_cab/constance/routes.dart';

import 'helper_providers/maps/directionStorage.dart';
import 'modules/home/insideAndOutSide.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(new MyApp()));
}

// void main() => runApp(
//       DevicePreview(
//         builder: (context) => MyApp(),
//       ),
//     );

class MyApp extends StatefulWidget {
  static changeTheme(BuildContext context) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.changeTheme();
  }

  static setCustomeLanguage(BuildContext context, String languageCode) {
    final _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLanguage(languageCode);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = new UniqueKey();

  void changeTheme() {
    this.setState(() {
      globals.isLight = !globals.isLight;
    });
  }

  String locale = "en";
  setLanguage(String languageCode) {
    setState(() {
      locale = languageCode;
      constance.locale = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    constance.locale = locale;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black26,
      statusBarIconBrightness:
          globals.isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: CoustomTheme.getThemeData().cardColor,
      systemNavigationBarDividerColor:
          CoustomTheme.getThemeData().disabledColor,
      systemNavigationBarIconBrightness:
          globals.isLight ? Brightness.dark : Brightness.light,
    ));
    return Container(
      key: key,
      color: CoustomTheme.getThemeData().backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CoustomTheme.getThemeData().backgroundColor,
              CoustomTheme.getThemeData().backgroundColor,
              CoustomTheme.getThemeData().backgroundColor.withOpacity(0.8),
              CoustomTheme.getThemeData().backgroundColor.withOpacity(0.7)
            ],
          ),
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MyLocationInfo(),
            ),
            ChangeNotifierProvider(
              create: (context) => DstinationInfo(),
            ),
            ChangeNotifierProvider(
              create: (context) => DirectionStorage(),
            ),
            ChangeNotifierProvider(
              create: (context) => ClientInfoProvider(),
            ),
          ],
          child: MaterialApp(
            //builder: DevicePreview.appBuilder,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'), // English
              const Locale('fr'), // French
              const Locale('ar'), // Arabic
            ],
            debugShowCheckedModeBanner: false,
            title: AppLocalizations.of('My Cab'),
            routes: routes,
            //home: HomeScreen(),
            theme: CoustomTheme.getThemeData(),
            builder: (BuildContext context, Widget child) {
              return Builder(
                builder: (BuildContext context) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: child,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  var routes = <String, WidgetBuilder>{
    Routes.SPLASH: (BuildContext context) => SplashScreen(),
    Routes.INTRODUCTION: (BuildContext context) => IntroductionScreen(),
    Routes.HOME: (BuildContext context) => HomeScreen(),
    Routes.Languages: (context) => LanguageScreen(),
    Routes.SelectDistrict: (context) => InsideAndOutSide(),
  };
}
