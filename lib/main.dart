import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:propal/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1E29),
        primaryColor: const Color(0xFF242A38),
        textTheme: GoogleFonts.sourceCodeProTextTheme(),
        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
      ),
    );
  }
}
