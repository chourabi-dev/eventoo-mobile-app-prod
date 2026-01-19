import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/shared/alertBox.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'dart:ui';
import '../../widgets/animated_button.dart';
import '../../theme/app_theme.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _companyController = TextEditingController();
  final _functionController = TextEditingController();


  final _passwordController = TextEditingController();
  int? _selectedCountry;
  
  String _selectedCountryName="";
  

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final GeneralGervice _generalGervice = GeneralGervice();

  bool _showError = false;
  bool _showSuccess = false;
  
  
  bool _emailExist = false;

   String _selectedSex = "male"; 
  

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
    _initForm();
  }


  void _initForm(){
    

    setState(() {
      _isLoading = true;
    });
    _authService.getUserInfo().then((res){
      setState(() {
        _isLoading = false;
      });

      dynamic body = jsonDecode(res.body); 
      dynamic user = body['user'];


      print(user);


      _firstNameController.text= user['firstName'] ; 
      _lastNameController.text= user['lastName'] ; 
      _phoneController.text= user['phone'] ; 
      
      _companyController.text= user['company'] ; 
      _functionController.text= user['role'] ; 
      

      
      
      
      setState(() {
        _selectedCountry= user['country_id'] ;   
        _selectedCountryName = user['country_name'];
        _selectedSex = user['sexe'] ?? "male";
      });
        
    });
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

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      setState(() => _showError = false);
      setState(() => _emailExist = false);
      setState(() => _showSuccess = false);

      
 
      String firstname = _firstNameController.text;
      String lastname = _lastNameController.text; 
      String phone = _phoneController.text;
      int countryID = _selectedCountry!; 

      String company = _companyController.text;
      String function = _functionController.text;
      
 

      _authService.updateInfo(firstname: firstname, lastname: lastname, phone: phone, countryID: countryID, sexe: _selectedSex! , company: company, role: function ).then((res){
        // check for success, else show error
        
        dynamic body = jsonDecode(res.body);
        bool success = body['success'];


        print("UPDATE RESPONSE:");
        print(body);

        setState(() => _isLoading = false);

        if (success == false) {
              
              setState(() => _showError = true);

        } else {
          
           // show success badge
           setState(() => _showSuccess = true);
           context.pop(true);

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
                          Text(
                            l10n.updateMyProfile,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.black.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

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

                                       DropdownButtonFormField<String>(
                                            value: _selectedSex,
                                            decoration: InputDecoration(
                                              labelText: l10n.sex,           // <-- add in localization
                                              prefixIcon: const Icon(FontAwesomeIcons.mars),
                                            ),
                                            items: [
                                              DropdownMenuItem(value: "male", child: Text(l10n.male)),
                                              DropdownMenuItem(value: "female", child: Text(l10n.female)),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedSex = value!;
                                              });
                                            },
                                            validator: (_) =>
                                                _selectedSex == null ? l10n.selectSex : null,
                                          ),
                                          const SizedBox(height: 16),

                                      // First Name
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


                                      

                                      // company
                                      TextFormField(
                                        controller: _companyController,
                                        decoration: InputDecoration(
                                          labelText:  l10n.companyLabel, 
                                          prefixIcon:  Icon(FontAwesomeIcons.building ),
                                           
                                           
                                            
                                        ),
                                         
                                      ),
                                      const SizedBox(height: 18),
                                      

                                      // role
                                      TextFormField(
                                        controller: _functionController,
                                        decoration: InputDecoration(
                                          labelText: l10n.functionLabel, 
                                          prefixIcon: const Icon(Icons.check),
                                           
                                             
                                            
                                        ),
                                        
                                      ),
                                      const SizedBox(height: 18),
                                      


 
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
                                        initialValue: TextEditingValue(text: _selectedCountryName),
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
    controller.text = _selectedCountryName;

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

                                      
                                      const SizedBox(height: 24),

                                      // Sign Up button
                                      _isLoading
                                          ? const CircularProgressIndicator()
                                          : AnimatedButton(
                                              onPressed: _handleUpdateProfile,
                                              text: l10n.updateMyProfile,
                                              gradient: AppTheme.accentGradient,
                                              icon: Icons.save,
                                            ),

                                       SizedBox(
                                        child: _showError == true ?
                                      
                                        AlertBox( text:l10n.serverError, type: "danger")
                                      : null
                                      ),

                                       SizedBox(
                                        child: _showSuccess == true ?
                                      
                                        AlertBox( text:l10n.profileDataUpdated, type: "success")
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
