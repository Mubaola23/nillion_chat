import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nillion_chat/model/ai_message_response.dart';
import 'package:nillion_chat/model/message_model.dart';
import 'package:nillion_chat/service/nillion_api_service.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  final String _currentUser = 'User';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    // Add some sample messages for demonstration
    setState(() {
      _messages = [
        Message(
          id: '1',
          content: 'Welcome to Nillion Chat!',
          sender: 'System',
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        Message(
          id: '2',
          content:
              'Your messages are secured with Nillion\'s privacy technology.',
          sender: 'System',
          timestamp: DateTime.now().subtract(Duration(minutes: 4)),
        ),
      ];
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: messageContent,
      sender: _currentUser,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _isLoading = true;
    });

    _scrollToBottom();

    // Store message with Nillion if encryption is enabled

    final response = await NillionApiService.sendMessage(message.content);
    setState(() {
      _isLoading = false;
    });

    if (response == []) {
      _showSnackBar('Failed to  generate response', Colors.red);
    } else {
      // Simulate a response (in a real app, this would come from other users)
      _simulateResponse(response);
    }
  }

  void _simulateResponse(List<Choice> responses) {
    final response = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responses[DateTime.now().millisecond % responses.length]
          .message
          .content,
      sender: 'System',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(response);
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [SvgPicture.asset('assets/logo.svg', width: 100)]),
        backgroundColor: const Color.fromRGBO(0, 33, 245, 1.0),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.green[100],
            child: Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.green[700]),
                SizedBox(width: 8),
                Text(
                  'Messages are encrypted with Nillion',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSystem = message.sender == 'System';

                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isSystem
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      if (isSystem) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color.fromRGBO(0, 33, 245, 1.0),
                          child: Text(
                            message.sender[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],

                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSystem
                                ? Colors.grey[300]
                                : Color.fromRGBO(0, 33, 245, 1.0),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isSystem) ...[
                                Row(
                                  children: [
                                    Text(
                                      message.sender,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),

                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.lock,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isSystem
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSystem
                                      ? Colors.grey[600]
                                      : Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (!isSystem) ...[
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color.fromRGBO(0, 33, 245, 1.0),
                          child: Text(
                            message.sender[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Encrypting message...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: Color.fromRGBO(0, 33, 245, 1.0),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
