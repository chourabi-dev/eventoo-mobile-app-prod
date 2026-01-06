import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';



class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return PopupMenuButton<Locale>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.language, color: Colors.white, size: 20),
      ),
      onSelected: (locale) {
        final appState = MyApp.of(context);
        appState?.setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text('English'),
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('fr'),
          child: Row(
            children: [
              const Text('🇫🇷', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text('Français'),
              if (currentLocale.languageCode == 'fr')
                const Icon(Icons.check, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ],
    );
  }
}