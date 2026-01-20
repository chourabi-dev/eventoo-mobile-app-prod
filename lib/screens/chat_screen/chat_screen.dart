import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/config.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/user_avatar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

/// ----------------------------
/// MODELS
/// ----------------------------

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; 
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.type
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['senderId'].toString(),
      receiverId: json['receiverId'].toString(),
      content: json['content'] ?? '',
      type: json['type'] ?? '', 
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// ----------------------------
/// MAIN SCREEN
/// ----------------------------

class ChatScreen extends StatefulWidget {
  final int participant;

  const ChatScreen({super.key, required this.participant});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const _storage = FlutterSecureStorage();
  final ServiceEnv _env = ServiceEnv(); 
  final List<ChatMessage> _messages = []; 
  late IO.Socket _socket;
  bool _isLoading = true;
  bool _isConnected = false;
  EventService eventService = EventService();

  String? _currentUserId;

  dynamic targetDATA;

  StreamSubscription<RemoteMessage>? _chatSubscription;
 

  @override
  void initState() {
    super.initState();
    _getConnectedParticipantID();

    _fetchMessages();
    _initSocket();
    listenToChat();
  }

  @override
  void dispose() {
    _socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  /// ----------------------------
  /// API FETCH
  /// ----------------------------
  /// 
  /// 
  
  Future<void> _getConnectedParticipantID() async{
    String? me = await _storage.read(key: 'participantId'); 
    _currentUserId = me;
  }

  Future<void> _fetchMessages() async {
    String? token = await _storage.read(key: 'token');
    String? me = await _storage.read(key: 'participantId'); 

    print("token");
    print(token);

    try {
      final res = await http.get(
        Uri.parse('${_env.endpoint}/api/messaging/fetch/${_currentUserId!}/target/${widget.participant}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',

        },
      );

      final body = jsonDecode(res.body);

      print(body);

      final List data = body['data'] ?? [];
      final dynamic participantDATA = body['targetData'] ?? null;
      
      setState(() {
        targetDATA = participantDATA;
      });

      _messages
        ..clear()
        ..addAll(data.map((e) => ChatMessage.fromJson(e)));
    } catch (e) {
      debugPrint(e.toString() );
      debugPrint('Fetch messages error: $e');
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  /// ----------------------------
  /// SOCKET.IO
  /// ----------------------------

  void _initSocket() {
    _socket = IO.io(
      _env.endpoint,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      }
    );

    _socket.connect();

    _socket.onConnect((_) { 

      setState(() => _isConnected = true);
      _socket.emit('join_private_chat', {
        'user_id': _currentUserId,
        'peer_id': widget.participant,
      });
    });

    _socket.on('new_message', (data) {
      print("NEW MESSAGE");
      print(data);

      final msg = ChatMessage.fromJson(data);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });

    _socket.onDisconnect((_) {
      setState(() => _isConnected = false);
    });

    /* _socket.onConnectError((err) {
        debugPrint('❌ CONNECT ERROR: $err');
      });

    _socket.onError((err) {
      debugPrint('❌ ERROR: $err');
    });*/

  }

  /// ----------------------------
  /// SEND MESSAGE
  /// ----------------------------
  

  void _sendMessage() {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final tempId = DateTime.now().millisecondsSinceEpoch.toString();

  final optimisticMessage = ChatMessage(
    id: tempId,
    senderId: _currentUserId!,
    receiverId: widget.participant.toString(),
    content: text,
    type: "text",
    createdAt: DateTime.now(),
  );

  // 1️⃣ Optimistically add message to UI
  setState(() {
    _messages.add(optimisticMessage);
  });

  _messageController.clear();
  _scrollToBottom();

  // 2️⃣ Emit socket event
  final payload = {
    'sender_id': _currentUserId,
    'receiver_id': widget.participant,
    'content': text,
  };

  _socket.emit('send_message', payload);

  // 3️⃣ Persist message to server
  eventService
      .sendDirectMessage(widget.participant, text)
      .then((res) {
    final body = jsonDecode(res.body);

    if (body['success'] == false) {
      // ❌ Rollback: remove last inserted message
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'] ?? "Message not sent"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }).catchError((e) {
    // ❌ Network / server error → rollback
    setState(() {
      _messages.removeWhere((m) => m.id == tempId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message not sent :("),
        duration: Duration(seconds: 2),
      ),
    );

    debugPrint("Send message error: $e");
  });
}


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

 void listenToChat() {
    _chatSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        _fetchMessages(); // trigger your in-app update
      } catch (e) {
        print("Error processing message: $e");
      }
    });
  }

  /// ----------------------------
  /// UI
  /// ----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.mainBackgroundColor,
      foregroundColor: Colors.black,
      title:
      targetDATA != null?
       Row(
        children: [
          UserAvatar(fullName: targetDATA['fullname'] ?? "...", imageUrl: targetDATA['photoURL'],),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( targetDATA['fullname'] ?? "..." ,
                  style: const TextStyle(fontSize: 15)),
              /*Text(
                _isConnected ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 11,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
              ),*/
            ],
          ),
        ],
      ): Container(child: Text("..."),)
    );
  }

  String formatMessengerDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final isSameDay =
        now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;

    if (isSameDay) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    /*if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return days[date.weekday - 1];
    }*/

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
  

  Widget _buildMessages() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == _currentUserId;

        print( msg.senderId);
        print( _currentUserId);
        

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
           
            constraints:  BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .7),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [

                  // time

                  Container(child: Text(formatMessengerDate(msg.createdAt)),   ),
 
                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                  color: isMe ? Color.fromRGBO(235, 255, 233, 1) : Color.fromRGBO(238, 237, 235, 1),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color:  Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
 
            child: Text(
              msg.content,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),




              ],
            ),
          )
        );
      },
    );
  }

  Widget _buildInput() {
    final l10n = AppLocalizations.of(context);


    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      margin: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
              hintText: l10n.typeAMessage,
              filled: false,
              fillColor: const Color(0xFFF1F2F6),

              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),

            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration:  BoxDecoration(
                color: Colors.green.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
