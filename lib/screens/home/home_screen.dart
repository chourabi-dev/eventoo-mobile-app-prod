import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/badge_display_screen/badge_display_screen.dart';
import 'package:mobile/screens/home/tabs/home_tab.dart';
import 'package:mobile/screens/home/tabs/notifications_tab.dart';
import 'package:mobile/screens/home/tabs/profile_tab.dart';
import 'package:mobile/screens/home/tabs/search_tab.dart';
import 'package:mobile/screens/qr_scanner_screen/qr_scanner_screen.dart';
import 'package:mobile/services/event_service.dart';
// import 'package:mobile/screens/badge/badge_display_screen.dart';


import 'dart:ui';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final String eventName;

  const HomeScreen({super.key, required this.eventName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedIndex = 0;
  EventService _eventService = EventService();
  dynamic _event = null;
  Map<String, dynamic>? _badgeSettings;
  Map<String, dynamic>? _userData;
  bool _loadingBadgeData = false;
  int notifications = 0;
  

  List<Widget> _tabs = [
    HomeTab(),
    SearchTab(),
    NotificationsTab(),
    ProfileTab()
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controller.forward();
    _loadBadgeData();
    updateNotifications();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBadgeData() async {
    setState(() => _loadingBadgeData = true);

    try {
      // TODO: Replace with actual API calls
      // Fetch badge settings from your API
      final badgeSettingsTEXT = await _eventService.getMyBadgeSetting();


      // do we have a badge setting ?
      dynamic badgeSuccess = jsonDecode(badgeSettingsTEXT.body)['success'];

      if( badgeSuccess ){
          dynamic setting = jsonDecode(badgeSettingsTEXT.body)['setting'];


          // Fetch user data from your API
          final userDataTEXT = await _eventService.getEventProfileDATA();

          setState(() {
            _badgeSettings = setting;
            _userData = jsonDecode(userDataTEXT.body)['data'];
            _loadingBadgeData = false;
          });
      }else{
        // log err
        setState(() => _loadingBadgeData = false);
      }
      
      
    } catch (e) {
      print('Error loading badge data: $e');
      setState(() => _loadingBadgeData = false);
    }
  }

  void _showBadgeOptions() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceColor.withOpacity(0.95),
                AppTheme.cardColor.withOpacity(0.95),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.badgeOptions,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                icon: Icons.badge_rounded,
                title: l10n.showBadge,
                gradient: AppTheme.primaryGradient,
                onTap: () {
                  Navigator.pop(context);
                  _showMyBadge();
                },
              ),
              const SizedBox(height: 16),
              _buildOptionButton(
                icon: Icons.qr_code_scanner_rounded,
                title: l10n.scanQRBadge,
                gradient: AppTheme.accentGradient,
                onTap: () {
                  Navigator.pop(context);
                  _openQRScanner();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyBadge() {
    if (_loadingBadgeData) {
      _showSnackBar('Loading badge data...');
      return;
    }

    if (_badgeSettings == null || _userData == null) {
      _showSnackBar('Badge data not available');
      return;
    }else{
      
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BadgeDisplayScreen(
          badgeSettings: _badgeSettings!,
          userData: _userData!,
        ),
      ),
    );

    }

     
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  void updateNotifications() {
    _eventService.getNotifications().then((res) {
      dynamic body = jsonDecode(res.body);
      print(body);

      setState(() {
        notifications = (body['notifications'] as List)
            .where((n) => n['seen'] == false)
            .toList().length;
      });
    }).catchError((err) {
      print('Error fetching notifications: $err');
    });
  }






  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: _tabs.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          print(index);
        },
        onCenterButtonPressed: _showBadgeOptions,
        notifications: notifications,
      ),
    );
  }
}

class ModuleData {
  final String Function(AppLocalizations l10n) title;
  final IconData icon;
  final Gradient gradient;
  final Color color;

  ModuleData({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.color,
  });
}