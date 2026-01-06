import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/shared/alertBox.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'dart:ui';
import '../../widgets/animated_button.dart';
import '../../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedCountry;
  String? _selectedSex; 

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final GeneralGervice _generalGervice = GeneralGervice();

  bool _showError = false;
  bool _emailExist = false;
  

 List<Map<String, dynamic>> _countries = [];

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
    initCountriesList();
    
  }



  void initCountriesList(){

    _generalGervice.getCountriesList().then((res){
      //print(res.body);
      dynamic response = jsonDecode(res.body); 
      
      setState(() {
        _countries = List<Map<String, dynamic>>.from(response['data']);
      });
      
    }).catchError((err){
       print(err);
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      setState(() => _showError = false);
      setState(() => _emailExist = false);
      
      
 
      String firstname = _firstNameController.text;
      String lastname = _lastNameController.text;
      String email = _emailController.text;
      String phone = _phoneController.text;
      int countryID = _selectedCountry!;
      String password  = _passwordController.text;

      _authService.register(firstname: firstname, lastname: lastname, phone: phone, countryID: countryID, email: email, password: password, sex:_selectedSex).then((res){
        // check for success, else show error
        
        dynamic body = jsonDecode(res.body);
        bool success = body['success'];

        setState(() => _isLoading = false);

        if (success == false) {
              
            String code = body['code'];

            if( code == 'EMAIL_EXIST' ){
              // show email error
              setState(() => _emailExist = true);
            }else{
              setState(() => _showError = true);
            }

        } else {
          
          // account created !! open session and redirect to home page
          _authService.login(email: email, password: password).then((res){
            print("connected after signup");
            context.go('/profile');

          }).catchError((err){
            print(err);
          });

        }


      }).catchError((err){

        print(err);
        
        setState(() => _showError = true);
        setState(() => _isLoading = false);
        
        
      });



    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
              AppTheme.cardColor,
            ],
          ),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          SizedBox(
                            height: 50,
                            child: Image.asset("assets/white-logo.png"),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.signUpContinue,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.black.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),

                          // Form container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // First Name

                                          // Sex / Gender
                                          DropdownButtonFormField<String>(
                                            value: _selectedSex,
                                            decoration: InputDecoration(
                                              labelText: l10n.sex, 
                                              prefixIcon: const Icon(Icons.transgender),
                                            ),
                                            items: [
                                              DropdownMenuItem(value: "male", child: Text(l10n.male)),
                                              DropdownMenuItem(value: "female", child: Text(l10n.female)),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedSex = value;
                                              });
                                            },
                                            validator: (_) =>
                                                _selectedSex == null ? l10n.selectSex : null,
                                          ),
                                          const SizedBox(height: 16),




                                      TextFormField(
                                        controller: _firstNameController,
                                        decoration: InputDecoration(
                                          labelText: l10n.firstName,
                                          hintText: l10n.enterFirstName,
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.enterFirstName;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Last Name
                                      TextFormField(
                                        controller: _lastNameController,
                                        decoration: InputDecoration(
                                          labelText: l10n.lastName,
                                          hintText: l10n.enterLastName,
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.enterLastName;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Email
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: l10n.email,
                                          hintText: l10n.enterYourEmail,
                                          prefixIcon:
                                              const Icon(Icons.email_outlined),
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
                                      const SizedBox(height: 16),

                                      // Phone
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          labelText: l10n.phone,
                                          hintText: l10n.enterYourPhone,
                                          prefixIcon: const Icon(Icons.phone),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.enterYourPhone;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
 

                                      Autocomplete<Map<String, dynamic>>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Map<String, dynamic>>.empty();
    }
    return _countries.where((country) =>
        country['name']
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
  },
  displayStringForOption: (option) => option['name'],
  onSelected: (selection) {
    setState(() {
      _selectedCountry = selection['id'];
    });

     
  },
  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: l10n.country,
        prefixIcon: const Icon(Icons.public),
      ),
      validator: (_) =>
          _selectedCountry == null ? l10n.selectCountry : null,
    );
  },
),

                                      const SizedBox(height: 16),

                                      // Password
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        decoration: InputDecoration(
                                          labelText: l10n.password,
                                          hintText: l10n.enterYourPassword,
                                          prefixIcon:
                                              const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
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
                                      const SizedBox(height: 24),

                                      // Sign Up button
                                      _isLoading
                                          ? const CircularProgressIndicator()
                                          : AnimatedButton(
                                              onPressed: _handleSignUp,
                                              text: l10n.signUp,
                                              gradient: AppTheme.accentGradient,
                                              icon: Icons.arrow_forward_rounded,
                                            ),

                                       SizedBox(
                                        child: _showError == true ?
                                      
                                        AlertBox( text:l10n.serverError, type: "danger")
                                      : null
                                      ),


                                      SizedBox(
                                        child: _emailExist == true ?
                                      
                                        AlertBox( text:l10n.enterAlreadyInUse, type: "danger")
                                      : null
                                      )

                                      



                                      
                                    ],
                                  ),
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
