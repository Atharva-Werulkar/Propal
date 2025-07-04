import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../services/auth_service.dart';
import '../repos/chat_repo.dart';
import 'home_page.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Add a small delay before attempting biometric auth
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _attemptBiometricAuth();
      }
    });
  }

  Future<void> _attemptBiometricAuth() async {
    if (!mounted) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final success = await AuthService.login();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Authentication error: $e';
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _skipBiometric() async {
    // Disable biometric for this session and go to home
    final user = await SecureStorageService.getCurrentUser();
    if (user != null) {
      await AuthService.updateLastLogin(user);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              // App Logo
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset('assets/logo.png'),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Welcome Back!',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Please authenticate to continue',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 60),

              // Biometric Icon
              if (_isAuthenticating)
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Iconsax.finger_scan,
                        color: theme.colorScheme.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Touch the fingerprint sensor',
                      style: GoogleFonts.sourceCodePro(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    GestureDetector(
                      onTap: _attemptBiometricAuth,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _errorMessage.isNotEmpty
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _errorMessage.isNotEmpty
                              ? Iconsax.close_circle
                              : Iconsax.finger_scan,
                          color: _errorMessage.isNotEmpty
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sourceCodePro(
                              color: theme.colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _attemptBiometricAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: GoogleFonts.sourceCodePro(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Tap to authenticate',
                        style: GoogleFonts.sourceCodePro(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),

              const Spacer(),

              // Skip Button
              TextButton(
                onPressed: _skipBiometric,
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.sourceCodePro(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
