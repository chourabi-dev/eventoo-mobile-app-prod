import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/event.dart';
import 'package:mobile/screens/badge_display_screen/badge_display_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/module_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {


  dynamic _event;
  bool _loading = true; 
  List<ModuleData> modules = [ ];

  Map<String, dynamic>? _badgeSettings;
  Map<String, dynamic>? _userData;
  bool _loadingBadgeData = false;
  EventService _eventService = EventService();
  List<dynamic> chatNotifications  = [];
  List<Event> _myEvents  = [];
   



   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEventInfo();
    updateUnreadedMessages();
    listenToChat();
    _loadBadgeData();

  }

  void listenToChat() async{
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {

        try { 
          
            updateUnreadedMessages();
          
        } catch (e) {
          print("Error processing message: $e");
        }
      });

  }

  
    void updateUnreadedMessages() {
    _eventService.getUnreadedMessages().then((res) {
      dynamic body = jsonDecode(res.body);
      print(body);

      setState(() {
        chatNotifications = (body['messages'] as List) .toList();
      });
      
    }).catchError((err) {
      print('Error fetching notifications: $err');
    });
  }



   void getEventInfo(){
      setState(() {
        _loading= true;
      });

      /*_eventService.getUserEventRegistrations().then((res){
        setState(() {
          _myEvents = [];
        });
      });*/

      _eventService.getCurrentConnectedEventDetails().then((res){

        dynamic body = jsonDecode(res.body);

        print(body);
  
        setState(() {
          _loading= false;
          _event = body;
        });
        
      }).catchError((err){ 
        setState(() {
        _loading= false;
      });
    });
  }





  List<ModuleData> buildModules(dynamic _eventData, AppLocalizations l10n) {
    print(_eventData['event']['show_participants_list_in_app']);
    bool showParticipantList = false;

    if( _eventData['event']['show_participants_list_in_app'] == null ){
      showParticipantList = false;
    }else{
      if( _eventData['event']['show_participants_list_in_app'] == 1 ){
        showParticipantList = true;
      }
    }

  final List<ModuleData> modules = [
    ModuleData(
      title: (l10n) =>  "Badge", //l10n.badgeOptions,
      icon: Icons.badge,
      gradient: AppTheme.primaryGradient,
      color: AppTheme.primaryColor,
      route: '/badge', // <-- add route here,
      backgroundIMAGE: 'assets/menu-badge.png'
    ),

    ModuleData(
      title: (l10n) => l10n.calendar,
      icon: Icons.calendar_today_rounded,
      gradient: AppTheme.secondaryGradient,
      color: AppTheme.secondaryColor,
      route: '/event-calendar', // <-- add route here
      backgroundIMAGE: 'assets/agenda.png'
    ),
    // Participants module only if allowed
    if ( showParticipantList == true)
      ModuleData(
        title: (l10n) => l10n.participants,
        icon: Icons.people_rounded, 
        gradient: AppTheme.expositionGardien,
        color: const Color.fromARGB(255, 205, 154, 78),
        route: '/participants',
        backgroundIMAGE: 'assets/21.png',
      ),
    
    ModuleData(
      title: (l10n) => l10n.networking,
      icon: Icons.business_center_rounded,
      gradient: AppTheme.primaryGradient,
      color: AppTheme.primaryColor,
      route: '/networking',
      backgroundIMAGE: 'assets/4.png'
    ),

    ModuleData(
      title: (l10n) => l10n.speakersLabel,
      icon: Icons.business_center_rounded,
      gradient: AppTheme.primaryGradient,
      color: AppTheme.primaryColor,
      route: '/speakers',
      backgroundIMAGE: 'assets/20.png'
    ),


    ModuleData(
      title: (l10n) => l10n.myContacts,
      icon: Icons.contacts,
      gradient: AppTheme.pinkGradient,
      color: AppTheme.primaryColor,
      route: '/my-contacts',
      backgroundIMAGE: 'assets/13.png'
    ),


    ModuleData(
      title: (l10n) => l10n.businessCardExchange,
      icon: Icons.contact_emergency,
      gradient: AppTheme.pinkGradient,
      color: Color.fromARGB(255, 117, 193, 251),
      route: '/business-cards',
      backgroundIMAGE: 'assets/menu-badge.png'
    ),

    ModuleData(
      title: (l10n) => l10n.exposers,
      icon: Icons.store,
      gradient: AppTheme.participantGardien,
        color: AppTheme.deepColor,
      route: '/exposition',
      backgroundIMAGE: 'assets/11.png'
    ),
 



  ];

  return modules;
}


 Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


    void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


    Future<void> _loadBadgeData() async {
    setState(() => _loadingBadgeData = true);

    try {
      // TODO: Replace with actual API calls
      // Fetch badge settings from your API
      final badgeSettingsTEXT = await _eventService.getMyBadgeSetting();


      // do we have a badge setting ?
      dynamic badgeSuccess = jsonDecode(badgeSettingsTEXT.body)['success'];

      if( badgeSuccess ){
          dynamic setting = jsonDecode(badgeSettingsTEXT.body)['setting'];


          // Fetch user data from your API
          final userDataTEXT = await _eventService.getEventProfileDATA();

          setState(() {
            _badgeSettings = setting;
            _userData = jsonDecode(userDataTEXT.body)['data'];
            _loadingBadgeData = false;
          });
      }else{
        // log err
        setState(() => _loadingBadgeData = false);
      }
      
      
    } catch (e) {
      print('Error loading badge data: $e');
      setState(() => _loadingBadgeData = false);
    }
  }

  void _showMyBadge() {
    if (_loadingBadgeData) {
      _showSnackBar('Loading badge data...');
      return;
    }

    if (_badgeSettings == null || _userData == null) {
      _showSnackBar('Badge data not available');
      return;
    }else{
      
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BadgeDisplayScreen(
          badgeSettings: _badgeSettings!,
          userData: _userData!,
        ),
      ),
    );

    }
  }


 
 
  @override
  Widget build(BuildContext context) {

    
    
    final l10n = AppLocalizations.of(context);

    final modules = _event != null ? buildModules(_event, l10n) : [];
     
    return 
    _loading == true ?
    Center(
      child: CircularProgressIndicator(),
    )
    :
    Container(
        decoration: BoxDecoration(
          color:  AppTheme.mainBackgroundColor,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
 

              Container(
                padding: const EdgeInsets.only(left: 24,right: 24,bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    IconButton(onPressed: (){
                      context.go("/");
                      /*showEventSelectorModal(context: context, events: _myEvents, onSelected: (e){
                        print(e!.id);

                      });*/
                       
                    }, icon: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: AppTheme.accentColor,
                      size: 25,
                    ),),
                    

                    GestureDetector(
                      onTap: () {
                        context.push("/chats");
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Colors.grey,
                            size: 26,
                          ),

                          // Badge
                          if (chatNotifications.isNotEmpty)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  chatNotifications.length > 99 ? '99+' : '${chatNotifications.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )


                  ],
                )
              ),

              Padding(
                padding: const EdgeInsets.only(left: 24,right: 24,bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcome,
                              overflow: TextOverflow.clip,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.accentColor
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: Container(
                                width:( MediaQuery.of(context).size.width -30) / 2,
                                
                                child: Text(

                                _event != null ?( _event['event']['name'] ?? "oups" ) : "...",
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.fade,
                              )
                              
                              ,)
                            ),
                          ],
                        ),
                        
                        Container(
                            width:( MediaQuery.of(context).size.width - 100) / 2,
                            child:  _event['event']['logo_url'] != null ?

                            Image.network(
                              'https://eventoo.io${_event['event']['logo_url']}' ?? "",
                              webHtmlElementStrategy: WebHtmlElementStrategy.fallback
                            
                            ): null
                            
                            ,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Modules grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 400 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value,
          child: child,
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: () {
                final route = modules[index].route;

                // exception for badge
                if (route == "/badge") {
                  _showMyBadge();
                } else {
                  if (route != null) {
                    context.push(route);
                  }
                }
              },
              child: Image.asset(
                modules[index].backgroundIMAGE,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          modules[index].title(l10n), // <-- title here
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
},

                  ),
                ),
              ),
               
            ],
          ),
        ),
      );
  }
}

 
