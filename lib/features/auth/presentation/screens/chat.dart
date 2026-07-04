import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? options;

  ChatMessage({required this.text, this.isUser = false, this.options});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['response']['text'],
      isUser: false,
      options: json['response']['options'] != null
          ? List<String>.from(json['response']['options'])
          : null,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late Map<String, ChatMessage> botReplies;

  @override
  void initState() {
    super.initState();
    _loadBotReplies();
    // Start message
    // _messages.add(ChatMessage(
    //   text: "Hello! I am Swampurna, How can I help you?",
    //   options: ["Menstruation", "Pregnancy", "Nutrition", "Mental Health"],
    // ));
  }

  void _loadBotReplies() {
    const String jsonData = '''
    {
  "messages": [
    {
      "id": 0,
      "trigger": "start",
      "response": {
        "text": "Hello! I am Swampurna, How can I help you? Please type or select below options to get more details",
        "options": ["Menstruation", "Pregnancy", "Nutrition", "Mental Health"]
      }
    },
    {
      "id": 1,
      "trigger": "menstruation",
      "response": {
        "text": "Periods are natural. What do you want to know?",
        "options": ["Myths", "Health Tips", "Cycle Tracking"]
      }
    },
    {
      "id": 2,
      "trigger": "myths",
      "response": {
        "text": "Myth: You are impure during periods. Fact: False! You are completely normal.",
        "options": null
      }
    },
    {
      "id": 3,
      "trigger": "health tips",
      "response": {
        "text": "Eat iron-rich food, stay hydrated, and do light exercise.",
        "options": null
      }
    },
    {
      "id": 4,
      "trigger": "pregnancy",
      "response": {
        "text": "Pregnancy is a beautiful journey. Do you want info about diet or checkups?",
        "options": ["Diet", "Checkups"]
      }
    },
    {
      "id": 5,
      "trigger": "nutrition",
      "response": {
        "text": "Balanced diet is key. Do you want vegetarian or non-vegetarian tips?",
        "options": ["Vegetarian", "Non-Vegetarian"]
      }
    },
    {
      "id": 6,
      "trigger": "mental health",
      "response": {
        "text": "Mental health matters. Do you want stress management tips or counseling info?",
        "options": ["Stress Management", "Counseling"]
      }
    }
  ]
}
    ''';

    final data = jsonDecode(jsonData);
    final List messages = data['messages'];
    botReplies = {
      for (var msg in messages)
        msg['trigger'].toString().toLowerCase(): ChatMessage.fromJson(msg)
    };
    // 👇 Start message 
  final startMsg = messages.firstWhere((m) => m['trigger'] == 'start');
  _messages.add(ChatMessage.fromJson(startMsg));
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 1), () {
      _handleBotReply(text.toLowerCase());
    });
  }

  void _handleBotReply(String userInput) {
    ChatMessage? reply = botReplies[userInput];
    setState(() {
      _isTyping = false;
      if (reply != null) {
        _messages.add(reply);
      } else {
        _messages.add(ChatMessage(text: "Sorry, I didn’t understand. Try again."));
      }
    });
    _scrollToBottom();
  }

  void _onOptionSelected(String option) {
    setState(() {
      _messages.add(ChatMessage(text: option, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 1), () {
      _handleBotReply(option.toLowerCase());
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4F7C),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Blue banner with logo + text + cross button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/sp.png"),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),

                    // Text section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "I am Swampurna",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "A live chat interface that allows for seamless, natural communication and connection.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cross button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Chat list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!msg.isUser)
                          const CircleAvatar(
                            backgroundImage: AssetImage("assets/images/sp.png"),
                            radius: 20,
                          ),
                        Flexible(
                          child: Card(
                            color: msg.isUser ? Colors.blue : Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(msg.text),
                                  if (msg.options != null)
                                    Wrap(
                                      spacing: 8,
                                      children: msg.options!.map((opt) {
                                        return ElevatedButton(
                                          onPressed: () => _onOptionSelected(opt),
                                          child: Text(opt),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Divider between chat and input
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),

              // Input area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: const [
        CircleAvatar(
          backgroundImage: AssetImage("assets/images/sp.png"),
          radius: 20,
        ),
        SizedBox(width: 8),
        Card(
          color: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text("...", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Image.asset(
            "assets/images/imoji.png",   // apna emoji image yahan rakho
            width: 28,
            height: 28,
          ),
        ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Reply...",
                border: InputBorder.none,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
