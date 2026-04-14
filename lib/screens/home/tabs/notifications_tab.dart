import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/notifications_model.dart';
import 'package:mobile/services/event_service.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {

  static const Color mainBackgroundColor = Color.fromRGBO(235, 232, 222, 1);
  static const Color primaryColor = Color.fromRGBO(199, 18, 94, 1);

  List<NotificationItem> notifications = [];
  EventService _eventService = EventService();
  bool loading = true;

  void _markAsSeen(int id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          seen: true,
          date: notifications[index].date,
        );
      }
    });

    // SEND API TO SERVER
    _eventService.updateNotification(id).then((res){

    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();

  }



  void getNotifications(){
    _eventService.getNotifications().then((res){

      dynamic body = jsonDecode(res.body);

      final List<NotificationItem> tmp = (body['notifications'] as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList();
          
     

      setState(() {
        loading = false;
        notifications = tmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    final unseenCount = notifications.where((n) => !n.seen).length;

    return Scaffold(
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unseenCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$unseenCount ${l10n.newLabel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: 
      
          loading == true ?

          Center(
            child: CircularProgressIndicator(),
          )
          :
      
          notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noNotificationsYet,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.seen ? Colors.white : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.seen
              ? Colors.grey.shade200
              : const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsSeen(notification.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.seen
                        ? Icons.notifications_outlined
                        : Icons.notifications_active,
                    color: const Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.seen
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.seen)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6C63FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
