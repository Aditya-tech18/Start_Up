// File: lib/ai_chat_screen.dart (FIXED VERSION - LaTeX Rendering + Auto-scroll)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'question_screen.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatScreen extends StatefulWidget {
  final PyqQuestion question;
  const AiChatScreen({super.key, required this.question});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // 🔑 Supabase Configuration
  static const String _supabaseFunctionUrl = 'https://pgvymttdvdlkcroqxsgn.supabase.co/functions/v1/ask-gemini';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBndnltdHRkdmRsa2Nyb3F4c2duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzOTEwMzMsImV4cCI6MjA3NDk2NzAzM30.lAaQEs2Mk6BGjIcP8zLkqkFxUDIKyDIT-9kTK5kPnq8';

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: "Hello! I'm here to help you understand this question. What's your doubt?",
        isUserMessage: false,
      ),
    );
    // Initial scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUserMessage: true));
      _isLoading = true;
    });

    _scrollToBottom();

    final optionsList = widget.question.options.entries
        .map((entry) => '(${entry.key}) ${entry.value}')
        .toList();

    try {
      final response = await http.post(
        Uri.parse(_supabaseFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode({
          'userPrompt': userMessage,
          'conversationHistory': _messages
              .where((m) => m != _messages.first)
              .map((msg) => {
                    'role': msg.isUserMessage ? 'user' : 'assistant',
                    'content': msg.text,
                  })
              .toList(),
          'questionText': widget.question.text,
          'options': optionsList,
          'correctAnswer': widget.question.correctAnswer,
          'solution': widget.question.solution,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final aiResponse = responseBody['reply'] as String? ??
            'Sorry, I received an empty response.';

        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUserMessage: false));
        });
        _scrollToBottom();
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Sorry, I couldn't process your request. Please try again.",
              isUserMessage: false,
            ),
          );
        });
        _scrollToBottom();
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "I'm having trouble connecting. Please check your internet and try again.",
            isUserMessage: false,
          ),
        );
      });
      _scrollToBottom();
      debugPrint('Exception in _sendMessage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Build text with LaTeX rendering - FIXED VERSION
  Widget _buildLatexText(String text, {double fontSize = 15, Color? color}) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = color ?? Colors.white;
    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    // First, handle block math ($$...$$)
    final blockMathRegex = RegExp(r'\$\$(.+?)\$\$', dotAll: true);
    final blockMatches = blockMathRegex.allMatches(text).toList();

    // Store positions of block math to avoid treating them as inline
    final Set<int> blockMathPositions = {};
    for (var match in blockMatches) {
      for (int i = match.start; i < match.end; i++) {
        blockMathPositions.add(i);
      }
    }

    while (currentIndex < text.length) {
      // Check if we're at the start of a block math
      bool foundBlockMath = false;
      for (var match in blockMatches) {
        if (currentIndex == match.start) {
          foundBlockMath = true;
          String mathContent = match.group(1)!.trim();

          // Clean up the LaTeX
          mathContent = mathContent.replaceAll('\\\\', '\\');

          try {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Math.tex(
                    mathContent,
                    textStyle: TextStyle(
                      fontSize: fontSize + 2,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            spans.add(
              TextSpan(
                text: '[Math Error: ${match.group(1)}]',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
            debugPrint('Block LaTeX Error: $e\nContent: ${match.group(1)}');
          }

          currentIndex = match.end;
          break;
        }
      }

      if (foundBlockMath) continue;

      // Look for inline math ($...$)
      int nextDollar = -1;
      for (int i = currentIndex; i < text.length; i++) {
        if (text[i] == '\$' && !blockMathPositions.contains(i)) {
          nextDollar = i;
          break;
        }
      }

      if (nextDollar == -1) {
        // No more math, add remaining text
        if (currentIndex < text.length) {
          spans.add(
            TextSpan(
              text: text.substring(currentIndex),
              style: TextStyle(fontSize: fontSize, color: textColor),
            ),
          );
        }
        break;
      }

      // Add text before the math
      if (nextDollar > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, nextDollar),
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        );
      }

      // Find closing dollar sign
      int closingDollar = -1;
      for (int i = nextDollar + 1; i < text.length; i++) {
        if (text[i] == '\$' && !blockMathPositions.contains(i)) {
          closingDollar = i;
          break;
        }
      }

      if (closingDollar == -1) {
        // No closing dollar, treat as regular text
        spans.add(
          TextSpan(
            text: text.substring(nextDollar),
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        );
        break;
      }

      // Extract and render inline math
      String mathContent = text.substring(nextDollar + 1, closingDollar).trim();

      if (mathContent.isNotEmpty) {
        mathContent = mathContent.replaceAll('\\\\', '\\');

        try {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                mathContent,
                textStyle: TextStyle(fontSize: fontSize, color: textColor),
              ),
            ),
          );
        } catch (e) {
          spans.add(
            TextSpan(
              text: '[$mathContent]',
              style: TextStyle(
                fontSize: fontSize - 2,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
          debugPrint('Inline LaTeX Error: $e\nContent: $mathContent');
        }
      }

      currentIndex = closingDollar + 1;
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: TextStyle(fontSize: fontSize, color: textColor),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PARTH is thinking...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARTH - Your AI Tutor'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing indicator
                if (index == _messages.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTypingIndicator(),
                  );
                }

                final message = _messages[index];
                final isUser = message.isUserMessage;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildLatexText(
                      message.text,
                      fontSize: 15,
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask a follow-up question...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _isLoading ? null : _sendMessage,
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _isLoading
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}