
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/screens/participant/participant_screen.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/widgets/participant_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Participant> _searchResults = []; 
  final List<Participant> _allParticipants = [];
  EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _searchResults = _allParticipants;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

   void _onSearchChanged() async {
    final String keywords = _searchController.text.trim().toLowerCase();
    print(keywords);
    try {
      final res = await _eventService.getParticipants(keywords: keywords);

      final body = jsonDecode(res.body);

      final List<Participant> tmp = (body['data'] as List)
          .map((e) => Participant.fromJson(e))
          .toList();

      setState(() {
        _searchResults = tmp;
      });

    } catch (e) {
      debugPrint('Search error: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
 

    return Scaffold(
      appBar: AppBar(
        title: Text( l10n.searchParticipantsLabel ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchParticipantsPlaceholder,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                
              ),
            ),
          ),
        ),
      ),
      body: _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noParticipantFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _searchResults.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final participant = _searchResults[index];
                return ParticipantCard(participant: participant,);
              },
            ),
    );
  }

  
}
