import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/screens/participant/participant_screen.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';

// Model class for Speaker
class Speaker {
  final String name;
  final String countryCode;
  final String profileLabel;
  final List<String> textFields;

  Speaker({
    required this.name,
    required this.countryCode,
    required this.profileLabel,
    required this.textFields,
  });
}

class SpeakersListScreen extends StatefulWidget {
  const SpeakersListScreen({Key? key}) : super(key: key);

  @override
  State<SpeakersListScreen> createState() => _SpeakersListScreenState();
}

class _SpeakersListScreenState extends State<SpeakersListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  bool loading = true;

  List<Participant> speakers = []; 

  EventService eventService = EventService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
    fetchSpeakers();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose(); 
    
  }
 

  void fetchSpeakers(){
    setState(() {
      loading = true;
    });

    eventService.spekers().then((res){
      

      dynamic body = jsonDecode(res.body);

        setState(() {
         speakers = (body['speakers'] as List)
              .map((e) => Participant.fromJson(e))
              .toList();
          });

      setState(() {
        loading = false;
      });

      
    }).catchError((err){
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainDeepBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:  AppTheme.mainDeepBackgroundColor,
        title: Text(
          l10n.speakersLabel,
          style: TextStyle(
            color: Color(0xFF1A1F36),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: 
      loading == true ?

      Center(
        child: CircularProgressIndicator(),
      ):
      
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: speakers.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animationDelay = index * 0.1;
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    animationDelay > 1 ? 1 : animationDelay,
                    1.0,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              );

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animation.value)),
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              );
            },
            child: SpeakerCard(speaker: speakers[index]),
          );
        },
      ),
    );
  }
}

class SpeakerCard extends StatelessWidget {
  final Participant speaker;

  const SpeakerCard({Key? key, required this.speaker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
      onTap: () {
        Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ParticipantDetailScreen(participant: speaker),
              ),
            );
      },
      child: 
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Line: Profile Label and Flag
          Container(
            decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
            ),
  height: 350,
  width: MediaQuery.of(context).size.width,
  child: Image.network(
    speaker.photoUrl,
    fit: BoxFit.cover,
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) {
        // Image chargée → fade-in
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 500),
          child: child,
        );
      } else {
        // Affiche un loader au centre
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      }
    },
    errorBuilder: (context, error, stackTrace) {
      return Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    },
  ),
)
,
          SizedBox(height: 12,),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Label
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  speaker.profileLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ),
              // Flag
              Text(
                _getFlag(speaker.country.name),
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Second Line: Full Name
          Text(
            speaker.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Text Fields Array
          ...speaker.feilds.where((f)=>f.showOnParticipantListPage && f.value != "").map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${field.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ));
  }

  String _getFlag(String countryCode) {
    // Convert country code to flag emoji
    final Map<String, String> flags = {
      
  'États-Unis': '🇺🇸',
  'France': '🇫🇷',
  'Japon': '🇯🇵',
  'Égypte': '🇪🇬',
  'Espagne': '🇪🇸',
  'Royaume-Uni': '🇬🇧',
  'Allemagne': '🇩🇪',
  'Italie': '🇮🇹',
  'Canada': '🇨🇦',
  'Australie': '🇦🇺',
  'Brésil': '🇧🇷',
  'Inde': '🇮🇳',
  'Chine': '🇨🇳',
  'Corée du Sud': '🇰🇷',
  'Mexique': '🇲🇽',
  'Tunisie': '🇹🇳',


    };
    return flags[countryCode] ?? '🇹🇳';
  }
}