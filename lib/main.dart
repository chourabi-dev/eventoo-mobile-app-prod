import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/welcome/welcome_screen.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  await Firebase.initializeApp();
  runApp(MyApp());
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