import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/message.dart';
import '../../services/gemini_client.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_theme.dart';
import './widgets/chat_input_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/typing_indicator_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final GeminiClient _geminiClient;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String _currentStreamingMessage = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _setupAnimations();
    _addWelcomeMessage();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _initializeGemini() {
    try {
      final service = GeminiService();
      _geminiClient = GeminiClient(service.dio, service.authApiKey);
    } catch (e) {
      _showErrorDialog('Error de configuración',
          'No se pudo inicializar el servicio de IA. Verifica tu clave API.');
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(Message(
        role: 'model',
        content:
            '¡Hola! Soy Sphiny AI, tu asistente de inteligencia artificial. ¿En qué puedo ayudarte hoy?',
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = Message(role: 'user', content: text.trim());

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
      _currentStreamingMessage = '';
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Add empty assistant message for streaming
      final assistantMessage = Message(role: 'model', content: '');
      setState(() {
        _messages.add(assistantMessage);
      });

      String fullResponse = '';

      await for (final chunk in _geminiClient.streamChat(
        messages: _messages
            .where((m) => m.role != 'model' || m.textContent.isNotEmpty)
            .toList(),
        model: 'gemini-1.5-flash-002',
        maxTokens: 1024,
        temperature: 0.7,
      )) {
        fullResponse += chunk;
        setState(() {
          _currentStreamingMessage = fullResponse;
          // Update the last message
          if (_messages.isNotEmpty && _messages.last.role == 'model') {
            _messages[_messages.length - 1] = Message(
              role: 'model',
              content: fullResponse,
              timestamp: _messages.last.timestamp,
              id: _messages.last.id,
            );
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        // Remove the empty assistant message
        if (_messages.isNotEmpty &&
            _messages.last.role == 'model' &&
            _messages.last.textContent.isEmpty) {
          _messages.removeLast();
        }

        _messages.add(Message(
          role: 'model',
          content:
              'Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.',
        ));
      });

      if (e is GeminiException) {
        _showErrorDialog('Error de API', e.message);
      } else {
        _showErrorDialog(
            'Error', 'No se pudo procesar tu mensaje. Verifica tu conexión.');
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isTyping = false;
        _currentStreamingMessage = '';
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red[600],
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Limpiar conversación',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres borrar toda la conversación?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            child: Text(
              'Limpiar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryLight, AppTheme.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sphiny AI',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'Powered by Gemini',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: Icon(
              Icons.refresh,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return const TypingIndicatorWidget();
                  }

                  return MessageBubbleWidget(
                    message: _messages[index],
                    isStreaming: _isTyping && index == _messages.length - 1,
                  );
                },
              ),
            ),
            ChatInputWidget(
              controller: _messageController,
              onSend: _sendMessage,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
