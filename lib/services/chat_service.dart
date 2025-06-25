import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../repos/chat_repo.dart';
import '../utils/constants.dart';

class ChatService {
  static const Uuid _uuid = Uuid();
  late GenerativeModel _model;
  PropalChatSession? _currentSession;

  ChatService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: api_key,
    );
  }

  // Create a new chat session
  Future<PropalChatSession> createNewSession({String? title}) async {
    final session = PropalChatSession(
      id: _uuid.v4(),
      title: title ?? 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentSession = session;
    await SecureStorageService.saveChatSession(session);
    return session;
  }

  // Load existing session
  Future<void> loadSession(String sessionId) async {
    final sessions = await SecureStorageService.getChatSessions();
    _currentSession = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
  }

  // Get current session
  PropalChatSession? get currentSession => _currentSession;

  // Send message and get response
  Future<ChatMessage> sendMessage(String content) async {
    if (_currentSession == null) {
      await createNewSession();
    }

    // Create user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message to session
    final updatedMessages = [..._currentSession!.messages, userMessage];
    _currentSession = _currentSession!.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    // Generate title if it's the first message
    String title = _currentSession!.title;
    if (_currentSession!.messages.length == 1 && title == 'New Chat') {
      title = _generateTitleFromMessage(content);
      _currentSession = _currentSession!.copyWith(title: title);
    }

    try {
      // Create chat context from previous messages
      final chat = _model.startChat(
        history: _buildChatHistory(
            _currentSession!.messages.where((m) => !m.isFromUser).toList()),
      );

      // Send message and get response
      final response = await chat.sendMessage(Content.text(content));

      if (response.text != null) {
        // Create AI response message
        final aiMessage = ChatMessage(
          id: _uuid.v4(),
          content: response.text!,
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        // Add AI message to session
        final finalMessages = [...updatedMessages, aiMessage];
        _currentSession = _currentSession!.copyWith(
          messages: finalMessages,
          updatedAt: DateTime.now(),
        );

        // Save session
        await SecureStorageService.saveChatSession(_currentSession!);

        return aiMessage;
      } else {
        throw Exception('No response from AI');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Build chat history for the AI model
  List<Content> _buildChatHistory(List<ChatMessage> messages) {
    return messages.map((message) {
      return Content(
        message.isFromUser ? 'user' : 'model',
        [TextPart(message.content)],
      );
    }).toList();
  }

  // Generate title from first message
  String _generateTitleFromMessage(String message) {
    if (message.length <= 30) return message;
    return '${message.substring(0, 30)}...';
  }

  // Get all chat sessions
  Future<List<PropalChatSession>> getAllSessions() async {
    final sessions = await SecureStorageService.getChatSessions();
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  // Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    await SecureStorageService.deleteChatSession(sessionId);
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
  }

  // Clear current session (start fresh)
  void clearCurrentSession() {
    _currentSession = null;
  }
}
