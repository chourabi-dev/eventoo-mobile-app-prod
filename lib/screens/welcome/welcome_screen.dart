import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/language_switcher.dart'; 
import '../../widgets/animated_button.dart';
import 'dart:ui';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  static const _storage = FlutterSecureStorage();
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    _checkSession();
  }


  // check session
  void _checkSession() async {
    String? token = await _storage.read(key: 'token');
    print(token);
 

    if( token != null ){
      
      context.pushReplacement('/profile');

    }else{
      setState(() {
        _checking = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: 
      _checking ?
      Center(
        child: CircularProgressIndicator(),
      ):
      
      
      
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0FF),
              Color(0xFFFFFFFF),
              Color(0xFFEFF5FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Language Switcher
            Positioned(
              top: 50,
              right: 20,
              child: const LanguageSwitcher(),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// LOGO
                          SizedBox(
                            width: 250, 
                            child: Image.asset("assets/white-logo.png"),
                          ),
                          const SizedBox(height: 16),
 
                          const SizedBox(height: 80),

                          /// GLASSMORPH CARD
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    /*AnimatedButton(
                                      onPressed: () {
                                        context.push('/events');
                                      },
                                      text: l10n.pickEvent,
                                      gradient: AppTheme.primaryGradient,
                                      icon: Icons.event_available_rounded,
                                    ),*/
                                    const SizedBox(height: 30),
                                    AnimatedButton(
                                      onPressed: () => context.push('/signin'),
                                      text: l10n.signIn,
                                      gradient: AppTheme.secondaryGradient,
                                      icon: Icons.login_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
