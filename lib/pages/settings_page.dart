import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../repos/chat_repo.dart';
import '../models/user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _currentUser;
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkBiometricSettings();
  }

  Future<void> _loadUserData() async {
    final user = await SecureStorageService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _checkBiometricSettings() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    final isEnabled = await SecureStorageService.isBiometricEnabled();
    setState(() {
      _isBiometricAvailable = isAvailable;
      _biometricEnabled = isEnabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && _isBiometricAvailable) {
      // Test biometric authentication before enabling
      final success = await AuthService.authenticateWithBiometrics();
      if (success) {
        await SecureStorageService.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication enabled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      await SecureStorageService.setBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication disabled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 80,
    );

    if (pickedFile != null && _currentUser != null) {
      setState(() {
        _loading = true;
      });

      try {
        final updatedUser = _currentUser!.copyWith(
          profileImagePath: pickedFile.path,
        );
        await SecureStorageService.saveUser(updatedUser);
        setState(() {
          _currentUser = updatedUser;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile picture: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _clearChatHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242A38),
        title: Text(
          'Clear Chat History',
          style: GoogleFonts.sourceCodePro(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete all chat sessions? This action cannot be undone.',
          style: GoogleFonts.sourceCodePro(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.sourceCodePro(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Clear All',
              style: GoogleFonts.sourceCodePro(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorageService.saveChatSessions([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat history cleared'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1E29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A38),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.sourceCodePro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF242A38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6366F1),
                      backgroundImage: _currentUser?.profileImagePath != null
                          ? FileImage(File(_currentUser!.profileImagePath!))
                          : null,
                      child: _currentUser?.profileImagePath == null
                          ? Text(
                              _currentUser?.name
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _loading ? null : _updateProfilePicture,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF242A38), width: 2),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Iconsax.camera,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser?.name ?? 'User',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currentUser?.email ?? '',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security Section
          Text(
            'Security',
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF242A38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Iconsax.finger_scan,
                    color: _isBiometricAvailable
                        ? const Color(0xFF6366F1)
                        : Colors.grey,
                  ),
                  title: Text(
                    'Biometric Authentication',
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    _isBiometricAvailable
                        ? 'Use fingerprint or face unlock'
                        : 'Not available on this device',
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: _biometricEnabled && _isBiometricAvailable,
                    onChanged: _isBiometricAvailable ? _toggleBiometric : null,
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          Text(
            'Data',
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF242A38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Iconsax.trash, color: Colors.red),
                  title: Text(
                    'Clear Chat History',
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Delete all saved conversations',
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  onTap: _clearChatHistory,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
