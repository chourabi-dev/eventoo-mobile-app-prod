import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart';

/// Success page shown after successful event registration
class RegistrationSuccessPage extends StatefulWidget {
  final String profileID;  

  const RegistrationSuccessPage({
    super.key,
    required this.profileID, 
  });

  @override
  State<RegistrationSuccessPage> createState() => _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  EventService _eventService = EventService(); 

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              
              // Success Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFF667eea).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 100,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // Success Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  l10n.registrationSuccessLabel,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                   l10n.registrationSuccessMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              
              
              Spacer(),
              
              // Action Buttons
              /*SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to event details
                    // TO BE CHECKED !!
                    context.push('/my-events');
 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.viewEventDeatils,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 12),*/
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Go back to events list
                    context.go('/profile');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Color(0xFF667eea)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.backToEvents,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
