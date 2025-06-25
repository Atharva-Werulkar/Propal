import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:propal/pages/home_page.dart';
import 'package:propal/pages/login_page.dart';
import 'package:propal/pages/biometric_auth_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'repos/chat_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/creds/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.data == true) {
            // User exists, check if biometric is enabled
            return FutureBuilder<bool>(
              future: SecureStorageService.isBiometricEnabled(),
              builder: (context, biometricSnapshot) {
                if (biometricSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SplashScreen();
                }

                if (biometricSnapshot.data == true) {
                  // Biometric is enabled, show biometric auth page
                  return const BiometricAuthPage();
                } else {
                  // Biometric not enabled, go directly to home
                  return const HomePage();
                }
              },
            );
          } else {
            return const LoginPage();
          }
        },
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1E29),
        primaryColor: const Color(0xFF242A38),
        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1E29),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset('assets/logo.png'),
            ),
            const SizedBox(height: 24),
            Text(
              'Propal',
              style: GoogleFonts.sourceCodePro(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }
}
