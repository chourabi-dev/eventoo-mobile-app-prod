import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/discussion_model.dart';
import 'package:mobile/screens/chat_screen/chat_screen.dart';
import 'package:mobile/services/event_service.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({Key? key}) : super(key: key);

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  List<Discussion> discussions = [];
  List<Discussion> filteredDiscussions = [];

  final TextEditingController _searchController = TextEditingController();

  EventService eventService = EventService();
  bool loading = true;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    fetchChat();
    listenToChat();

  }

  @override
  void dispose() {
    _searchController.dispose(); 
     _chatSubscription?.cancel();
    super.dispose();
  }

  void fetchChat() {
    //setState(() => loading = true);

    eventService.fetchChats().then((res) {
      final dynamic body = jsonDecode(res.body);

      final list = (body['messages'] as List<dynamic>)
          .map<Discussion>((json) => Discussion.fromJson(json))
          .toList();

      setState(() {
        discussions = list;
        filteredDiscussions = list;
        loading = false;
      });
    }).catchError((err) {
      print(err);
      setState(() => loading = false);
    });
  }

void listenToChat() {
    _chatSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        fetchChat(); // trigger your in-app update
      } catch (e) {
        print("Error processing message: $e");
      }
    });
  }

  void _onSearchChanged(String value) {
    final query = value.toLowerCase().trim();

    setState(() {
      filteredDiscussions = discussions.where((d) {
        final fullName =
            '${d.firstname} ${d.lastname}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.chatsLabel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: l10n.searchParticipantsLabel,
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                // Discussions list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDiscussions.length,
                    itemBuilder: (context, index) {
                      return DiscussionTile(
                        discussion: filteredDiscussions[index],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class DiscussionTile extends StatelessWidget {
  final Discussion discussion;

  const DiscussionTile({Key? key, required this.discussion})
      : super(key: key);

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

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return days[date.weekday - 1];
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(participant: discussion.userId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(discussion.photoUrl),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${discussion.firstname} ${discussion.lastname}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: discussion.unreadCount != 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatMessengerDate(discussion.messageDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: discussion.unreadCount != 0
                              ? Colors.blue
                              : Colors.grey[600],
                          fontWeight: discussion.unreadCount != 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          discussion.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: discussion.unreadCount != 0
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: discussion.unreadCount != 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (discussion.unreadCount != null &&  discussion.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${discussion.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
