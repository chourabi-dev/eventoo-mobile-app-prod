// ============================================================================
// NETWORKING EXPERIENCE - PRODUCTION LEVEL
// ============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/api_networking_date.dart';
import 'package:mobile/models/networking_role.dart';
import 'package:mobile/models/participant_model.dart';
import 'dart:ui';
import 'dart:convert';

import 'package:mobile/screens/chat_screen/chat_screen.dart';
import 'package:mobile/screens/networking_experience/widgets/date_planifier.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/user_avatar.dart';



class AdvancedFilter {
  final int id;
  final String label;
  final String type; // text, checkbox, dropdown, radio
  final List<dynamic> options;

  AdvancedFilter({
    required this.id,
    required this.label,
    required this.type,
    required this.options,
  });

  factory AdvancedFilter.fromJson(Map<String, dynamic> json) {
    return AdvancedFilter(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      options: List<dynamic>.from(json['options'] ?? []),
    );
  }
}

class ParticipantRoles {
  final bool canSendInvitation;
  final bool canRequestBusinessCard;
  final bool canOpenChat;

  ParticipantRoles({
    required this.canSendInvitation,
    required this.canRequestBusinessCard,
    required this.canOpenChat,
  });

  factory ParticipantRoles.fromJson(Map<String, dynamic> json) {
    return ParticipantRoles(
      canSendInvitation: json['canSendInvitation'] ?? false,
      canRequestBusinessCard: json['canRequestBusinessCard'] ?? false,
      canOpenChat: json['canOpenChat'] ?? false,
    );
  }
}

class MeetingInvitation {
  final DateTime date;
  final TimeOfDay time;
  final String location;

  MeetingInvitation({
    required this.date,
    required this.time,
    required this.location,
  });
}
 
class NetworkingExperienceParticipantsTab extends StatefulWidget {
  const NetworkingExperienceParticipantsTab({super.key});

  @override
  State<NetworkingExperienceParticipantsTab> createState() =>
      _NetworkingExperienceParticipantsTabState();
}

class _NetworkingExperienceParticipantsTabState extends State<NetworkingExperienceParticipantsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Basic Filters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String? _selectedProfile;

  // Advanced Filters
  List<AdvancedFilter> _advancedFilters = [];
  Map<int, dynamic> _advancedFilterValues = {};
  bool _isLoadingFilters = false;

  // Data
  List<Participant> _participants = [];
  List<Participant> _filteredParticipants = [];
  List<Participant> _recommendations = [];
  bool _isLoadingData = true;
  bool _loadingNewParticipants = false;
         

  var _countries = <Map<String, dynamic>>[];
  var _profiles = <Map<String, dynamic>>[];
  String _selectedCountry = ""; 

  EventService _eventService = EventService();
  static const _storage = FlutterSecureStorage();
 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _nameController.addListener(_applyFilters);
    _countryController.addListener(_applyFilters);
    _loadProfilesAndCountries();

  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }


    Future<void> _loadProfilesAndCountries() async {
    try {
      final results = await Future.wait([
        _eventService.networkingExperienceProfiles(),
        _eventService.getCountriesList(),
      ]);

      if (!mounted) return;

 
      setState(() {
        _profiles = List<Map<String, dynamic>>.from(
          jsonDecode(results[0].body)['profiles'] as List,
        );
        _countries = List<Map<String, dynamic>>.from(
          jsonDecode(results[1].body) as List,
        );
      });

     
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<void> _loadData() async {
    String? participantsStorage = await _storage.read(key: "networking_participants");
    if( participantsStorage != null ){
      if( participantsStorage.isNotEmpty ){

        setState(() {
          _loadingNewParticipants = true;
        });

        dynamic body = jsonDecode(participantsStorage);

        setState(() {
  final rawList = body['data'] as List;

  List<Participant> participants = rawList.map((e) {
    try {
      return Participant.fromJson(e);
    } catch (err) {
      print('❌ Skipped corrupted participant: $err');
      return null;
    }
  })
  .whereType<Participant>()
  .toList();

  _participants = participants;
  _filteredParticipants = List.from(participants);
  _recommendations = List.from(participants);

  _isLoadingData = false;
});
      }
    }


    print("FETCHING NETWORKING EXPERINCE PARTICIPANTS...");
    

    _eventService.networkingExperienceParticipants().then((res) async {
      dynamic body = jsonDecode(res.body);

      await _storage.write(key: "networking_participants", value: res.body );


       setState(() {
        _participants = (body['data'] as List)
                  .map((e) => Participant.fromJson(e))
                  .toList();

        _filteredParticipants = (body['data'] as List)
                  .map((e) => Participant.fromJson(e))
                  .toList();
          _recommendations = (body['data'] as List)
                  .map((e) => Participant.fromJson(e))
                  .toList(); 
         _isLoadingData = false; 
         _loadingNewParticipants = false;

      });
        
      }).catchError((err){
        print(err.toString());
        setState(() {
          _isLoadingData = false;
          _loadingNewParticipants = false;
         
        });
      });
     
  }

  Future<void> _loadAdvancedFilters(String profile) async {

   _eventService
    .getNetworkingExperienceAdvancedFilters(int.parse(profile))
    .then((res) {
  final body = jsonDecode(res.body);
  

  print(body);

  setState(() {
    _isLoadingFilters = true;

    _advancedFilters = (body['filters'] as List)
        .map((e) => AdvancedFilter.fromJson(e))
        .toList();

    _advancedFilterValues.clear();
    _isLoadingFilters = false;
  });
});
 
  }

  void _applyFilters() {
      
       print("SEARCHING...");

      setState(() {
      _filteredParticipants = _participants.where((p) {
        // Basic filters
        final nameMatch = p.fullName.toLowerCase().contains(
          _nameController.text.toLowerCase(),
        );
        final countryMatch = p.country.name.toLowerCase().contains(
          _selectedCountry.toLowerCase()
        ); 


        // _selectedProfile is numeric, find associated label
        String label = "";

        for (var i = 0; i < _profiles.length; i++) {
          if (_profiles[i]['id'].toString() == _selectedProfile  ) {
            label = _profiles[i]['label'];
          }
        }

        final profileMatch =  _selectedProfile == null || p.profileLabel == label;

        // Advanced filters
        bool advancedMatch = true;
        for (var filter in _advancedFilters) {
          final value = _advancedFilterValues[filter.id];
          
          
          if (value != null) {
            if (filter.type == 'multiCheckbox') {
              if (value.isNotEmpty) {
                // Check if participant has any of the selected values
                final pfeilds = p.feilds;

                bool contains = false;

                for (var i = 0; i < pfeilds.length; i++) {

                  
                  
                  final hasMatch = value.any(
                    (v) => pfeilds[i].multipleValuesSelected.contains(v),
                  );

                  if ( hasMatch) {
                    contains = true;
                  }

                }
                
                if (contains == false) {
                  advancedMatch = false;
                  break;
                }
              }
            } else if ( value is String) {

              final pfeilds = p.feilds;
              
              bool found = false;

              for (var f in pfeilds) {
                 if (f.value == value) {
                  found = true; 
                }
              }

              if (found == false) {
                  advancedMatch = false;
                  break;
                }

             
            } 
          }
        }

        return nameMatch && countryMatch && profileMatch && advancedMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _countryController.clear();
      _selectedProfile = null;
      _advancedFilters.clear();
      _advancedFilterValues.clear();
      _filteredParticipants = _participants;
    });
  }

  void _openAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersSheet(
        filters: _advancedFilters,
        initialValues: _advancedFilterValues,
        onApply: (values) {
          setState(() {
            _advancedFilterValues = values;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);


    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: const Text('Networking Experience'), 
        actions: [
          if (_nameController.text.isNotEmpty ||
              _countryController.text.isNotEmpty ||
              _selectedProfile != null ||
              _advancedFilterValues.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _advancedFilters.isEmpty ? null : _openAdvancedFilters,
          ),
        ],
        /*bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '${l10n.allLabel} (${_filteredParticipants.length})'),
            Tab(text: '${l10n.recommendationsLabel} (${_recommendations.length})'),
          ],
        ),*/
      ),
     
      body: Column(
        children: [
          // Basic Filters
          Container(
            margin: EdgeInsets.only(top:15, left: 15, right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mainDeepBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: l10n.searchParticipantsLabel,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: AppTheme.mainDeepBackgroundColor,

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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }

                          return _countries.where((country) {
                            final name = country['label'];
                            if (name == null) return false;
                            return name
                                .toString()
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        displayStringForOption: (option) => option['label'].toString(),
                        onSelected: (selection) {
                          setState(() {
                            _selectedCountry = selection['label'];
                          });
                          _applyFilters();
                        },
                        fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration:  InputDecoration(
                              labelText: l10n.country ,
                              prefixIcon: Icon(Icons.public),
                              fillColor: AppTheme.mainDeepBackgroundColor,

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
                          );
                        },
                      ),
                    ) 
                    
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.mainDeepBackgroundColor,
                    borderRadius: BorderRadius.circular(4), 
                    border: BoxBorder.all( 
                      color: const Color.fromARGB(255, 198, 198, 198)
                    ), 
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedProfile,
                      hint:  Text(l10n.selectProfile),
                      items: [
                         DropdownMenuItem(
                          value: null,
                          child: Text(l10n.profile),
                        ),
                        ..._profiles.map((profile) {
                          return DropdownMenuItem(
                            value: '${ profile['id'] }',
                            child: Text(profile['label']),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProfile = value;
                        });
                        if (value != null) {
                          _loadAdvancedFilters(value);
                        } else {
                          setState(() {
                            _advancedFilters = [];
                            _advancedFilterValues.clear();
                          });
                        }
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                if (_isLoadingFilters == true) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],

                SizedBox(height: 15,),

                if( _loadingNewParticipants )
                LinearProgressIndicator()
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : _buildParticipantsList(_filteredParticipants),
                
                  /*TabBarView(
                    controller: _tabController,
                    children: [
                      _buildParticipantsList(_filteredParticipants),
                      _buildParticipantsList(_recommendations),
                    ],
                  ),*/
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(List<Participant> participants) {
    final l10n = AppLocalizations.of(context);
    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noParticipantFound,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return ParticipantCard(
          participant: participants[index],
          onTap: () => _showParticipantActions(participants[index]),
        );
      },
    );
  }


  Future<void> _addToFavourite(int id) async {
     
   

    try {
      final body = await _eventService.addParticipantToMyFavoutites( id,  ""  );
      dynamic res = jsonDecode(body.body);

      if (res != null && res['success'] == true) {
        //setState(() => _isFavourite = true);

        _showToast(
          context,
          message: res['message'] ?? 'Added to favourites',
          success: true,
        );
      } else {
        _showToast(
          context,
          message: res['message'] ?? 'Something went wrong',
          success: false,
        );
      }
    } catch (_) {
      _showToast(
        context,
        message: 'Server error, please try again',
        success: false,
      );
    } finally {
      //setState(() => _isAddingToFav = false);
    }
  }

    void _showToast(
    BuildContext context, {
    required String message,
    required bool success,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 90,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: success ? Colors.green.shade600 : Colors.red.shade600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
  

  Future<void> _showParticipantActions(
    Participant participant,
  ) async {
    // Simulate API call to get roles
    // my roles
    final res = await _eventService.networkingExperienceMyRoles();
    dynamic body = jsonDecode(res.body);

    print(body);

    if (!mounted) return;

    if( body['success'] == true ){
      final List<NetworkingRole> roles =  (body['roles'] as List)
          .map((e) => NetworkingRole.fromJson(e))
          .toList();

      showModalBottomSheet(
        context: context,
        //showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ParticipantActionsSheet(
          participant: participant,
          roles: roles,
          onSendInvitation: () => _sendMeetingInvitation(participant),
          onRequestBusinessCard: () => _requestBusinessCard(participant),
          onOpenChat: () => _openChat(participant),
          onfavAdd: (){
            print("ADDING TO FAV ${participant.id}");
            _addToFavourite(participant.id);

          },
        ),
      );
          


    }

    return;
 
  }

 

  Future<void> _sendMeetingInvitation(Participant participant) async {
    Navigator.pop(context);

    final invitation = await showDialog<MeetingInvitation>(
      context: context,
      builder: (context) => MeetingInvitationDialog(participant: participant),
    );

    if (invitation != null) {
      // Send to API
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meeting invitation sent to ${participant.fullName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _requestBusinessCard(Participant participant) async {
    Navigator.pop(context); 

    // CREATE THE API HERE
    _eventService.sendBusinessCardRequest(participant.id).then((res){

      dynamic body = jsonDecode(res.body);

      if( body['success'] == true ){
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                body['message'] ?? "Request sent",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }else{
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                body['message'] ?? "Request cannot be sent",
              ),
              backgroundColor: Colors.amber,
            ),
          );
        }
      }

      print(body);

    }).catchError((err){

    });

 
  }

  void _openChat(Participant participant) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(participant: participant.id)),
    );
  }
}

// ============================================================================
// PARTICIPANT CARD
// ============================================================================

class ParticipantCard extends StatelessWidget {
  final Participant participant;
  final VoidCallback onTap;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.mainDeepBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar with gradient ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentColor, AppTheme.accentColor],
                    ),
                     
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: UserAvatar(fullName: participant.fullName, imageUrl: participant.photoUrl,)
                    
                    /*CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(participant.photoUrl),
                      backgroundColor: Colors.grey[300],
                    ),*/
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      ...participant.feilds
                          .where((f) => f.showOnNetworkingApp == true && f.value != null && f.value != "")
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (f.value != null)
                                      Text(
                                        f.value ?? "",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    if (f.multipleValuesSelected.isNotEmpty)
                                      Text(
                                        f.multipleValuesSelected.join(", "),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                  ],
                                ),
                              )),

                      const SizedBox(height: 4),
                      Container( 
                        child: Text(
                          participant.profileLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            participant.country.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      

                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration( 
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentColor,
                    )
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.accentColor
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================================
// ADVANCED FILTERS SHEET
// ============================================================================

class AdvancedFiltersSheet extends StatefulWidget {
  final List<AdvancedFilter> filters;
  final Map<int, dynamic> initialValues;
  final Function(Map<int, dynamic>) onApply;

  const AdvancedFiltersSheet({
    super.key,
    required this.filters,
    required this.initialValues,
    required this.onApply,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  late Map<int, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                 Expanded(
                  child: Text(
                    l10n.advancedFilters,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _values.clear());
                  },
                  child:  Text(l10n.clearLabel),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.filters.map((filter) {
                  return _buildFilterWidget(filter);
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_values);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  Text(
                  l10n.applyFilters,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildFilterWidget(AdvancedFilter filter) {
  switch (filter.type) {
    case 'text':
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextField(
          onChanged: (value) {
            _values[filter.id] = value;
          },
          decoration: InputDecoration(
            labelText: filter.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

    // ===================== CHECKBOX =====================
    case 'multiCheckbox':
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              filter.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...filter.options.map((option) {
              final String label = option['label'].toString();
              final String value = option['value'].toString();

              final List<String> selected =
                  (_values[filter.id] as List<String>?) ?? [];

              return CheckboxListTile(
                title: Text(label),
                value: selected.contains(value),
                activeColor: const Color(0xFF6C63FF),
                onChanged: (checked) {
                  setState(() {
                    _values.putIfAbsent(filter.id, () => <String>[]);
                    final list = _values[filter.id] as List<String>;

                    if (checked == true) {
                      if (!list.contains(value)) list.add(value);
                    } else {
                      list.remove(value);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      );

    // ===================== DROPDOWN =====================
    case 'dropdown':
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              filter.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _values[filter.id] as String?,
                  hint: Text('Select ${filter.label}'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...filter.options.map((option) {
                      final String label = option['label'].toString();
                      final String value = option['value'].toString();

                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _values[filter.id] = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );

    // ===================== RADIO =====================
    case 'radio':
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              filter.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...filter.options.map((option) {
              final String label = option['label'].toString();
              final String value = option['value'].toString();

              return RadioListTile<String>(
                title: Text(label),
                value: value,
                groupValue: _values[filter.id] as String?,
                activeColor: const Color(0xFF6C63FF),
                onChanged: (val) {
                  setState(() {
                    _values[filter.id] = val;
                  });
                },
              );
            }).toList(),
          ],
        ),
      );

    default:
      return const SizedBox.shrink();
  }
}



}

// ============================================================================
// PARTICIPANT ACTIONS SHEET
// ============================================================================
class ParticipantActionsSheet extends StatelessWidget {
  final Participant participant;
  final List<NetworkingRole> roles;
  final VoidCallback onSendInvitation;
  final VoidCallback onRequestBusinessCard;
  final VoidCallback onOpenChat;
  final VoidCallback onfavAdd;
  
  const ParticipantActionsSheet({
    super.key,
    required this.participant,
    required this.roles,
    required this.onSendInvitation,
    required this.onRequestBusinessCard,
    required this.onOpenChat, required this.onfavAdd,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // can i send invitations ?
    bool canSendInvitation = false;

    for (var role in roles) {
      if (role.module == 'INVITAION_MODULE') {
        
        for (var action in role.action) {
          if (action == 'SEND') {
            canSendInvitation = true;
          }
        }
      }
    }

    bool canSendBusinessCard = false;

    for (var role in roles) {
      if (role.module == 'CARTE_VISITE_MODULE') {
        
        for (var action in role.action) {
          if (action == 'SEND') {
            canSendBusinessCard = true;
          }
        }
      }
    }


    bool canChat = false;

    for (var role in roles) {
      if (role.module == 'MESSAGING_MODULE') {
         
        for (var action in role.action) {
          if (action == 'SEND') {
            canChat = true;
          }
        }
      }
    }



    return Container(
      //height: 800,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppTheme.mainBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          const SizedBox(height: 20),
          // Participant Info
          UserAvatar(fullName: participant.fullName, imageUrl: participant.photoUrl,radius: 55,),
          /*CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(participant.photoUrl),
          ),*/
          const SizedBox(height: 12),
          Text(
            participant.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            participant.profileLabel,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

            if( canSendInvitation == true )
            _buildActionButton(
              context,
              Icons.event,
              l10n.sendInvitation,
              const Color(0xFF6C63FF),
              onSendInvitation,
            ),
           

            if( canSendBusinessCard == true )
            _buildActionButton(
              context,
              Icons.badge,
              l10n.requestBusinesCard,
              const Color(0xFFFF6584),
              onRequestBusinessCard,
            ),
           
            if( canChat == true )
            _buildActionButton(
              context,
              Icons.chat,
              l10n.chatsLabel,
              const Color(0xFF4ECDC4),
              onOpenChat,
            ), 


            _buildActionButton(
              context,
              Icons.star,
              l10n.addToFavLabel,
              AppTheme.deepColor,
              onfavAdd,
            ), 

           
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

