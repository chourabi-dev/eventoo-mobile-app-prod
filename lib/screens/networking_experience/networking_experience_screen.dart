import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/networking_experience/tabs/business_card.dart';
import 'package:mobile/screens/networking_experience/tabs/my_meetings_timeline.dart';
import 'package:mobile/screens/networking_experience/tabs/participants_tabs.dart';
import 'package:mobile/screens/networking_experience/tabs/requests_tab.dart';
import 'package:mobile/services/event_service.dart';

class NetworkingExperience extends StatefulWidget {
  const NetworkingExperience({super.key});

  @override
  State<NetworkingExperience> createState() => _NetworkingExperienceState();
}

class _NetworkingExperienceState extends State<NetworkingExperience> {

  List<Widget> _tabs = [
    NetworkingExperienceParticipantsTab(),
    MeetingsScreen(),
    NetworkingInvitationsTab(),
    BusinessCardExchangeTab()
  ];

  int countList = 0;
  int countBadgesList = 0;

  int _selectedIndex = 0;
  EventService eventService =EventService();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotificationBadge();
  }

void getNotificationBadge() {
  eventService.myInvitations().then((res) {
    final body = jsonDecode(res.body);

    final List receivedInvitations = body['receivedInvitations'] ?? [];

    final pendingInvitations = receivedInvitations
        .where((invitation) => invitation['status'] != 'accepted')
        .toList(); 
    setState(() {
      countList = pendingInvitations.length;
    });
  });

  
  eventService.myBusinessCardsInvitations().then((res) {
    final body = jsonDecode(res.body);

    final List receivedInvitations = body['receivedInvitations'] ?? [];

    final pendingInvitations = receivedInvitations
        .where((invitation) => invitation['status'] != 'accepted')
        .toList(); 
    setState(() {
      countBadgesList = pendingInvitations.length;
    });
  });

  
} 


BottomNavigationBarItem _navItem(
  IconData icon,
  String label,
  int index,
) {
  final isSelected = _selectedIndex == index;

  return BottomNavigationBarItem(
    label: label,
    icon: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      transform: Matrix4.translationValues(
        0,
        isSelected ? -4 : 0,
        0,
      )..scale(isSelected ? 1.15 : 1.0),
      child: Icon(icon),
    ),
  );
}



Widget buildBottomNav() {
  final l10n = AppLocalizations.of(context);
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (value) {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = value);
        },
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade500,
        items: [
          _navItem(Icons.share, l10n.homeLabel, 0),
          _navItem(Icons.calendar_month, l10n.myMeetings, 1),
          _navItemWithBadge(
            Icons.inbox,
            l10n.myInvitations,
            2,
            countList,
          ),
          _navItemWithBadge(
            Icons.contact_emergency,
            l10n.businessCardExchange,
            3,
            countBadgesList,
          ),
        ],
      ),
    ),
  );
}


BottomNavigationBarItem _navItemWithBadge(
  IconData icon,
  String label,
  int index,
  int count,
) {
  final isSelected = _selectedIndex == index;

  return BottomNavigationBarItem(
    label: label,
    icon: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(
            0,
            isSelected ? -4 : 0,
            0,
          )..scale(isSelected ? 1.15 : 1.0),
          child: Icon(icon),
        ),

        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}




  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _tabs.elementAt(_selectedIndex),
       bottomNavigationBar: buildBottomNav(),
    );
  }
}