import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/widgets/calendar_livechat.dart';
import 'package:mobile/widgets/youtube_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:intl/intl.dart';

class EventResponse {
  final bool success;
  final EventData data;

  EventResponse({required this.success, required this.data});

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      success: json['success'],
      data: EventData.fromJson(json['data']),
    );
  }
}

class EventData {
  final List<Room> rooms;

  EventData({required this.rooms});

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      rooms: (json['rooms'] as List).map((r) => Room.fromJson(r)).toList(),
    );
  }
}

class Room {
  final int id;
  final String label;
  final String type;
  final int privacy;
  final String photoUrl;
  final List<String> keywords;
  final List<dynamic> workerProfiles;
  final String description;
  final List<Program> programs;

  Room({
    required this.id,
    required this.label,
    required this.type,
    required this.privacy,
    required this.photoUrl,
    required this.keywords,
    required this.workerProfiles,
    required this.description,
    required this.programs,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      privacy: json['privacy'],
      photoUrl: json['photo_url'],
      keywords: List<String>.from(json['keywords']),
      workerProfiles: List<dynamic>.from(json['worker_profiles']),
      description: json['description'],
      programs: (json['programs'] as List).map((p) => Program.fromJson(p)).toList(),
    );
  }

  bool get hasLiveProgram => programs.any((p) => p.isLive);
  Program? get liveProgram => programs.firstWhere((p) => p.isLive, orElse: () => programs.first);
}

class Program {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final List<String> tags;
  final int canChat;
  final int mode;
  final String liveLinkUrl;
  final String liveTranslationLinkUrl;
  final String mainSponsorPhotoUrl;
  final int type;
  final List<dynamic> participants;
  final List<dynamic> sponsors;
  final List<dynamic> exposers;
  final bool isLive;
  final List<dynamic> moderators;

  // Add room reference
  Room? room;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.canChat,
    required this.mode,
    required this.liveLinkUrl,
    required this.liveTranslationLinkUrl,
    required this.mainSponsorPhotoUrl,
    required this.type,
    required this.participants,
    required this.sponsors,
    required this.exposers,
    required this.isLive,
    required this.moderators,
    this.room,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      tags: List<String>.from(json['tags']),
      canChat: json['can_chat'],
      mode: json['mode'],
      liveLinkUrl: json['live_link_url'],
      liveTranslationLinkUrl: json['live_translation_link_url'],
      mainSponsorPhotoUrl: json['main_sponsor_photo_url'],
      type: json['type'],
      participants: List<dynamic>.from(json['participants']),
      sponsors: List<dynamic>.from(json['sponsors']),
      exposers: List<dynamic>.from(json['exposers']),
      isLive: json['is_live'],
      moderators: List<dynamic>.from(json['moderators']),
    );
  }

  String get formattedStartTime {
    final date = DateTime.parse(startDate);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    final date = DateTime.parse(endDate);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final date = DateTime.parse(startDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);
}

// ============================================================================
// EVENT CALENDAR SCREEN WITH FILTERS
// ============================================================================
class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  String? participantID;
  List<Room> rooms = [];
  EventService _eventService = EventService();
  final storage = const FlutterSecureStorage();
  bool _loading = true;

  // Filter states
  DateTime? selectedDay;
  int? selectedRoomId;
  List<DateTime> availableDays = [];
  List<Program> allPrograms = [];

  @override
  void initState() {
    super.initState();
    getCalendar();
  }

  void getCalendar() async {
    participantID = await storage.read(key: 'participantId');
    if (participantID != null) {
      print(participantID);

      setState(() {
        _loading = true;
      });

      _eventService.getCalendarDetails(participantID!).then((res) {
        print(res.body);

        dynamic body = jsonDecode(res.body);
        EventData data = EventData.fromJson(body['data']);

        // Flatten all programs and attach room reference
        List<Program> programs = [];
        Set<String> daysSet = {};

        for (var room in data.rooms) {
          for (var program in room.programs) {
            program.room = room;
            programs.add(program);
            
            // Extract unique days
            final programDate = DateTime.parse(program.startDate);
            final dayOnly = DateTime(programDate.year, programDate.month, programDate.day);
            daysSet.add(dayOnly.toIso8601String());
          }
        }

        // Sort days
        List<DateTime> days = daysSet
            .map((dateStr) => DateTime.parse(dateStr))
            .toList()
          ..sort();

        setState(() {
          _loading = false;
          rooms = data.rooms;
          allPrograms = programs;
          availableDays = days;
          
          // Set default to first day if available
          if (days.isNotEmpty) {
            selectedDay = days.first;
          }
        });
      }).catchError((err) {
        print(err);
        context.pop();
      });
    }
  }

  List<Program> getFilteredPrograms() {
    return allPrograms.where((program) {
      // Filter by day
      if (selectedDay != null) {
        final programDate = DateTime.parse(program.startDate);
        final programDay = DateTime(programDate.year, programDate.month, programDate.day);
        final filterDay = DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day);
        
        if (programDay != filterDay) {
          return false;
        }
      }

      // Filter by room
      if (selectedRoomId != null && program.room?.id != selectedRoomId) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filteredPrograms = getFilteredPrograms();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendar),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
            padding: EdgeInsets.only(top: 15),
        
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
                ),
              ),
              child: Column(
                children: [
                  // Day Filter
                  _buildDayFilter(),
                  const SizedBox(height: 16),

                  // Room Filter
                  _buildRoomFilter(l10n),
                  const SizedBox(height: 16),

                  // Programs List
                  Expanded(
                    child: filteredPrograms.isEmpty
                        ? Center(
                            child: Text(
                              l10n.programs,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPrograms.length,
                            itemBuilder: (context, index) {
                              return ProgramCard(program: filteredPrograms[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDayFilter() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final day = availableDays[index];
          final isSelected = selectedDay != null &&
              day.year == selectedDay!.year &&
              day.month == selectedDay!.month &&
              day.day == selectedDay!.day;

          // Get localized day name using the device's locale
          final locale = Localizations.localeOf(context);
          final dayName = DateFormat.E(locale.toString()).format(day).substring(0, 3).toUpperCase();

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomFilter(AppLocalizations l10n) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All Rooms" chip
          GestureDetector(
            onTap: () {
              setState(() {
                selectedRoomId = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: selectedRoomId == null
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: selectedRoomId == null
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  l10n.allRoomsLabel ,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedRoomId == null
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),

          // Room chips
          ...rooms.map((room) {
            final isSelected = selectedRoomId == room.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRoomId = room.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    room.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ============================================================================
// PROGRAM CARD WIDGET (Updated with Room Info)
// ============================================================================

class ProgramCard extends StatelessWidget {
  final Program program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: program.isLive
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveProgramScreen(program: program),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room badge and Live indicator
                      Row(
                        children: [
                          if (program.room != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                program.room!.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (program.isLive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle, color: Colors.white, size: 8),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.liveLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Program title
                      Text(
                        program.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${program.formattedStartTime} - ${program.formattedEndTime}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        program.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: program.tags.take(4).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // All Entities (Participants, Moderators, Sponsors, Exposers)
                      const SizedBox(height: 12),
                      _buildAllEntitiesStack(program),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsStack(List<dynamic> participants) {
    final displayCount = participants.length > 4 ? 4 : participants.length;
    final remaining = participants.length - displayCount;

    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          // Display up to 4 participants
          ...List.generate(displayCount, (index) {
            final participant = participants[index];
            final String? photoUrl = participant['photo_url'];
            final String name = participant['name'] ?? '?';

            return Positioned(
              left: index * 28.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E),
                    width: 2,
                  ),
                  image: photoUrl != null && photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null || photoUrl.isEmpty
                    ? Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
          // Show "+X" if there are more participants
          if (remaining > 0)
            Positioned(
              left: displayCount * 28.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllEntitiesStack(Program program) {
    // Combine all entities
    List<Map<String, dynamic>> allEntities = [];
    
    // Add participants
    for (var participant in program.participants) {
      allEntities.add({
        'photo_url': participant['photo_url'],
        'name': participant['name'] ?? '?',
        'type': 'participant',
      });
    }
    
    // Add moderators
    for (var moderator in program.moderators) {
      allEntities.add({
        'photo_url': moderator['photo_url'],
        'name': moderator['name'] ?? '?',
        'type': 'moderator',
      });
    }
    
    // Add sponsors
    for (var sponsor in program.sponsors) {
      allEntities.add({
        'photo_url': sponsor['photo_url'],
        'name': sponsor['name'] ?? '?',
        'type': 'sponsor',
      });
    }
    
    // Add exposers
    for (var exposer in program.exposers) {
      allEntities.add({
        'photo_url': exposer['photo_url'],
        'name': exposer['name'] ?? '?',
        'type': 'exposer',
      });
    }

    if (allEntities.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount = allEntities.length > 5 ? 5 : allEntities.length;
    final remaining = allEntities.length - displayCount;

    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          // Display up to 5 entities
          ...List.generate(displayCount, (index) {
            final entity = allEntities[index];
            final String? photoUrl = entity['photo_url'];
            final String name = entity['name'] ?? '?';

            return Positioned(
              left: index * 28.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E),
                    width: 2,
                  ),
                  image: photoUrl != null && photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null || photoUrl.isEmpty
                    ? Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
          // Show "+X" if there are more entities
          if (remaining > 0)
            Positioned(
              left: displayCount * 28.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// LIVE PROGRAM SCREEN (Keep as is)
// ============================================================================

class LiveProgramScreen extends StatelessWidget {
  final Program program;

  const LiveProgramScreen({super.key, required this.program});

  Widget universalLivePlayer(String iframeHtml) {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadHtmlString(
          '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        background: black;
        height: 100%;
      }
      iframe {
        width: 100%;
        height: 100%;
        border: 0;
      }
    </style>
  </head>
  <body>
    $iframeHtml
  </body>
</html>
''',
        );

      return SizedBox(
        height: 220,
        child: WebViewWidget(controller: controller),
      );
    } catch (e) {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(program.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Video Player
              program.liveLinkUrl.isNotEmpty
                  ? Container(
                      color: Colors.black,
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: YoutubeFramePlayer(
                          videoUrl: program.liveLinkUrl,
                          base: "https://www.youtube-nocookie.com"))
                  : Container(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room badge
                    if (program.room != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          program.room!.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    Text(
                      program.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${program.formattedDate} • ${program.formattedStartTime} - ${program.formattedEndTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: program.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l10n.description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      program.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (program.canChat == 1) ...[
                      Container(
                        height: 500,
                        child: CalendarLiveChat(
                          programID: program.id,
                        ),
                      )
                    ],

                    // Main Sponsor
                    Image.network(
                      program.mainSponsorPhotoUrl,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sponsors
                    if (program.sponsors.isNotEmpty) ...[
                      Text(
                        l10n.sponsors,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEntityRow(program.sponsors),
                      const SizedBox(height: 20),
                    ],

                    // Participants
                    if (program.participants.isNotEmpty) ...[
                      Text(
                        l10n.participants,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEntityRow(program.participants),
                      const SizedBox(height: 20),
                    ],

                    // Moderators
                    if (program.moderators.isNotEmpty) ...[
                      Text(
                        l10n.moderators,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEntityRow(program.moderators),
                      const SizedBox(height: 20),
                    ],

                    // Exposers
                    if (program.exposers.isNotEmpty) ...[
                      Text(
                        l10n.exposers,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEntityRow(program.exposers),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntityRow(List<dynamic> data) {
    print(data);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: data.map((item) {
        final String name = item['name'] ?? '...';
        final String? photoUrl = item['photo_url'];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                image: photoUrl != null && photoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage('$photoUrl'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: photoUrl == null || photoUrl.isEmpty
                  ? Center(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded( 
              child: Text(
                name,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}