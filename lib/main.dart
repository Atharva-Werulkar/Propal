import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:propal/pages/home_page.dart';
import 'package:propal/pages/login_page.dart';
import 'package:propal/pages/biometric_auth_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart';
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
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
