import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/profile/my_profile.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/google_auth_service.dart';
import 'package:mobile/shared/alertBox.dart';
import 'package:mobile/widgets/language_switcher.dart';
//import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:ui';
import '../../widgets/animated_button.dart';
import '../../theme/app_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService =  AuthService();
  bool _showError = false;
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _handleSignIn() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Simulate network/loading delay
      await Future.delayed(Duration(seconds: 2));

      final res = await _authService.login(email: email, password: password);

      if (res.success == false) {
        setState(() {
          _showError = true;
        });
      } else {
        // Store token and user
        await _storage.write(key: 'token', value: res.token);
        await _storage.write(key: 'user', value: jsonEncode(res.user));

        print('Token after login: ${res.token}');
 
        
        context.go('/profile');
        
      }
    } catch (err) {
      print(err.toString());
      setState(() {
        _showError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  _handleSignInWithGoogle() async{
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final userCredential =  await GoogleAuthService().signInWithGoogle();

     final user = userCredential.user;

      if (user != null) {
        // ✅ SUCCESS
        print(user);
        
        print(user.email);
        print(user.displayName);
        print(user.photoURL);
 
        // 👉 SEND user.uid or idToken to backend 
        final res = await _authService.loginWithGoogle(email: user.email!);

        if (res.success) {
          // Store token and user
          await _storage.write(key: 'token', value: res.token);
          await _storage.write(key: 'user', value: jsonEncode(res.user));

          print( res );
          print('Token after login: ${res.token}');

          context.go('/profile');
  
        }else{
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(l10n.googleSignInFaildNoAccount),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        
        
      }
    } catch (e) {
      
      setState(() {
        _isLoading = false; 
      });

      await GoogleAuthService().signOut();

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(l10n.googleSignInFaild),
          backgroundColor: Colors.red,
        ),
      );
    }finally {
      await GoogleAuthService().signOut();
      setState(() => _isLoading = false);
    }
  }



  Future<void> _signInWithApple() async {
  /*final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );
 
  final appleUserId = credential.userIdentifier; // STORE THIS
  final email = credential.email; // Only first login
  final fullName = credential.givenName;

  final identityToken = credential.identityToken; // SEND TO BACKEND
  final authCode = credential.authorizationCode;

  // TODO: Send identityToken + appleUserId to backend

  print(appleUserId);
  print(email);
  print(fullName);*/
}


  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0, 
        actions: [
           const LanguageSwitcher(),
        ],
        
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.mainBackgroundColor
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon
                          Container(
                            height: 50,
                            child: SizedBox( 
                              child: Image.asset("assets/eventoo.png"),
                            ),
                            
                          ),

                          SizedBox(height: 80,),
                           
   
                          // Form
                          ClipRRect(
                            //borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                //color: Colors.red,
                                width: MediaQuery.of(context).size.width, 
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [ 

                                      Text(
                                        l10n.signInContinue,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),

                                      SizedBox(height: 18,),


                                      TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          style:  TextStyle(
                                            color: Colors.black, // text color
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: l10n.email,
                                            labelStyle: const TextStyle(color: Color.fromRGBO(156, 156, 152, 1)),
                                            hintText: l10n.enterYourEmail,
                                            hintStyle: const TextStyle(color: Color.fromRGBO(156, 156, 152, 1)),
                                            //prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),

                                            filled: true,
                                            fillColor: Color.fromRGBO(225, 218, 203, 1), // text color

                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),

                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),

                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(199, 18, 94, 1), // focus color
                                                width: 1.5,
                                              ),
                                            ),

                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.2,
                                              ),
                                            ),

                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return l10n.enterYourEmail;
                                            }
                                            if (!value.contains('@')) {
                                              return l10n.enterValidEmail;
                                            }
                                            return null;
                                          },
                                        ),


                                      const SizedBox(height: 20),

                                      // Password field
                                      TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: l10n.password,
                                            labelStyle: const TextStyle(
                                              color: Color.fromRGBO(156, 156, 152, 1),
                                            ),
                                            hintText: l10n.enterYourPassword,
                                            hintStyle: const TextStyle(
                                              color: Color.fromRGBO(156, 156, 152, 1),
                                            ),
                                            filled: true,
                                            
                                            /*prefixIcon: const Icon(
                                              Icons.lock_outline,
                                              color: Color.fromRGBO(156, 156, 152, 1),
                                            ),*/

                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                                color: Color.fromRGBO(199, 18, 94, 1),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                            ),
                                            fillColor: const Color.fromRGBO(225, 218, 203, 1), 
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(color: Colors.grey, width: 0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(color: Colors.grey, width: 0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(199, 18, 94, 1),
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.2,
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            
                                            
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return l10n.enterYourPassword;
                                            }
                                            if (value.length < 6) {
                                              return l10n.passwordError;
                                            }
                                            return null;
                                          },
                                        ),

                                      const SizedBox(height: 12),

                                      // Forgot password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            context.push('/forgot-password');
                                          },
                                          child: Text(
                                            l10n.forgetPassword ,
                                            style: TextStyle(
                                              color: AppTheme.accentColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Sign in button
                                      _isLoading
                                          ? Container(
                                            height: 50,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppTheme.accentColor,
                                              ),
                                            ),
                                          )
                                          : Container(

                                            child: Column(
                                              children: [
                                                AnimatedButton(
                                                  onPressed: _handleSignIn,
                                                  text: l10n.signIn,
                                                  gradient: AppTheme.primaryButtonGradient
                                                ),
                                                SizedBox(height: 15,),
                                                Container(
                                                  child: Row(
                                                    children: [

                                                      /*if( Platform.isAndroid )
                                                      Expanded(child: AnimatedButton(
                                                        onPressed: _handleSignInWithGoogle,
                                                        text: l10n.signInWihGoogle,
                                                        gradient: AppTheme.secondaryButtonGradient,
                                                        icon: FontAwesomeIcons.google,
                                                        textColor: Colors.grey.shade600,
                                                        
                                                      ), ),-*/


                                                      /*if (Platform.isIOS == true)
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      if (Platform.isIOS == true) 
                                                      Expanded(child: AnimatedButton(
                                                        onPressed: _signInWithApple,
                                                        text: "",
                                                        gradient: AppTheme.secondaryButtonGradient,
                                                        icon: FontAwesomeIcons.apple,
                                                        textColor: Colors.grey.shade600,
                                                      ), ),*/

                                                      
                                                      

                                                    ],
                                                  ),
                                                )
 
                                              ],
                                            ),
                                          ),
                                       
                                       SizedBox(height: 15,),

                                      SizedBox(
                                        child: _showError == true ?
                                      
                                        AlertBox( text:l10n.badCridential, type: "danger")
                                      : null
                                      )





                                      
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign up link
                         Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.dontHaveAccount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: () {
                                    context.push('/signup');
                                  },
                                  child: Text(
                                    l10n.signUpLabelLoginScreen,
                                    style: TextStyle(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )


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