import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/widgets/language_switcher.dart';

/// Participant Type Selection Page
/// User selects their participant profile type (VIP, Sponsor, etc.) before registration
class ParticipantTypeSelection extends StatefulWidget {
  final String eventId; 

  const ParticipantTypeSelection({
    super.key,
    required this.eventId
  });

  @override
  State<ParticipantTypeSelection> createState() => _ParticipantTypeSelectionState();
}

class _ParticipantTypeSelectionState extends State<ParticipantTypeSelection>  with SingleTickerProviderStateMixin {
  
  final EventService _eventService = EventService();


  
  
  List<ParticipantType> _participantTypes = [];
  ParticipantType? _selectedType;
  bool _isLoading = true;
  String? _error;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadParticipantTypes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipantTypes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _eventService.getParticipantTypes(widget.eventId);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _participantTypes = (data['participantTypes'] as List<dynamic>)
              .map((type) => ParticipantType.fromJson(type))
              .toList();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load participant types';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

   _handleContinue(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectProfile),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to registration form with selected type
    if (_selectedType != null) {
        context.push(
        '/events/${_selectedType!.id}/register',
        extra: {
          'participantType': _selectedType!.id,
          'participantTypeName': _selectedType!.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          
          _buildAppBar(),
          
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
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
                        onPressed: _loadParticipantTypes,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.chooseProfile,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n.pickProfileDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      _buildParticipantTypesList(),
                      SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : 
          Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedType != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF667eea).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF667eea), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedType!.name}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                   _handleContinue(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.continueLabel ,
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
          ],
        ),
      ),
    )
          ,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 20,
      pinned: true,
      stretch: true,
      //backgroundColor: Color(0xFF667eea),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 0, 0, 0)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: LanguageSwitcher(),
        ),
      ],
       
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFFf093fb),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  

  Widget _buildParticipantTypesList() {
    return Column(
      children: _participantTypes.map((type) {
        return _buildParticipantTypeCard(type);
      }).toList(),
    );
  }

  Widget _buildParticipantTypeCard(ParticipantType type) {
    final isSelected = _selectedType?.id == type.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF667eea) : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Color(0xFF667eea).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 16 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon/Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _getTypeColor(type.id).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(type.id),
                    size: 32,
                    color: _getTypeColor(type.id),
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                         
                      ],
                    ),
                    
                    SizedBox(height: 6),
                    
                    Text(
                      type.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    
                    if (type.price != null) ...[
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            type.price!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (type.benefits != null && type.benefits!.isNotEmpty) ...[
                      SizedBox(height: 12),
                      ...type.benefits!.take(3).map((benefit) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (type.benefits!.length > 3)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${type.benefits!.length - 3} more benefits',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667eea),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Color(0xFF667eea) : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? Color(0xFF667eea) : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

 

  Color _getTypeColor(String typeId) {
    switch (typeId.toLowerCase()) {
      case 'vip':
        return Color(0xFFFFD700); // Gold
      case 'sponsor':
        return Color(0xFF9C27B0); // Purple
      case 'speaker':
        return Color(0xFF2196F3); // Blue
      case 'attendee':
      case 'general':
        return Color(0xFF4CAF50); // Green
      case 'exhibitor':
        return Color(0xFFFF9800); // Orange
      case 'media':
      case 'press':
        return Color(0xFFE91E63); // Pink
      default:
        return Color(0xFF667eea); // Default purple-blue
    }
  }

  IconData _getTypeIcon(String typeId) {
    switch (typeId.toLowerCase()) {
      case 'vip':
        return Icons.star;
      case 'sponsor':
        return Icons.business;
      case 'speaker':
        return Icons.mic;
      case 'attendee':
      case 'general':
        return Icons.person;
      case 'exhibitor':
        return Icons.store;
      case 'media':
      case 'press':
        return Icons.camera_alt;
      default:
        return Icons.badge;
    }
  }
}

/// Model for Participant Type
class ParticipantType {
  final String id;
  final String name;
  final String description;
  final String? price;
  final String? badge;
  final List<String>? benefits;
  final int? availableSlots;
  final bool isAvailable;

  ParticipantType({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.badge,
    this.benefits,
    this.availableSlots,
    this.isAvailable = true,
  });

  factory ParticipantType.fromJson(Map<String, dynamic> json) {
    return ParticipantType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as String?,
      badge: json['badge'] as String?,
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      availableSlots: json['availableSlots'] as int?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
