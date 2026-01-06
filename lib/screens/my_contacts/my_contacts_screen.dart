import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/contact_model.dart';
import 'package:mobile/services/event_service.dart';

 

/// API Service for fetching participants
class ParticipantsApiService {
  final String baseUrl;

  ParticipantsApiService({required this.baseUrl});

  /// Fetch all participants from API
  Future<List<Contact>> fetchParticipants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/participants'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Contact.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load participants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching participants: $e');
    }
  }
}

class MyContactsScreen extends StatefulWidget {
 

  const MyContactsScreen({
    Key? key, 
  }) : super(key: key);

  @override
  State<MyContactsScreen> createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  
  
  List<Contact> _allParticipants = [];
  List<Contact> _filteredParticipants = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedEvent;
  bool _isSearchActive = false;
  bool _isLoading = true;
  String? _errorMessage;
  EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    
    
    _searchController.addListener(_onSearchChanged);
    _loadParticipants();
  }

  /// Load participants from API
  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _eventService.myContacts();

      dynamic body = jsonDecode(res.body); 

      setState(() {
        final List contactsJson = body['contacts'] ?? [];

        _allParticipants = contactsJson
            .map((e) => Contact.fromJson(e))
            .toList();

        _filteredParticipants = List<Contact>.from(_allParticipants);

        _isLoading = false;
      });


    } catch (e) {
      print(e);

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterParticipants();
  }

  void _filterParticipants() {
    setState(() {
      _filteredParticipants = _allParticipants.where((participant) {
        final matchesSearch = _searchController.text.isEmpty ||
            participant.fullname
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesEvent =
            _selectedEvent == null || participant.eventName == _selectedEvent;

        return matchesSearch && matchesEvent;
      }).toList();
    });
  }

  List<String> _getUniqueEvents() {
    final events = _allParticipants.map((p) => p.eventName).toSet().toList();
    events.sort();
    return events;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedEvent = null;
      _isSearchActive = false;
      _filteredParticipants = _allParticipants;
    });
  }

  void _showParticipantDetails(Contact participant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ParticipantDetailsSheet(participant: participant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final uniqueEvents = _getUniqueEvents();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.myContacts,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipants,
            tooltip: "refresh"// l10n.refresh,
          ),
          if (_isSearchActive || _selectedEvent != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: l10n.clearLabel,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _errorMessage != null
              ? _buildErrorState(context, l10n)
              : Column(
                  children: [
                    // Search and Filter Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            onTap: () => setState(() => _isSearchActive = true),
                            decoration: InputDecoration(
                              hintText: l10n.searchParticipantsLabel,
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.primary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Event Filter Dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _selectedEvent,
                                hint: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Event",//l10n.filterByEvent,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(12),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(l10n.seeAll),
                                  ),
                                  ...uniqueEvents.map((event) {
                                    return DropdownMenuItem<String?>(
                                      value: event,
                                      child: Text(event),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEvent = value;
                                    _filterParticipants();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Results Count
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            "${_filteredParticipants.length} ${l10n.resultsLabel}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedEvent != null) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(_selectedEvent!),
                              onDeleted: () {
                                setState(() {
                                  _selectedEvent = null;
                                  _filterParticipants();
                                });
                              },
                              deleteIcon: const Icon(Icons.close, size: 18),
                              backgroundColor: theme.colorScheme.primaryContainer
                                  .withOpacity(0.5),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Participants List
                    Expanded(
                      child: _filteredParticipants.isEmpty
                          ? _buildEmptyState(context, l10n)
                          : RefreshIndicator(
                              onRefresh: _loadParticipants,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredParticipants.length,
                                itemBuilder: (context, index) {
                                  final participant =
                                      _filteredParticipants[index];
                                  return _ParticipantCard(
                                    participant: participant,
                                    onTap: (){
                                      _showParticipantDetails(participant);
                                    }
                                        
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noParticipantFound,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
           
          
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadingParticipants,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingParticipant,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadParticipants,
              icon: const Icon(Icons.refresh),
              label: Text( l10n.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Participant Card Widget
class _ParticipantCard extends StatelessWidget {
  final Contact participant;
  final VoidCallback onTap;

  const _ParticipantCard({
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: participant.email,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: participant.avatarUrl != null
                        ? NetworkImage(participant.avatarUrl!)
                        : null,
                    child: participant.avatarUrl == null
                        ? Text(
                            participant.fullname[0].toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.fullname,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event,
                              size: 14,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              participant.eventName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (participant.scannedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          participant.scannedAt!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Participant Details Bottom Sheet
class _ParticipantDetailsSheet extends StatelessWidget {
  final Contact participant;

  const _ParticipantDetailsSheet({required this.participant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          expand: false,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.95),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Hero(
                      tag: participant.email,
                      child: CircleAvatar(
                      
                        radius: 55,
                        backgroundColor:  Colors.grey.shade300,
                        backgroundImage: participant.avatarUrl != null
                            ? NetworkImage(participant.avatarUrl!)
                            : null,
                        child: participant.avatarUrl == null
                            ? Text(
                                participant.fullname[0].toUpperCase(),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      participant.fullname,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _DetailItem(
                      icon: Icons.email,
                      label: l10n.email,
                      value: participant.email),
                  if (participant.phone != null)
                    _DetailItem(
                        icon: Icons.phone,
                        label: l10n.phone,
                        value: participant.phone!),
                  _DetailItem(
                      icon: Icons.event,
                      label: l10n.eventLabel,
                      value: participant.eventName),
                  if (participant.scannedAt != null)
                    _DetailItem(
                        icon: Icons.access_time,
                        label: l10n.dateLabel,
                        value: participant.scannedAt!),
                  if (participant.note != null)
                    _DetailItem(
                      icon: Icons.note,
                      label: l10n.noticeLabel,
                      value: participant.note!,
                      isLast: true,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Detail Item Widget
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
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