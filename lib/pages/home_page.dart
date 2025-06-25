import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/messagecard.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/chat_model.dart';
import '../repos/chat_repo.dart';
import 'login_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ChatService _chatService;
  User? _currentUser;
  List<PropalChatSession> _chatSessions = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadUserData();
    _loadChatSessions();
  }

  Future<void> _loadUserData() async {
    final user = await SecureStorageService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadChatSessions() async {
    final sessions = await _chatService.getAllSessions();
    setState(() {
      _chatSessions = sessions;
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _startNewChat() async {
    await _chatService.createNewSession();
    await _loadChatSessions();
    setState(() {});
    Navigator.pop(context); // Close drawer
  }

  Future<void> _loadChatSession(String sessionId) async {
    await _chatService.loadSession(sessionId);
    setState(() {});
    Navigator.pop(context); // Close drawer
  }

  Future<void> _deleteChatSession(String sessionId) async {
    await _chatService.deleteSession(sessionId);
    await _loadChatSessions();
    setState(() {});
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = _chatService.currentSession;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1E29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A38),
        elevation: 0,
        title: Text(
          currentSession?.title ?? 'Propal',
          style: GoogleFonts.sourceCodePro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Iconsax.menu_1, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (currentSession != null)
            IconButton(
              icon: const Icon(Iconsax.add, size: 24),
              onPressed: _startNewChat,
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child:
                  currentSession != null && currentSession.messages.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: currentSession.messages.length,
                          itemBuilder: (context, index) {
                            final message = currentSession.messages[index];
                            return MessageWidget(
                              text: message.content,
                              isFromUser: message.isFromUser,
                            );
                          },
                        )
                      : _buildWelcomeScreen(),
            ),

            // Loading indicator
            if (_loading)
              Container(
                padding: const EdgeInsets.all(16),
                child:
                    Lottie.asset('assets/loader.json', height: 60, width: 60),
              ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF242A38),
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF6366F1),
                    backgroundImage: _currentUser?.profileImagePath != null
                        ? FileImage(File(_currentUser!.profileImagePath!))
                        : null,
                    child: _currentUser?.profileImagePath == null
                        ? Text(
                            _currentUser?.name.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser?.name ?? 'User',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 18,
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

            const Divider(color: Colors.white24),

            // New Chat Button
            ListTile(
              leading: const Icon(Iconsax.add_circle, color: Color(0xFF6366F1)),
              title: Text(
                'New Chat',
                style: GoogleFonts.sourceCodePro(color: Colors.white),
              ),
              onTap: _startNewChat,
            ),

            const Divider(color: Colors.white24),

            // Chat History
            Expanded(
              child: _chatSessions.isEmpty
                  ? Center(
                      child: Text(
                        'No chat history',
                        style: GoogleFonts.sourceCodePro(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        final isSelected =
                            _chatService.currentSession?.id == session.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              session.title,
                              style: GoogleFonts.sourceCodePro(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${session.messages.length} messages',
                              style: GoogleFonts.sourceCodePro(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => _loadChatSession(session.id),
                            trailing: IconButton(
                              icon: const Icon(Iconsax.trash,
                                  size: 18, color: Colors.red),
                              onPressed: () => _deleteChatSession(session.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(color: Colors.white24),

            // Settings & Logout
            ListTile(
              leading: const Icon(Iconsax.setting_2, color: Colors.white70),
              title: Text(
                'Settings',
                style: GoogleFonts.sourceCodePro(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.sourceCodePro(color: Colors.red),
              ),
              onTap: _logout,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
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
          const SizedBox(height: 32),
          Text(
            'Welcome to Propal',
            style: GoogleFonts.sourceCodePro(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your AI-powered coding assistant is ready to help!\nAsk me anything about programming, debugging, or code optimization.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSuggestionChip('Debug my code'),
              _buildSuggestionChip('Explain this algorithm'),
              _buildSuggestionChip('Optimize performance'),
              _buildSuggestionChip('Code review'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF242A38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: GoogleFonts.sourceCodePro(
            color: const Color(0xFF6366F1),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xFF242A38),
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        maxHeight: 120, // Limit max height to prevent overflow
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFieldFocus,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 16,
                ),
                maxLines: 3, // Limit max lines
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about coding...',
                  hintStyle: GoogleFonts.sourceCodePro(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1E29),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _loading ? null : _sendMessage,
                icon: const Icon(
                  Iconsax.send_2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _loading) return;

    setState(() {
      _loading = true;
    });

    _textController.clear();
    _textFieldFocus.unfocus();

    try {
      await _chatService.sendMessage(message);
      await _loadChatSessions(); // Refresh sessions list
      setState(() {});
      _scrollDown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }
}
