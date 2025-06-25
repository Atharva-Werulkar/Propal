import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../repos/chat_repo.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  bool _loading = false;
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createAccount() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      await AuthService.createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profileImagePath: _profileImage?.path,
      );

      if (_biometricEnabled && _isBiometricAvailable) {
        await SecureStorageService.setBiometricEnabled(true);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating account: $e')),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1E29),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // App Logo/Title
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.code,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Propal',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI Coding Assistant',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Profile Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 3,
                    ),
                    color: const Color(0xFF242A38),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo,
                          color: Color(0xFF6366F1),
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add profile picture',
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 40),

              // Name Field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF242A38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  prefixIcon:
                      const Icon(Icons.person, color: Color(0xFF6366F1)),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF242A38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF6366F1)),
                ),
              ),

              const SizedBox(height: 20),

              // Biometric Toggle
              if (_isBiometricAvailable)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242A38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint, color: Color(0xFF6366F1)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Enable Biometric Authentication',
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Switch(
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                        },
                        activeColor: const Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 60),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Get Started',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
