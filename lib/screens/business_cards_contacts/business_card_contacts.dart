import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Model
class Contact {
  final int id;
  final int participantId;
  final String fullname;
  final String email;
  final String phone;
  final String avatarUrl;
  final String eventName;
  final String type;
  

  Contact({
    required this.id,
    required this.participantId,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.eventName, required this.type,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      participantId: json['participant_id'],
      fullname: json['fullname'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      eventName: json['eventName'], 
      type: json['type']
    );
  }
}

// Main Screen
class BusinessCardsScreen extends StatefulWidget {
  const BusinessCardsScreen({Key? key}) : super(key: key);

  @override
  State<BusinessCardsScreen> createState() => _BusinessCardsScreenState();
}

class _BusinessCardsScreenState extends State<BusinessCardsScreen>
    with TickerProviderStateMixin {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedEvent;
  Set<String> _eventNames = {};

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  EventService eventService = EventService();
  String? _selectedType; // incoming / outgoing

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadContacts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    
    eventService.myBusinessCardsContacts().then((res){ 
      final data = jsonDecode(res.body);

      print(data);

    final contacts = (data['contacts'] as List)
        .map((json) => Contact.fromJson(json))
        .toList();

    setState(() {
      _allContacts = contacts;
      _filteredContacts = contacts;
      _eventNames = contacts.map((c) => c.eventName).toSet();
      _isLoading = false;
    });

    _fadeController.forward();
    });



    
  }
void _filterContacts() {
  setState(() {
    _filteredContacts = _allContacts.where((contact) {
      final matchesSearch =
          contact.fullname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesEvent =
          _selectedEvent == null || contact.eventName == _selectedEvent;

      final matchesType =
          _selectedType == null || contact.type == _selectedType;
          // contact.type should be: 'incoming' or 'outgoing'

      return matchesSearch && matchesEvent && matchesType;
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title:  Text(
          l10n.businessCardExchange,
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A5568)),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterSection(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _filteredContacts.isEmpty
                        ? _buildEmptyState()
                        : _buildCardsList(),
                  ),
                ),
              ],
            ),
    );
  }

  
  Widget _buildFilterSection() {
  final l10n = AppLocalizations.of(context);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Search field
        TextField(
          onChanged: (value) {
            _searchQuery = value;
            _filterContacts();
          },
          decoration: InputDecoration(
            hintText: l10n.searchParticipantsLabel,
            prefixIcon: const Icon(Icons.search, color: Color(0xFF4A5568)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Event filter
        _buildDropdownContainer(
          child: DropdownButton<String?>(
            value: _selectedEvent,
            hint: Text(l10n.myEventsLabel),
            isExpanded: true,
            icon: const Icon(Icons.event),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.myEventsLabel),
              ),
              ..._eventNames.map((event) {
                return DropdownMenuItem<String>(
                  value: event,
                  child: Text(event),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _selectedEvent = value);
              _filterContacts();
            },
          ),
        ),

        const SizedBox(height: 12),

        // Type filter (Incoming / Outgoing)
        _buildDropdownContainer(
          child: DropdownButton<String?>(
            value: _selectedType,
            hint: Text('${l10n.outgoing} / ${l10n.incoming}'),
            isExpanded: true,
            icon: const Icon(Icons.swap_horiz),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('${l10n.outgoing} / ${l10n.incoming}'),
              ),
              DropdownMenuItem<String>(
                value: 'incoming',
                child: Text(l10n.incoming),
              ),
              DropdownMenuItem<String>(
                value: 'outgoing',
                child: Text(l10n.outgoing),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedType = value);
              _filterContacts();
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdownContainer({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );
}




  Widget _buildCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        return _buildBusinessCard(_filteredContacts[index], index);
      },
    );
  }

  Widget _buildBusinessCard(Contact contact, int index) {
    final l10n = AppLocalizations.of(context);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showContactDetails(contact),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'avatar_${contact.id}',
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              contact.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue.shade300,
                                  child: Center(
                                    child: Text(
                                      contact.fullname[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.fullname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                contact.eventName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.email_outlined,
                    contact.email,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    contact.phone,
                    Colors.green,
                  ),
                   const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.share,
                    contact.type == 'outgoing' ? l10n.outgoing : l10n.incoming,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noParticipantFound,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
           
        ],
      ),
    );
  }

  void _showContactDetails(Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContactDetailsSheet(contact),
    );
  }

Future<void> _callPhone(String phone) async {
  final Uri uri = Uri(scheme: 'tel', path: phone);
  if (!await launchUrl(uri)) {
    throw 'Could not launch $phone';
  }
}

Future<void> _sendEmail(String email) async {
  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
  );
  if (!await launchUrl(uri)) {
    throw 'Could not send email to $email';
  }
}


  Widget _buildContactDetailsSheet(Contact contact) {
    final l10n = AppLocalizations.of(context);
    return Container( 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Hero(
            tag: 'avatar_${contact.id}',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  contact.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue.shade300,
                      child: Center(
                        child: Text(
                          contact.fullname[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            contact.fullname,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              contact.eventName,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildDetailTile(
                  Icons.email,
                  l10n.email,
                  contact.email,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildDetailTile(
                  Icons.phone,
                  l10n.phone,
                  contact.phone,
                  Colors.green,
                ),
                 
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: contact.phone.isNotEmpty
                    ? () => _callPhone(contact.phone)
                    : null,
                    icon: const Icon(Icons.phone),
                    label: Text(l10n.callLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: contact.email.isNotEmpty
                    ? () => _sendEmail(contact.email)
                    : null,
                    icon: const Icon(Icons.email),
                    label: Text(l10n.email),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildDetailTile(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
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

 