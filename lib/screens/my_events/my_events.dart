import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/widgets/language_switcher.dart';
import '../../models/event.dart';
import '../../widgets/event_card.dart';
import '../../theme/app_theme.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller; 
  EventService _eventService = EventService(); 

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
    _eventService.getUserEventRegistrations().then((res){
      
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






  // call this instead of context.go('/home');
Future<void> finishLogin(BuildContext context,int eventId) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );


  _eventService.authToEvent(eventID: eventId).then((res) async{

    dynamic response = jsonDecode(res.body);
    dynamic participantID = response['participantID'];
    bool success = response['success'];
    
    print("Connectiing ...");
   

    if( success == true){
      if (participantID != null) { 
         
          print("WELCOME BACk");
          print(participantID);

        final storage = const FlutterSecureStorage();
        await storage.write(key: 'participantId', value: participantID.toString());

        if (context.mounted) context.go('/home'); 
      } 
    }else{
       if (context.mounted) Navigator.of(context).pop();
    }
 

  }).catchError((err){ 
    print(err);
    if (context.mounted) Navigator.of(context).pop();
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

                             finishLogin(context, _events[index].id );

                            
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