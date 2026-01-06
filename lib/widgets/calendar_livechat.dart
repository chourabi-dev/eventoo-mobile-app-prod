import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/config.dart';
import 'package:mobile/services/event_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatMessage {
  final String id;
  final String userName;
  final String userLabel;
  final String avatarUrl;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.userName,
    required this.userLabel,
    required this.avatarUrl,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      userName: json['userName'],
      userLabel: json['userLabel'],
      avatarUrl: json['avatarUrl'] ?? '',
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['isMe'] == true,
    );
  }
}

class CalendarLiveChat extends StatefulWidget {
  final int programID;

  const CalendarLiveChat({super.key, required this.programID});

  @override
  State<CalendarLiveChat> createState() => _CalendarLiveChatState();
}

class _CalendarLiveChatState extends State<CalendarLiveChat> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _messageIdCounter = 0; 
  EventService _eventService = EventService(); 
  late IO.Socket socket; 
  dynamic userInfo;
  AuthService authService =AuthService();

  @override
  void initState() {
    super.initState(); 
    fetchDATA();
    initSocket();


  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


    void fetchDATA() {

      _eventService.getEventProfileDATA().then((res){
        dynamic body = jsonDecode(res.body);

        print(body);
        setState(() {
          userInfo = body['data'];
        });

      });

      

      _eventService.fetchMessagesProgramRoom(widget.programID).then((response) {
        final res = jsonDecode(response.body);

        final List<ChatMessage> demoMessages =
            (res['chat'] as List)
                .map((e) => ChatMessage.fromJson(e))
                .toList();

        setState(() {
          _messages.clear(); // optional
          _messages.addAll(demoMessages);
        });

        _scrollToBottom();
      }).catchError((err) {
        print(err);
      });
    }


void initSocket() { 
  ServiceEnv tmp = ServiceEnv();
  
  socket = IO.io(
    '${tmp.endpoint}',
    <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }
  );

  socket.connect();

  socket.onConnect((_) {
    print('✅ Socket connected');
    print('Connected? ${socket.connected}'); // true
    socket.emit('joined_room_program', widget.programID);
  });

  socket.on('newMessage', (_) {
    print('📩 New message event');
    fetchDATA();
  });
  
}




  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    String message =_messageController.text.trim();

    final newMessage = ChatMessage(
      id: '${_messageIdCounter++}',
      userName: userInfo['fullName'] ?? 'You',
      userLabel: userInfo['profileLabel'] ?? 'You',
      avatarUrl: userInfo['photoUrl'] ?? 'You',
      message: message,
      timestamp: DateTime.now(),
      isMe: true,
    );


    // SEND MESSAGE TO SERVER
    print("SENDING MESSAGE TO ROOM N°");
    print(widget.programID);
    
    _eventService.sendRoomProgramChatMessage(widget.programID,  message ).then((res){
      print(res.body);
    });

    setState(() {
      _messages.add(newMessage);
      // Keep only last 15 messages
      if (_messages.length > 15) {
        _messages.removeAt(0);
      }
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);



    return Container(
      //margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.95),
            const Color(0xFF16213e).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5848E8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.liveChat ,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                     l10n.joinTheConversation ,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_messages.length} msgs',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 48,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noMessagesyet,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                         
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(_messages[index]);
                    },
                  ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 63, 63, 63).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: const Color.fromARGB(255, 64, 64, 64).withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    
                    child: TextField(
                      
                      controller: _messageController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5848E8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: message.isMe 
                    ? const Color(0xFF6C63FF) 
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (message.isMe 
                      ? const Color(0xFF6C63FF) 
                      : Colors.white).withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                message.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF6C63FF),
                    child: Center(
                      child: Text(
                        message.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.userName,
                      style: TextStyle(
                        color: message.isMe 
                            ? const Color(0xFF6C63FF) 
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: message.isMe
                            ? const Color(0xFF6C63FF).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.userLabel,
                        style: TextStyle(
                          color: message.isMe
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFF6C63FF).withOpacity(0.15)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: message.isMe
                          ? const Color(0xFF6C63FF).withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      height: 1.4,
                    ),
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