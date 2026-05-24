import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app_router.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/l10n/app_localizations.dart'; 
import 'package:mobile/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


/*

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
   
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(MyApp());
}*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFirebaseMessaging();

  runApp(MyApp());
}


Future<void> setupFirebaseMessaging() async {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  // App opened from background
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {

      handleNotificationNavigation(message);
    },
  );

  // App opened from terminated state
  RemoteMessage? initialMessage =
      await messaging.getInitialMessage();

  if (initialMessage != null) {
    handleNotificationNavigation(initialMessage);
  }
}



void handleNotificationNavigation(RemoteMessage message)  {
  //final storage = const FlutterSecureStorage();
  final data = message.data;

  final type = data['type'];


  if (type == 'chat') {

    //final myParticipantId = data['my_participant_id'];
    //await storage.write(key: 'participantId', value: myParticipantId);

    AppRouter.router.go(
      '/chats',
    ); 

  }

    if (type == 'networking_experience') { 
      AppRouter.router.go(
        '/networking',
      );  
    }

  







 /* if (type == 'event') {

    final eventId = data['event_id'];

    AppRouter.router.go(
      '/event-details/$eventId',
    );
  }

  if (type == 'chat') {

    final conversationId = data['conversation_id'];

    AppRouter.router.go(
      '/chat/$conversationId',
    );
  }*/

  /*AppRouter.router.go(
    '/event-details/15',
  );*/

}



// ============================================================================
// APP ROOT
// ============================================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static String currentLanguage = "fr";
 
 
  static _MyAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    if (state == null) {
      throw Exception("MyApp.of(context) was called outside MyApp!");
    }
    return state;
  }
 
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('fr');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      MyApp.currentLanguage = locale.languageCode;
    });
  }
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Event App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      routerConfig: AppRouter.router,
    );
  }
}