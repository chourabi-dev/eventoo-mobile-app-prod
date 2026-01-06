import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/widgets/language_switcher.dart';
import '../../models/event.dart';
import '../../widgets/event_card.dart';
import '../../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller; 
  GeneralGervice _generalservice = GeneralGervice(); 
  bool _loading = true;
  
  
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controller.forward();
    _getAllEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _getAllEvents(){
    _generalservice.getEvents().then((res){
      
      dynamic body = jsonDecode(res.body);
      
      // print(body['data']);

      final tmp = (body['data'] as List)
      .map((item) => Event.fromJson(item))
      .toList();
      setState(() {
        _events = tmp;
        _loading = false;
      });


    }).catchError((err){
      print(err);
      setState(() {
         _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title:  Text(l10n.pickEvent),
        actions: [
          LanguageSwitcher()
        ],
      ),
      body: 

      _loading == true ?
      Center(
        child: CircularProgressIndicator(),
      ):
      
      
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
               
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EventCard(
                          event: _events[index],
                          onTap: () {
                            // context.go('/home?event=${Uri.encodeComponent(_events[index].name)}');
                            context.push('/events/${_events[index].id}/pick-profile');
                            
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}