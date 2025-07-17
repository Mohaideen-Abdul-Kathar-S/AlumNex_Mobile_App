import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AlumnexIndividualChatScreen extends StatefulWidget {
  final dynamic sender;
  final dynamic reciever;

  const AlumnexIndividualChatScreen({
    super.key,
    required this.sender,
    required this.reciever,
  });

  @override
  State<AlumnexIndividualChatScreen> createState() =>
      _AlumnexIndividualChatScreenState();
}

class _AlumnexIndividualChatScreenState
    extends State<AlumnexIndividualChatScreen> {
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

final String apiUrl = 'http://192.168.157.76:5000';

@override
void initState() {
  super.initState();
  _loadMessages();
}

void _loadMessages() async {
  final uri = Uri.parse('$apiUrl/get_messages?user1=${widget.sender}&user2=${widget.reciever}');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      _messages = data.map((e) => {
        'sender': e['sender'],
        'text': e['text'],
        'timestamp': DateTime.parse(e['timestamp']),
      }).toList();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}

void _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final message = {
    'sender': widget.sender,
    'receiver': widget.reciever,
    'text': text,
  };

  final response = await http.post(
    Uri.parse('$apiUrl/send_message'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(message),
  );

  if (response.statusCode == 200) {
    setState(() {
      _messages.add({
        'sender': widget.sender,
        'text': text,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}


  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isSender = msg['sender'] == widget.sender;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSender ? accentColor : secondaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(isSender ? 14 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 14),
          ),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: accentColor,
              child: Text(
                widget.reciever.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reciever.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text("Online", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: secondaryColor,
              border: Border(top: BorderSide(color: accentColor, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Colors.white),
                    cursorColor: accentColor,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: accentColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


