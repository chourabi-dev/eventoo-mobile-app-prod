
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
}

// ============================================================================
// EVENT CALENDAR SCREEN (Shows all rooms)
// ============================================================================
class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {

  String? participantID; 
  List<dynamic> rooms = [];
  EventService _eventService = EventService();
  final storage = const FlutterSecureStorage();
  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCalandar();

  }

  void getCalandar() async {
   participantID = await storage.read(key: 'participantId');
   if( participantID != null ){
    print(participantID);

    // FETCH CALENDAR
    setState(() {
      _loading = true;
    });


    _eventService.getCalendarDetails(participantID!).then((res){
      

      print(res.body);

      dynamic body = jsonDecode(res.body);
 
      EventData data = EventData.fromJson(body['data']);
 
      setState(() {
        _loading = false;
        rooms = data.rooms;
      });

    }).catchError((err){
      print(err);
      context.pop();
    });

   }

  }







  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);



    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendar),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: 
        
        _loading == true ?

        Center(
          child: CircularProgressIndicator() ,
        )
        :
      
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            return RoomCard(room: rooms[index]);
          },
        ),
      ),
    );
  }
}
 



// ============================================================================
// ROOM CARD WIDGET
// ============================================================================

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);


    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: room.hasLiveProgram
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomDetailScreen(room: room),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Room Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${room.photoUrl}', 
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.meeting_room, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Room Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    room.label,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (room.hasLiveProgram)
                                  Container(
                                    padding:  EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children:  [
                                        Icon(Icons.circle, color: Colors.white, size: 8),
                                        SizedBox(width: 4),
                                        Text(
                                          l10n.liveLabel ,
                                          style: TextStyle(
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
                            const SizedBox(height: 4),
                            Text(
                              room.type,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: room.keywords.take(3).map((keyword) {
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
                                    keyword,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${room.programs.length} ${l10n.programs}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
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
}

// ============================================================================
// ROOM DETAIL SCREEN (Shows all programs in a room)
// ============================================================================

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with Room Image
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network( 
                      room.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(room.label),
              ),
            ),

            // Room Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        room.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      room.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.keywords.map((keyword) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                     Text(
                      l10n.programs ,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Programs List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProgramCard(program: room.programs[index]);
                },
                childCount: room.programs.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: room.hasLiveProgram
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveProgramScreen(program: room.liveProgram!),
                  ),
                );
              },
              backgroundColor: Colors.red,
              icon: const Icon(Icons.play_circle_filled),
              label:  Text(l10n.watchLive),
            )
          : null,
    );
  }
}

// ============================================================================
// PROGRAM CARD WIDGET
// ============================================================================

class ProgramCard extends StatelessWidget {
  final Program program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              program.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                                children:  [
                                  Icon(Icons.circle, color: Colors.white, size: 8),
                                  SizedBox(width: 4),
                                  Text(
                                    l10n.liveLabel ,
                                    style: TextStyle(
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            program.formattedDate,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 16),
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
}

// ============================================================================
// LIVE PROGRAM SCREEN
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
              // Live Video Player (Placeholder)
             
             program.liveLinkUrl.isNotEmpty ?
             Container( 
              color: Colors.black,
              height: 250,
              width: MediaQuery.of(context).size.width,
              child:  YoutubeFramePlayer(videoUrl: program.liveLinkUrl, base:"https://www.youtube-nocookie.com")
               ): Container(),
                

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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


                    // Chat Section (if enabled)
               

                    Text(
                      l10n.description ,
                      style: TextStyle(
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
                        child: CalendarLiveChat(programID: program.id,) 
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
                        style: TextStyle(
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
                        style: TextStyle(
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
                        style: TextStyle(
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
                        style: TextStyle(
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
                    
                      image: NetworkImage('${photoUrl}'),
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
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white
              ),
            ),
          ),
        ],
      );
    }).toList(),
  );
}

}