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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          currentSession?.title ?? 'Propal',
          style: GoogleFonts.sourceCodePro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
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
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
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
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: _currentUser?.profileImagePath != null
                        ? FileImage(File(_currentUser!.profileImagePath!))
                        : null,
                    child: _currentUser?.profileImagePath == null
                        ? Text(
                            _currentUser?.name.substring(0, 1).toUpperCase() ??
                                'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _currentUser?.email ?? '',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor),

            // New Chat Button
            ListTile(
              leading:
                  Icon(Iconsax.add_circle, color: theme.colorScheme.primary),
              title: Text(
                'New Chat',
                style: GoogleFonts.sourceCodePro(
                    color: theme.colorScheme.onSurface),
              ),
              onTap: _startNewChat,
            ),

            Divider(color: theme.dividerColor),

            // Chat History
            Expanded(
              child: _chatSessions.isEmpty
                  ? Center(
                      child: Text(
                        'No chat history',
                        style: GoogleFonts.sourceCodePro(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
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
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              session.title,
                              style: GoogleFonts.sourceCodePro(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${session.messages.length} messages',
                              style: GoogleFonts.sourceCodePro(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => _loadChatSession(session.id),
                            trailing: IconButton(
                              icon: Icon(Iconsax.trash,
                                  size: 18, color: theme.colorScheme.error),
                              onPressed: () => _deleteChatSession(session.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Divider(color: theme.dividerColor),

            // Settings & Logout
            ListTile(
              leading: Icon(Iconsax.setting_2,
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
              title: Text(
                'Settings',
                style: GoogleFonts.sourceCodePro(
                    color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style:
                    GoogleFonts.sourceCodePro(color: theme.colorScheme.error),
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            height: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset('assets/logo.png'),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Propal',
            style: GoogleFonts.sourceCodePro(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your AI-powered coding assistant is ready to help!\nAsk me anything about programming, debugging, or code optimization.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: GoogleFonts.sourceCodePro(
            color: theme.colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
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
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
                maxLines: 3, // Limit max lines
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about coding...',
                  hintStyle: GoogleFonts.sourceCodePro(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _loading ? null : _sendMessage,
                icon: Icon(
                  Iconsax.send_2,
                  color: theme.colorScheme.onPrimary,
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
