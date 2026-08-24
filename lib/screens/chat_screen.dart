import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiService _aiService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aiService = AiService(); // Initialize Service
    if (widget.initialMessage != null) {
      // Small delay to allow UI to build
      Future.delayed(const Duration(milliseconds: 500), () {
        _sendMessage(widget.initialMessage!);
      });
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

  Future<void> _sendMessage([String? initialText]) async {
    final text = initialText ?? _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      // AI message will be added when first chunk arrives
      _isLoading = true;
    });
    _scrollToBottom();

    String fullResponse = "";
    bool isFirstChunk = true;

    try {
      await for (final chunk in _aiService.sendMessageStream(text)) {
        fullResponse += chunk;
        if (mounted) {
          setState(() {
            if (isFirstChunk) {
              _isLoading = false;
              _messages.add({'role': 'ai', 'text': fullResponse});
              isFirstChunk = false;
            } else {
              _messages.last['text'] = fullResponse;
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
            if (isFirstChunk) {
               _isLoading = false;
               _messages.add({'role': 'ai', 'text': "Error: حدث خطأ في الاتصال"});
            } else {
               _messages.last['text'] = "Error: حدث خطأ في الاتصال";
            }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "المستشار الذكي", // Intelligent Adviser
          style: GoogleFonts.amiri(
            color: AppTheme.goldAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004D40), // Deep Emerald
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat List
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 64, color: AppTheme.goldAccent.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              "كيف يمكنني مساعدتك اليوم؟",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                            ),
                          ],
                        ).animate().fadeIn(duration: 800.ms),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                             // Loading Indicator
                             return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: const SizedBox(
                                    width: 40, 
                                    child: LinearProgressIndicator(color: AppTheme.goldAccent, backgroundColor: Colors.transparent)
                                  ),
                                ).animate().fadeIn(),
                             );
                          }

                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser 
                                    ? AppTheme.emeraldPrimary.withOpacity(0.8) 
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: isUser ? AppTheme.goldAccent.withOpacity(0.3) : Colors.white10,
                                ),
                              ),
                              child: isUser 
                                ? Text(
                                    msg['text']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                                  )
                                : MarkdownBody(
                                    data: msg['text']!,
                                    styleSheet: MarkdownStyleSheet(
                                      p: GoogleFonts.cairo(color: Colors.white, fontSize: 16, height: 1.5),
                                      h1: GoogleFonts.amiri(color: AppTheme.goldAccent, fontSize: 24, fontWeight: FontWeight.bold),
                                      h2: GoogleFonts.amiri(color: AppTheme.goldAccent, fontSize: 22, fontWeight: FontWeight.bold),
                                      h3: GoogleFonts.amiri(color: AppTheme.goldLight, fontSize: 20, fontWeight: FontWeight.bold),
                                      strong: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
                                      listBullet: const TextStyle(color: AppTheme.goldAccent),
                                      blockquote: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
                                      blockquoteDecoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: const Border(right: BorderSide(color: AppTheme.goldAccent, width: 4)), // Right side for RTL
                                      ),
                                    ),
                                  ),
                            ).animate().fadeIn().slideY(begin: 0.1, duration: 300.ms), 
                          );
                        },
                      ),
              ),

              // Output Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "اكتب سؤالك هنا...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.goldAccent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.black),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
