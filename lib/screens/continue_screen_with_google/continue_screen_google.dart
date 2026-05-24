import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/shared/alertBox.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'dart:ui';
import '../../widgets/animated_button.dart';
import '../../theme/app_theme.dart';

class ContinueGoogleSignup extends StatefulWidget {
  final String email;
  final String fullname;
  final String photoURL;
   
  const ContinueGoogleSignup({super.key, required this.email, required this.fullname, required this.photoURL});

  @override
  State<ContinueGoogleSignup> createState() => _ContinueGoogleSignupState();
}

class _ContinueGoogleSignupState extends State<ContinueGoogleSignup> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _companyController = TextEditingController();
  final _functionController = TextEditingController();

  
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
      
      String fullname = widget.fullname;
      String email = widget.email;


      print(fullname);
      
 
     final parts = fullname.trim().split(RegExp(r'\s+'));

    String firstname = parts.isNotEmpty ? parts.first : "";
    String lastname  = parts.length > 1 ? parts.sublist(1).join(' ') : "";
    String phone = _phoneController.text;
    int countryID = _selectedCountry!; 
    
    String company = _companyController.text;
    String function = _functionController.text;

 


      

      _authService.continueGoogleSignup(firstname: firstname, lastname: lastname, phone: phone, countryID: countryID, email: email, sex:_selectedSex, photoURL: widget.photoURL, company: company, role: function).then((res) async{
        // check for success, else show error
        
        dynamic body = jsonDecode(res.body);

        print(body);


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

          await _storage.write(key: 'token', value: body['token']);
          await _storage.write(key: 'user', value: body['user'].toString() ); 

          print("Token after login: ${ body['token'] }"); 
          context.go('/profile');


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
      backgroundColor: AppTheme.mainBackgroundColor,
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
                            child: Image.asset("assets/eventoo.png"),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.finishSignUpText,
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
                          Container( 
                            child: Container(
                               
                              child: Container(
                                 
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
                                              fillColor: Color.fromRGBO(225, 218, 203, 1), // text color
                                           border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),
                                             enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0),
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
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.2,
                                              ),
                                            ),

                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            
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
                                          const SizedBox(height: 18),


 
                                      
                                      

                                      // Phone
                                      IntlPhoneField(
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                          labelText: l10n.phone,
                                          hintText: l10n.enterYourPhone,
                                          fillColor: Color.fromRGBO(225, 218, 203, 1), // text color
                                           border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),
                                             enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0),
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
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.2,
                                              ),
                                            ),

                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            
                                        ),
                                        initialCountryCode: 'TN',
                                        validator: (phone) {
                                          if (phone == null || phone.number.isEmpty) {
                                            return l10n.enterYourPhone;
                                          }
                                          return null;
                                        },
                                      ),

                                      

                                      TextFormField(
                                        controller: _companyController,
                                        decoration: InputDecoration(
                                          labelText:  l10n.companyLabel, 
                                          prefixIcon:  FaIcon(FontAwesomeIcons.building ),
                                          fillColor: Color.fromRGBO(225, 218, 203, 1), // text color
                                           border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),
                                             enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0),
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
                                           
                                            
                                        ),
                                         
                                      ),
                                      const SizedBox(height: 18),
                                      

                                      // role
                                      TextFormField(
                                        controller: _functionController,
                                        decoration: InputDecoration(
                                          labelText: l10n.functionLabel, 
                                          prefixIcon: const Icon(Icons.check),
                                          fillColor: Color.fromRGBO(225, 218, 203, 1), // text color
                                           border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),
                                             enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0),
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
                                             
                                            
                                        ),
                                        
                                      ),
                                      const SizedBox(height: 18),
                                      

 

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
                                              fillColor: Color.fromRGBO(225, 218, 203, 1), // text color
                                           border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0), // radius
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0,
                                              ),
                                            ),
                                             enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(0),
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
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.2,
                                              ),
                                            ),

                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            
                                            ),
                                            validator: (_) =>
                                                _selectedCountry == null ? l10n.selectCountry : null,
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 18),
 

                                      // Sign Up button
                                      _isLoading
                                          ? const CircularProgressIndicator()
                                          : AnimatedButton(
                                              onPressed: _handleSignUp,
                                              text: l10n.finishSignup,
                                              gradient: AppTheme.primaryButtonGradient,
                                              icon: Icons.check,
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
