import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/continue_screen_with_google/continue_screen_google.dart';
import 'package:mobile/services/google_auth_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/auth_separator.dart';
import 'package:mobile/widgets/google_auth_button.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/animated_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const _storage = FlutterSecureStorage();
  bool _checking = true;

  bool _googleSignupScreen = false;
 

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

  /// Check session
  Future<void> _checkSession() async {
    final token = await _storage.read(key: 'token');

    if (token != null) {
      context.pushReplacement('/profile');
    } else {
      setState(() {
        _checking = false;
      });
    }
  }

  /// Open company website
  Future<void> _openCompanyWebsite() async {
    /*final Uri url = Uri.parse('http://chourabi-e-business-solutions.com/');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }*/
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }





  _handleSignInWithGoogle() async{
    setState(() {
      //_isLoading = true;
      //_showError = false;
    });

    try {
      final userCredential =  await GoogleAuthService().signInWithGoogle();

     final user = userCredential.user;

      if (user != null) {
        // ✅ SUCCESS
        print(user); 
        print(user.email); 
        print(user.photoURL);
        print(user.displayName);
        


        setState(() {
          _googleSignupScreen = false; 
        });

       if (user.email != null && user.displayName != null) {
          Navigator.push(context, new MaterialPageRoute(builder: (context) {
              return( ContinueGoogleSignup( email: user.email!, fullname: user.displayName!, photoURL: user.photoURL?? "/assets/img/avatar-placeholder.png",  ) );
          },));
          
       } else{
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google signup failed'),
          backgroundColor: Colors.red,
        ),
      );
       } 
        
      }
    } catch (e) {
      
      setState(() {
        _googleSignupScreen = false; 
      });

      await GoogleAuthService().signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    }finally {
      await GoogleAuthService().signOut();
      // setState(() => _isLoading = false);
    }
  }

  



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: AppTheme.mainBackgroundColor
                
              ),
              child: Stack(
                children: [
                  /// Language Switcher
                  const Positioned(
                    top: 50,
                    right: 20,
                    child: LanguageSwitcher(),
                  ),

                  /// Main Content
                  SafeArea(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /// APP LOGO
                                SizedBox( 
                                  height: 90,
                                  child: Image.asset(
                                    "assets/main-logo.png",
                                    fit:BoxFit.fill
                                  ),
                                ), 
                                

                                const SizedBox(height: 80),

                                /// GLASSMORPH CARD
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      
                                      padding: const EdgeInsets.all(30),
                                      child: Column(
                                        children: [
                                          AnimatedButton(
                                            onPressed: () =>
                                                context.push('/signin'),
                                            text: l10n.signIn,
                                            gradient: AppTheme.primaryButtonGradient,
                                           
                                          ),

                                          SizedBox( height: 18, ),

                                          AuthSeparator( text: l10n.orTextSeparator,),

                                          SizedBox( height: 18, ),


                                          AnimatedButton(
                                            onPressed: () =>
                                            context.push('/signup'),
                                            text: l10n.signUp,
                                            gradient:  AppTheme.secondaryButtonGradient,
                                            textColor: Colors.grey.shade600,
                                            icon: Icons.mail,
                                          ),


                                          SizedBox( height: 18, ), 


                                          /*if( Platform.isAndroid )
                                          _googleSignupScreen == true? 
                                          Container(
                                            child: CircularProgressIndicator(),
                                          ):
                                            
                                          AnimatedButton(
                                            onPressed: (){
                                            setState(() {
                                              _googleSignupScreen = true;
                                            });

                                            _handleSignInWithGoogle(); 
                                          },
                                            text: l10n.signUpWihGoogle,
                                            gradient: AppTheme.secondaryButtonGradient,
                                            icon: FontAwesomeIcons.google,
                                            textColor: Colors.grey.shade600,
                                          ),*/
 
                                          

                                          
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

                  /// COMPANY LOGO (BOTTOM)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text("PowredBy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)
                    )
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _openCompanyWebsite,
                        child: Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'assets/tmp.png', 
                            height: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    ));
  }
}
