import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  String _flagForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return '🇫🇷';
      case 'en':
      default:
        return '🇬🇧';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return PopupMenuButton<Locale>(
      tooltip: 'Change language',
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration( 
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          _flagForLocale(currentLocale),
          style: const TextStyle(fontSize: 22),
        ),
      ),
      onSelected: (locale) {
        final appState = MyApp.of(context);
        appState?.setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('fr'),
          child: Row(
            children: [
              const Text('🇫🇷', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text('Français'),
              const Spacer(),
              if (currentLocale.languageCode == 'fr')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text('English'),
              const Spacer(),
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
        
      ],
    );
  }
}
