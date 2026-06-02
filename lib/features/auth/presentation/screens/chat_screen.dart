import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String postId;

  const ChatScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF1E1E5F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navyBlue,
        title: const Text('Post Discussion', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Discussion for post: $postId',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const Text(
                    'Chat features coming soon!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chat integration placeholder',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}