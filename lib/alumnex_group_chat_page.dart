import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlumnexGroupChatPage extends StatefulWidget {
  final dynamic sender;
  final dynamic groupid;

  const AlumnexGroupChatPage({
    super.key,
    required this.sender,
    required this.groupid,
  });

  @override
  State<AlumnexGroupChatPage> createState() => _AlumnexGroupChatPageState();
}

class _AlumnexGroupChatPageState extends State<AlumnexGroupChatPage> {
  final Color primaryColor = const Color(0xFF1565C0); // Bright blue
  final Color accentColor = const Color(0xFFFF7043); // Vivid orange
  final Color secondaryColor = const Color(0xFFEEEEEE); // Light gray

  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [
   
  ];

late final Timer _timer;

@override
void initState() {
  super.initState();
  _loadMessages();
  _timer = Timer.periodic(Duration(seconds: 5), (timer) => _loadMessages());
}

@override
void dispose() {
  _timer.cancel();
  super.dispose();
}

void _loadMessages() async {
  try {
    final fetchedMessages = await _fetchMessages();
    setState(() {
      messages = fetchedMessages;
    });
  } catch (e) {
    print("Error loading messages: $e");
  }
}

  Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isNotEmpty) {
    await http.post(
      Uri.parse('http://10.149.248.153:5000/send_group_message'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "group_id": widget.groupid,
        "sender": widget.sender,
        "message": text,
      }),
    );

    setState(() {
      messages.add({'sender': widget.sender, 'text': text});
      _messageController.clear();
    });
  }
}

Future<List<Map<String, dynamic>>> _fetchMessages() async {
  final response = await http.get(
    Uri.parse('http://10.149.248.153:5000/get_group_messages/${widget.groupid}'),
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((msg) => {
      'sender': msg['sender'],
      'text': msg['message'],
    }).toList();
  } else {
    throw Exception("Failed to load messages");
  }
}


  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['sender'] == widget.sender;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message['sender'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Group Chat", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: accentColor,
                    radius: 22,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
