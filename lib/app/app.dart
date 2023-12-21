import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injazathr/app/appLocalization.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/appLocalizationCubit.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/cubits/internetConnectivityCubit.dart';
import 'package:injazathr/data/models/hive/face_data.dart';
import 'package:injazathr/data/repositories/authRepository.dart';
import 'package:injazathr/locator.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/utils/appLanguages.dart';
import 'package:injazathr/utils/hiveBoxKeys.dart';
import 'package:injazathr/utils/localdb.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injazathr/data/repositories/settingsRepository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> initializeApp() async {
  setupServices();
  WidgetsFlutterBinding.ensureInitialized();

  //Register the license of font
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await Hive.initFlutter();

  await Hive.openBox(authBoxKey);
  await Hive.openBox(settingsBoxKey);
  await Hive.openBox(mainUrlBoxKey);
  await HiveBoxes.initialize();

  configLoading();

  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 50.0
    ..radius = 0.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.blue
    ..textColor = Colors.black
    ..maskType = EasyLoadingMaskType.none
    ..userInteractions = false
    ..dismissOnTap = false;
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //preloading some of the images
    precacheImage(
        AssetImage(UiUtils.getImagePath("upper_pattern.png")), context);

    precacheImage(
        AssetImage(UiUtils.getImagePath("lower_pattern.png")), context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<InternetConnectivityCubit>(
            create: (_) => InternetConnectivityCubit()),
        BlocProvider<AppLocalizationCubit>(
            create: (_) => AppLocalizationCubit(SettingsRepository())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
      ],
      child: Builder(builder: (context) {
        final currentLanguage =
            context.watch<AppLocalizationCubit>().state.language;
        return MaterialApp(
          /*   theme: ThemeData(
            canvasColor: const Color.fromRGBO(255, 255, 255, 1),
            fontFamily: 'GoogleSans',
            primarySwatch: Colors.blue,
          ),*/

          theme: Theme.of(context).copyWith(
              textTheme:
                  GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              scaffoldBackgroundColor: pageBackgroundColor,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    onPrimary: onPrimaryColor,
                    secondary: secondaryColor,
                    background: backgroundColor,
                    error: errorColor,
                    onSecondary: onSecondaryColor,
                    onBackground: onBackgroundColor,
                  )),
          builder: (context, widget) {
            // do your initialization here
            widget = ScrollConfiguration(
                behavior: GlobalScrollBehavior(), child: widget!);
            widget = EasyLoading.init()(context, widget);
            return widget;
          },
          locale: currentLanguage,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appLanguages.map((language) {
            return UiUtils.getLocaleFromLanguageCode(language.languageCode);
          }).toList(),
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splash,
          onGenerateRoute: Routes.onGenerateRouted,
        );
      }),
    );
  }
}
