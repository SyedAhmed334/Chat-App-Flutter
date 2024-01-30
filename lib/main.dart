import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/colors.dart';
import 'constants/routes.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterialColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 22,
              color: AppColors.primaryTextTextColor),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 40,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.6),
          displayMedium: TextStyle(
              fontSize: 32,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.6),
          displaySmall: TextStyle(
              fontSize: 28,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.9),
          headlineMedium: TextStyle(
              fontSize: 24,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.6),
          headlineSmall: TextStyle(
              fontSize: 20,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.6),
          titleLarge: TextStyle(
              fontSize: 17,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w700,
              height: 1.6),
          bodyLarge: TextStyle(
              fontSize: 17,
              color: AppColors.primaryTextTextColor,
              fontWeight: FontWeight.w500,
              height: 1.6),
          bodyMedium: TextStyle(
              fontSize: 14,
              color: AppColors.primaryTextTextColor,
              height: 1.6),
          bodySmall: TextStyle(
              fontSize: 12,
              color: AppColors.primaryTextTextColor,
              height: 2.26),
        ),
      ),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
