import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/advanced_filter_feild.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/participant_card.dart';

// Miami Retro Light Theme Color Palette
//Color.fromRGBO(199, 18, 94, 1), Color.fromRGBO(107, 22, 81, 1)

class MiamiColors {
  static const hotPink = Color.fromRGBO(199, 18, 94, 1);
  static const electricBlue = Color.fromRGBO(199, 18, 94, 1);
  static const sunsetOrange = Color(0xFFFF8C42);
  static const neonPurple = Color.fromRGBO(199, 18, 94, 1);
  static const mintGreen = Color.fromRGBO(199, 18, 94, 1);
  static const softCream = Color(0xFFFFFBF5);
  static const lightPeach = Color(0xFFFFF0E6);
  static const paleBlue = Color(0xFFE3F5FF);
  static const lavender = Color(0xFFF3E5FF);
  
  static const gradient = LinearGradient(
    colors: [softCream, lightPeach, Color(0xFFFFF5F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFFFBF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AllParticipantsScreen extends StatefulWidget {
  const AllParticipantsScreen({super.key});

  @override
  State<AllParticipantsScreen> createState() => _AllParticipantsScreenState();
}

class _AllParticipantsScreenState extends State<AllParticipantsScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final ScrollController _scrollController;
  late final AnimationController _filterAnimationController;
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarAnimation;
  late final Animation<Offset> _slideAnimation;

  final EventService _eventService = EventService();

  var _participants = <Participant>[];
  var _profiles = <Map<String, dynamic>>[];
  var _countries = <Map<String, dynamic>>[];
  var _advancedFields = <AdvancedFeildFiler>[];
  var _selectedAdvancedFilters = <int, dynamic>{};

  int? _selectedProfile;
  int? _selectedCountry;
  var _isLoading = true;
  var _showAdvancedFilters = false;


  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;


  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _scrollController = ScrollController();
    
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutCubic,
    );
    
    _searchBarController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _filterAnimationController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    await _loadProfilesAndCountries();
    await _performSearch();
  }

  Future<void> _loadProfilesAndCountries() async {
    try {
      final results = await Future.wait([
        _eventService.getEventProfiles(),
        _eventService.getCountriesList(),
      ]);

      if (!mounted) return;

      setState(() {
        _profiles = List<Map<String, dynamic>>.from(
          jsonDecode(results[0].body) as List,
        );
        _countries = List<Map<String, dynamic>>.from(
          jsonDecode(results[1].body) as List,
        );
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load filters');
    }
  }

  Future<void> _loadAdvancedFilters(int profileId) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await _eventService.getAdvancedFilters(profileId);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;

      if (body['success'] == true) {
        final filters = (body['filters'] as List)
            .map((e) => AdvancedFeildFiler.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _advancedFields = filters;
          _showAdvancedFilters = true;
        });
        
        await _filterAnimationController.forward();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load advanced filters');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    if (!mounted) return;

     
    try {
      
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return; 
      
      
      print("searching participants ...");
      
      _eventService.searchParticipants( 
        fullName: _nameController.text,
        profile: _selectedProfile.toString(),
        country: _selectedCountry.toString(),
        advancedFilters: _selectedAdvancedFilters ,
        limit: 50,
        page: _currentPage
       ).then((res){
 
        dynamic body = jsonDecode(res.body);
 

        setState(() {
          _participants = (body['data'] as List)
            .map((e) {
              try {
                return Participant.fromJson(e);
              } catch (err) {
                print('❌ Bad participant skipped: $err');
                return null;
              }
            })
            .where((e) => e != null)
            .cast<Participant>()
            .toList();
        });
        setState(() => _isLoading = false);


       }).catchError((err){
        _showErrorSnackBar("${err.toString()}");
        setState(() => _isLoading = false);
       });
 
      
    } catch (e) {
      _showErrorSnackBar('Search failed');
      setState(() => _isLoading = false);
    } finally {
      
    }
  }

  Future<void> _hideAdvancedFilters() async {
    await _filterAnimationController.reverse();
    if (mounted) {
      setState(() => _showAdvancedFilters = false);
    }
  }

  void _clearAdvancedFilters() {
    setState(() => _selectedAdvancedFilters.clear());
  }

  void _applyFilters() {
    _performSearch();
    _hideAdvancedFilters();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MiamiColors.hotPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        //decoration: const BoxDecoration(gradient: MiamiColors.gradient),
        child: Stack(
          children: [
            // Animated background elements
            _buildBackgroundEffects(),
            
            // Main content
            Column(
              children: [
                const SizedBox(height: 100),
                _buildSearchSection(),
                const SizedBox(height: 16),
                Expanded(child: _buildParticipantsList()),
              ],
            ),
            
            // Advanced filters panel
            if (_showAdvancedFilters) _buildAdvancedFiltersPanel(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      backgroundColor: AppTheme.mainDeepBackgroundColor,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [MiamiColors.hotPink, MiamiColors.electricBlue],
        ).createShader(bounds),
        child:  Text(
          l10n.participants,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: MiamiColors.hotPink.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: () {
              if (_selectedProfile != null && !_showAdvancedFilters) {
                _loadAdvancedFilters(_selectedProfile!);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundEffects() {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        // Animated orbs
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  MiamiColors.electricBlue.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  MiamiColors.hotPink.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  MiamiColors.mintGreen.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _searchBarAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_searchBarAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Search bar
              Container(
                /*decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: MiamiColors.electricBlue.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MiamiColors.electricBlue.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: MiamiColors.hotPink.withOpacity(0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),*/
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchParticipantsLabel,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onChanged: (_) => _performSearch(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter chips
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      label: _selectedProfile != null 
                        ? _profiles.firstWhere((p) => p['id'] == _selectedProfile)['label']
                        : l10n.profile,
                      icon: Icons.person_outline,
                      gradient: LinearGradient(
                        colors: [MiamiColors.neonPurple, MiamiColors.hotPink],
                      ),
                      onTap: () => _showProfilePicker(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterChip(
                      label: _selectedCountry != null
                        ? _countries.firstWhere((c) => c['id'] == _selectedCountry)['label']
                        : l10n.country,
                      icon: Icons.public,
                      gradient: LinearGradient(
                        colors: [MiamiColors.electricBlue, MiamiColors.mintGreen],
                      ),
                      onTap: () => _showCountryPicker(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.mainDeepBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.transparent, 
            width: 0
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfilePicker() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetPicker(
        title: l10n.profile,
        items: _profiles,
        selectedId: _selectedProfile,
        onSelect: (id) {
          setState(() {
            _selectedProfile = id;
            _selectedAdvancedFilters.clear();
          });
          if (id != null) _loadAdvancedFilters(id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCountryPicker() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetPicker(
        title: l10n.country,
        items: _countries,
        selectedId: _selectedCountry,
        onSelect: (id) {
          setState(() => _selectedCountry = id);
          _performSearch();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBottomSheetPicker({
    
    required String title,
    required List<Map<String, dynamic>> items,
    required int? selectedId,
    required Function(int?) onSelect,
  }) {
    final l10n = AppLocalizations.of(context);

    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: MiamiColors.electricBlue.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [MiamiColors.hotPink, MiamiColors.electricBlue],
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (selectedId != null)
                  TextButton(
                    onPressed: () {
                      onSelect(null);
                      Navigator.pop(context);
                    },
                    child:  Text(
                      l10n.clearLabel,
                      style: TextStyle(
                        color: MiamiColors.hotPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item['id'] == selectedId;
                
                return InkWell(
                  onTap: () => onSelect(item['id']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                MiamiColors.hotPink.withOpacity(0.1),
                                MiamiColors.neonPurple.withOpacity(0.1),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? MiamiColors.hotPink
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        if (isSelected) const SizedBox(width: 12),
                        Text(
                          item['label'],
                          style: TextStyle(
                            color: const Color(0xFF2D3748),
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: MiamiColors.electricBlue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MiamiColors.electricBlue),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [MiamiColors.hotPink, MiamiColors.electricBlue],
              ).createShader(bounds),
              child:  Text(
                l10n.loadingParticipants,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: MiamiColors.electricBlue.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MiamiColors.electricBlue.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: MiamiColors.electricBlue.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noParticipantFound,
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
             
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ParticipantCard(participant: _participants[index]),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFiltersPanel() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              color: MiamiColors.electricBlue.withOpacity(0.3),
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildAdvancedFiltersHeader(),
            Expanded(child: _buildAdvancedFiltersList()),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFiltersHeader() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MiamiColors.hotPink.withOpacity(0.08),
            MiamiColors.neonPurple.withOpacity(0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
             Expanded(
              child: Text(
                l10n.advancedFilters,
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _clearAdvancedFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text( l10n.clearLabel ),
              style: TextButton.styleFrom(
                foregroundColor: MiamiColors.hotPink,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF2D3748)),
              onPressed: _hideAdvancedFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFiltersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _advancedFields.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: _buildFilterField(_advancedFields[index]),
        );
      },
    );
  }

  Widget _buildFilterField(AdvancedFeildFiler field) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFieldInput(field),
        ],
      ),
    );
  }

  Widget _buildFieldInput(AdvancedFeildFiler field) {
    return switch (field.type) {
      'dropdown' => _buildDropdownField(field),
      'radio' => _buildRadioField(field),
      'multiCheckbox' => _buildCheckboxField(field),
      _ => _buildTextField(field),
    };
  }

  Widget _buildDropdownField(AdvancedFeildFiler field) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAdvancedFilters[field.id] as String?,
        dropdownColor: Colors.white,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: Text(
          l10n.selectOptionLabel,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        style: const TextStyle(color: Color(0xFF2D3748), fontSize: 15),
        icon: Icon(Icons.arrow_drop_down, color: MiamiColors.electricBlue),
        items: field.values
            .map((option) => DropdownMenuItem<String>(
                  value: option['value'] as String,
                  child: Text(option['label'] as String),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedAdvancedFilters[field.id] = value);
        },
      ),
    );
  }

  Widget _buildRadioField(AdvancedFeildFiler field) {
    return Column(
      children: field.values.map<Widget>((option) {
        final isSelected = _selectedAdvancedFilters[field.id] == option['value'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedAdvancedFilters[field.id] = option['value']);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        MiamiColors.hotPink.withOpacity(0.08),
                        MiamiColors.neonPurple.withOpacity(0.08),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? MiamiColors.hotPink
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
                          )
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.circle, color: Colors.white, size: 10)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  option['label'] as String,
                  style: TextStyle(
                    color: const Color(0xFF2D3748),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildCheckboxField(AdvancedFeildFiler field) {
    final selectedValues = (_selectedAdvancedFilters[field.id] as List<String>?) ?? <String>[];

    return Column(
      children: field.values.map<Widget>((option) {
        final value = option['value'] as String;
        final isSelected = selectedValues.contains(value);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              final selected = List<String>.from(selectedValues);
              if (isSelected) {
                selected.remove(value);
              } else {
                selected.add(value);
              }
              _selectedAdvancedFilters[field.id] = selected;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        MiamiColors.electricBlue.withOpacity(0.08),
                        MiamiColors.mintGreen.withOpacity(0.08),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? MiamiColors.electricBlue
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [MiamiColors.electricBlue, MiamiColors.mintGreen],
                          )
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option['label'] as String,
                    style: TextStyle(
                      color: const Color(0xFF2D3748),
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(AdvancedFeildFiler field) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: TextField(
        style: const TextStyle(color: Color(0xFF2D3748), fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Enter ${field.label.toLowerCase()}',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          _selectedAdvancedFilters[field.id] = value;
        },
      ),
    );
  }

  Widget _buildApplyButton() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MiamiColors.hotPink, MiamiColors.neonPurple],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: MiamiColors.hotPink.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _applyFilters,
              borderRadius: BorderRadius.circular(16),
              child:  Center(
                child: Text(
                  l10n.applyFilters,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}