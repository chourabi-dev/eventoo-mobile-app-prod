import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart'; 
import 'package:mobile/services/general_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/event_registration/dynamic_form_page.dart';
import 'package:mobile/widgets/event_registration/form_models.dart';
import 'package:mobile/widgets/event_registration/registration_success.dart';


class EventRegistrationFlow extends StatefulWidget {
  final String eventId;

  const EventRegistrationFlow({
    super.key,
    required this.eventId,
  });

  @override
  State<EventRegistrationFlow> createState() => _EventRegistrationFlowState();
}

class _EventRegistrationFlowState extends State<EventRegistrationFlow> {
  final EventService _eventService = EventService();
  final PageController _pageController = PageController();
  
  List<FormPageConfig> _pages = [];
  Map<String, dynamic> _formData = {};
  
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFormConfiguration();
 
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Load form configuration from server
  Future<void> _loadFormConfiguration() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _eventService.getEventRegistrationForm(widget.eventId);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> pagesData = data['pages'] ?? [];
        
        setState(() {
          _pages = pagesData.map((pageJson) => FormPageConfig.fromJson(pageJson)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load registration form';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading form: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Move to next page
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _submitRegistration();
    }
  }

  /// Move to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  /// Save page data
  void _savePageData(Map<String, dynamic> pageData) {
    setState(() {
      _formData.addAll(pageData);
    });
  }

  /// Submit registration to server
  Future<void> _submitRegistration() async {
    setState(() => _isSubmitting = true);
    
    print(_formData);
    
    try {
      final response = await _eventService.createEventAccount(
        profileID: widget.eventId,
        formData: _formData,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationSuccessPage(
              profileID: data['profileID']
            ),
          ),
        );

        context.go("/");
        
      } else {
        setState(() {
          _isSubmitting = false;
          _error = data['message'] ?? 'Registration failed';
        });
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Error submitting registration: ${e.toString()}';
      });
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Error'),
        content: Text(_error ?? 'An unknown error occurred'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.mainDeepBackgroundColor,
        appBar: AppBar(
          title: Text( l10n.eventRegistration ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading registration form...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null && _pages.isEmpty) {
      return Scaffold(
       backgroundColor: AppTheme.mainDeepBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.eventRegistration),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadFormConfiguration,
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
   backgroundColor: AppTheme.mainDeepBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.eventRegistration),
      backgroundColor: AppTheme.mainDeepBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0 ? _previousPage : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppTheme.mainDeepBackgroundColor,
      child: Column(
        children: [
          Row(
            children: List.generate(_pages.length, (index) {
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? AppTheme.accentColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _pages.length - 1) SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentPage + 1} / ${_pages.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(((_currentPage + 1) / _pages.length) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
          
          // Form Pages
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return DynamicFormPage(
                      pageConfig: _pages[index],
                      initialData: _formData,
                      onNext: (data) {
                        _savePageData(data);
                        _nextPage();
                      },
                      onPrevious: _previousPage,
                      isFirstPage: index == 0,
                      isLastPage: index == _pages.length - 1,
                    );
                  },
                ),
                
                // Submitting overlay
                if (_isSubmitting)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        margin: EdgeInsets.all(32),
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                l10n.submiting,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
}
