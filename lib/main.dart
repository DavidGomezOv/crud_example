import 'package:crud_example/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [
      const Locale("en", "US"),
      const Locale("es", "ES")
    ],
    title: "Main page",
    home: MainScreen(),
  ));
}
